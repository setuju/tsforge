# ============================================================
#  flake.nix — tsforge modern Nix flake
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Usage:
#    nix develop              # enter the dev shell
#    nix flake show           # inspect outputs
#    nix flake update         # bump locked inputs
# ============================================================

{
  description = "tsforge — TypeScript Performance & Diagnostics Toolkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        tsgo = pkgs.writeShellScriptBin "tsgo" ''
          exec npx --yes @typescript/native-preview "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          name = "tsforge-dev";

          buildInputs = with pkgs; [
            nodejs_22
            nodePackages.npm
            nodePackages.typescript
            tsgo
            shellcheck
            bashInteractive
            vhs
            ffmpeg
            ttyd
          ];

          shellHook = ''
            echo "⚡ tsforge dev shell — node $(node --version)"
            export PATH="$PWD:$PATH"
          '';
        };
      });
}