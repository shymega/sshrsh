# SPDX-FileCopyrightText: 2024 Dom 'shymega' Rodriguez

# SPDX-License-Identifier: Apache-2.0

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.outputs.legacyPackages.${system};
      in
      {
        packages.rsshsh = pkgs.callPackage ./rsshsh.nix { };
        packages.default = self.outputs.packages.${system}.rsshsh;

        devShells.default = self.packages.${system}.default.overrideAttrs (super: {
          nativeBuildInputs = with pkgs; [
            super.nativeBuildInputs
            ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        });
      })
    // {
      overlays.default = final: prev: {
        inherit (self.packages.${final.system}) rsshsh;
      };
    };
}
