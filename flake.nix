{
  inputs = {
    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      fenix,
      flake-utils,
      nixpkgs,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = (
          import nixpkgs {
            inherit system;
            overlays = [
              (
                _final: prev:
                let
                  pkgs = fenix.inputs.nixpkgs.legacyPackages.${prev.system};
                in
                fenix.overlays.default pkgs pkgs
              )
            ];
          }
        );
      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              (pkgs.fenix.complete.withComponents [
                "cargo"
                "clippy"
                "rust-src"
                "rustc"
                "rustfmt"
              ])
              pkgs.rust-analyzer-nightly
              pkgs.nixfmt-rfc-style
              pkgs.just
              pkgs.treefmt
            ];
          };
        };
      }
    );
}
