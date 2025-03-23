{ inputs, ... }: {
  imports = [
    inputs.rust-flake.flakeModules.default
    inputs.rust-flake.flakeModules.nixpkgs
    inputs.process-compose-flake.flakeModule
    inputs.cargo-doc-live.flakeModule
  ];
  perSystem = { config, self', pkgs, lib, ... }: {
    rust-project.crates."res-soc".crane.args = {
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
    };
    packages.default = self'.packages.res-soc;
  };
}
