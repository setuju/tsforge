# ============================================================
#  shell.nix — tsforge reproducible dev environment
#  Author  : Jack
#  GitHub  : https://github.com/setuju
#  Website : https://saturumah.net
#
#  Usage:
#    nix-shell              # legacy command
#    nix develop            # flake-based (recommended)
#
#  Provides:
#    - Node.js 22 (LTS)
#    - TypeScript compiler (tsc)
#    - tsgo (native Go compiler, 8-12x faster)
#    - ShellCheck (for linting tsforge.sh)
#    - Bash 5.x (for testing)
#    - VHS + ttyd + ffmpeg (for demo GIF generation)
# ============================================================

{ pkgs ? import <nixpkgs> { } }:

let
  # TypeScript 7 native compiler (tsgo) via npm.
  tsgo = pkgs.writeShellScriptBin "tsgo" ''
    exec npx --yes @typescript/native-preview "$@"
  '';
in
pkgs.mkShell {
  name = "tsforge-dev";

  buildInputs = with pkgs; [
    # Runtime
    nodejs_22
    nodePackages.npm
    nodePackages.typescript

    # Native Go compiler (TypeScript 7 preview)
    tsgo

    # Linting & testing
    shellcheck
    bashInteractive

    # Demo GIF generation
    vhs
    ffmpeg
    ttyd
  ];

  shellHook = ''
    echo ""
    echo "  ⚡ tsforge — development environment"
    echo "  ─────────────────────────────────────"
    echo "  Node.js   : $(node --version)"
    echo "  npm       : $(npm --version)"
    echo "  tsc       : $(tsc --version)"
    echo "  ShellCheck: $(shellcheck --version | head -1)"
    echo ""
    echo "  Quick start:"
    echo "    source ./tsforge.sh"
    echo "    tsforge-help"
    echo "    shellcheck tsforge.sh"
    echo ""

    # Make the local tsforge.sh available on PATH
    export PATH="$PWD:$PATH"
  '';
}