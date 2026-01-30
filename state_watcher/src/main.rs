use anyhow::{Context, Result};
use clap::Parser;
use notify::{
    Event, EventKind, RecursiveMode, Watcher,
    event::{CreateKind, DataChange, ModifyKind},
};
use regex::Regex;
use serde::Deserialize;
use std::path::PathBuf;
use std::{
    fs::File,
    io::{BufReader, Read, Write},
    path::Path,
    sync::mpsc,
};

use crate::generate::Generator;
mod generate;
mod parse;
mod types;

/// ff-state-watcher: important part of ff, auto generates state classes for you
/// watches your files and generates code only where and when needed
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// path to the ff.yaml configuration file
    #[arg(value_name = "CONFIG")]
    config: PathBuf,
}

/// Configuration loaded from ff.yaml
#[derive(Debug, Deserialize)]
struct Config {
    /// directory in which we will watch for changes (relative to config file)
    directory: PathBuf,

    /// magic token to identify the files to parse
    #[serde(default = "default_magic_token")]
    magic_token: String,

    /// file extension to name the generated file
    #[serde(default = "default_output_extension")]
    output_file_extension: String,

    /// files extensions to watch for changes
    #[serde(default = "default_file_extensions")]
    file_extensions: Vec<String>,

    /// file patterns to ignore
    #[serde(default)]
    ignore_patterns: Vec<String>,

    /// custom view class to extend instead of FFView in typedef helpers
    #[serde(default)]
    view_override: Option<String>,
}

fn default_magic_token() -> String {
    "ff-state".to_string()
}

fn default_output_extension() -> String {
    "ff.dart".to_string()
}

fn default_file_extensions() -> Vec<String> {
    vec!["dart".to_string()]
}

fn main() -> Result<()> {
    let args = Args::parse();

    // Read and parse the config file
    let config_path = args.config.canonicalize().context("Config file not found")?;
    let config_dir = config_path
        .parent()
        .ok_or_else(|| anyhow::anyhow!("Cannot determine config file directory"))?;

    let config_file = File::open(&config_path)
        .with_context(|| format!("Failed to open config file: {:?}", config_path))?;
    let config: Config = serde_yaml::from_reader(config_file)
        .with_context(|| format!("Failed to parse config file: {:?}", config_path))?;

    // Resolve directory relative to config file location
    let directory = if config.directory.is_absolute() {
        config.directory
    } else {
        config_dir.join(&config.directory).canonicalize()
            .with_context(|| format!("Directory not found: {:?}", config.directory))?
    };

    println!("Starting ff-state-watcher...");
    println!("  Config: {:?}", config_path);
    println!("  Directory: {:?}", directory);
    println!("  Magic token: {}", config.magic_token);
    println!("  Output extension: {}", config.output_file_extension);
    if let Some(ref view) = config.view_override {
        println!("  View override: {}", view);
    }

    let file_watcher = FileWatcher::new(
        &directory,
        &config.magic_token,
        &config.output_file_extension,
        &config.file_extensions,
        &config.ignore_patterns,
        config.view_override,
    )?;

    println!("Watcher initialized, listening for changes...");

    // this will run forever
    file_watcher.run()
}

struct FileWatcher<'a> {
    rx: mpsc::Receiver<notify::Result<Event>>,
    // just here to keep the watcher alive
    #[allow(dead_code)]
    watcher: notify::RecommendedWatcher,
    magic_token: String,
    output_file_extension: String,
    allowed_watch_extensions: Vec<String>,
    generator: Generator<'a>,
    ignore_patterns: Vec<Regex>,
    view_override: Option<String>,
}

impl<'a> FileWatcher<'a> {
    fn new(
        directory: &Path,
        magic_token: &str,
        output_file_extension: &str,
        file_extensions: &[String],
        ignore_patterns: &[String],
        view_override: Option<String>,
    ) -> Result<Self> {
        let (tx, rx) = mpsc::channel::<notify::Result<Event>>();
        let mut watcher = notify::recommended_watcher(tx)?;
        watcher.watch(Path::new(&directory), RecursiveMode::Recursive)?;

        let generator = Generator::new()?;
        // keep the watcher alive
        Ok(Self {
            rx,
            watcher,
            magic_token: magic_token.to_string(),
            output_file_extension: output_file_extension.to_string(),
            allowed_watch_extensions: file_extensions.to_vec(),
            generator,
            ignore_patterns: ignore_patterns
                .iter()
                .filter(|pattern| !pattern.is_empty())
                .map(|pattern| Regex::new(pattern).unwrap())
                .collect(),
            view_override,
        })
    }

    fn run(&self) -> Result<()> {
        for res in &self.rx {
            match res {
                Ok(event) => self.handle_event(&event)?,
                Err(e) => println!("watch error: {:?}", e),
            }
        }
        Ok(())
    }

    fn handle_event(&self, event: &Event) -> Result<()> {
        match event.kind {
            EventKind::Modify(ModifyKind::Data(DataChange::Content))
            | EventKind::Create(CreateKind::File) => self.handle_file_change(
                event
                    .paths
                    .first()
                    .ok_or(anyhow::anyhow!("No path found"))?,
            ),
            _ => Ok(()),
        }
    }

    fn handle_file_change(&self, path: &Path) -> Result<()> {
        if path
            .to_str()
            .unwrap()
            .ends_with(&self.output_file_extension)
        {
            return Ok(());
        }

        if !self.allowed_watch_extensions.iter().any(|ext| {
            path.extension()
                .unwrap_or_default()
                .to_str()
                .unwrap()
                .ends_with(ext)
        }) {
            return Ok(());
        }

        if self
            .ignore_patterns
            .iter()
            .any(|pattern| pattern.is_match(path.to_str().unwrap()))
        {
            return Ok(());
        }

        self.parse_file(path)?;
        Ok(())
    }

    fn parse_file(&self, path: &Path) -> Result<()> {
        let file = File::open(path)?;
        let mut reader = BufReader::new(file);
        let mut code = String::new();
        reader.read_to_string(&mut code)?;

        println!("parsing file: {:?}", path);
        let classes = parse::parse(&code, &self.magic_token)?;

        if classes.is_empty() {
            return Ok(());
        }
        println!("found {} classes in file: {:?}", classes.len(), path);

        let generated = self.generator.generate(
            &classes,
            path.file_name().unwrap().to_str().unwrap(),
            self.view_override.as_deref(),
        )?;
        let output_path = path.with_extension(&self.output_file_extension);
        let mut file = File::create(output_path)?;
        file.write_all(generated.as_bytes())?;

        Ok(())
    }
}
