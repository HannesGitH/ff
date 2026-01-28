{
  description = "ff-state-watcher: important part of ff, auto generates state classes for you";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;
      forAllSystems = lib.genAttrs systems;
      spkgs = system: nixpkgs.legacyPackages.${system}.pkgs;
    in {
      packages = forAllSystems (s: with spkgs s; rec {
        parser = rustPlatform.buildRustPackage {
          pname = "ff-state-watcher";
          version = "0.0.1";
          src = ./state_watcher;
          cargoLock = {
            lockFile = ./state_watcher/Cargo.lock;
            outputHashes = {
              "tree-sitter-dart-0.0.1" = "sha256-6TJV4N0YKufvMJh81stpKGaxmFTzeFwoEz5t07yXS24=";
            };
          };
          nativeBuildInputs = [
            pkg-config
          ];
          buildInputs = [
            openssl
          ];
        };
        default = parser;
      });

      devShells = forAllSystems (s: with spkgs s; {
        default = mkShell {
          RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
          buildInputs = [
            cargo
            rustc
          ];
        };
      });
  };
}
