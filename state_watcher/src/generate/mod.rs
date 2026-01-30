use crate::types::Class;
use anyhow::Result;
use handlebars::Handlebars;
use serde_json::json;

pub struct Generator<'a> {
    handlebars: Handlebars<'a>,
}

impl<'a> Generator<'a> {
    pub fn new() -> Result<Self> {
        let mut handlebars = Handlebars::new();
        handlebars.register_template_string(
            "template",
            include_str!("../../templates/state.ff.dart.handlebars"),
        )?;
        Ok(Self { handlebars })
    }

    pub fn generate(
        &self,
        classes: &[Class],
        file_name: &str,
        view_override: Option<&str>,
    ) -> Result<String> {
        let view_base = view_override.unwrap_or("FFView");
        let rendered = self.handlebars.render("template", &json!({
            "file_name": file_name,
            "view_base": view_base,
            "classes": classes.iter().map(|c| json!({
                "class_name": c.name_str,
                "fields": c.fields.iter().map(|f| json!({
                    "name_str": f.name_str,
                    "type_str": f.type_str,
                    "is_nullable": f.is_nullable,
                    "is_map": f.is_map,
                    "map_key_type": f.map_key_type,
                    "map_value_type": f.map_value_type,
                })).collect::<Vec<_>>(),
            })).collect::<Vec<_>>(),
        }))?;
        Ok(rendered)
    }
}
