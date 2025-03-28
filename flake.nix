{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, crane, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true; # Enable unfree packages
          config.android_sdk.accept_license = true;
          overlays = [ (import rust-overlay) ];
        };
        craneLib = (crane.mkLib pkgs).overrideToolchain (p:
          p.rust-bin.stable.latest.default.override {
            targets = [ "wasm32-unknown-unknown" "aarch64-linux-android" ];
          });
        androidComposition =
          pkgs.androidenv.composeAndroidPackages { includeNDK = true; };
        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          strictDeps = true;
          buildInputs = [
            # Add additional build inputs here
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
            pkgs.lld
            pkgs.xdotool
            pkgs.sdkmanager
            pkgs.rustup
            pkgs.android-studio
            (pkgs.android-studio.withSdk androidComposition.androidsdk)
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs can be set here
            pkgs.libiconv
          ];
          nativeBuildInputs = with pkgs; [
            pkg-config
            gobject-introspection
            cargo
            cargo-tauri
            nodejs
          ];
          shellHook = ''
            export CARGO_HOME=$PWD/.cargo
            export RUSTUP_HOME="$PWD/.rustup"
            export PATH="$CARGO_HOME/bin:$PATH"
            cargo install -j $(nproc) --root .cargo cargo-binstall
            cargo binstall dioxus-cli

            export ANDROID_HOME="${androidComposition.androidsdk}/libexec/android-sdk";
            export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk-bundle";
          '';
        };

        my-crate = craneLib.buildPackage (commonArgs // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        });
      in {
        checks = { inherit my-crate; };

        packages.default = my-crate;

        apps.default = flake-utils.lib.mkApp { drv = my-crate; };

        devShells.default = craneLib.devShell {
          # Inherit inputs from checks.
          checks = self.checks.${system};
          inputsFrom = [ my-crate ];
          # Additional dev-shell environment variables can be set directly
          # MY_CUSTOM_DEVELOPMENT_VAR = "something else";

          GDK_BACKEND = "x11";
          # Extra inputs can be added here; cargo and rustc are provided by default.
          packages = [
            # pkgs.ripgrep
          ];
        };
      });
}
