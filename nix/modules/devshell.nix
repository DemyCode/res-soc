{ inputs, ... }: {
  perSystem = { config, self', pkgs, lib, ... }: {
    devShells.default = pkgs.mkShell {
      name = "res-soc-shell";
      nativeBuildInputs = with pkgs; [
        pkg-config
        gobject-introspection
        cargo
        cargo-tauri
        nodejs
      ];
      buildInputs = lib.optionals pkgs.stdenv.isDarwin
        (with pkgs.darwin.apple_sdk.frameworks; [ IOKit ]) ++ [
          pkgs.at-spi2-atk
          pkgs.atkmm
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.glib
          pkgs.gtk3
          pkgs.harfbuzz
          pkgs.librsvg
          pkgs.libsoup_3
          pkgs.pango
          pkgs.webkitgtk_4_1
          pkgs.openssl
        ];
      inputsFrom = [
        self'.devShells.rust
        config.pre-commit.devShell # See ./nix/modules/pre-commit.nix
      ];
      packages = with pkgs; [
        just
        nixd # Nix language server
        bacon
        config.process-compose.cargo-doc-live.outputs.package
      ];
    };
  };
}
