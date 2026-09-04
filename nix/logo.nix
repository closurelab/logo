{ pkgs }:

let
  source = ../src/logo.lisp;

  generator = pkgs.writeShellApplication {
    name = "closurelab-logo";
    runtimeInputs = [
      pkgs.librsvg
      pkgs.sbcl
    ];
    text = ''
      exec sbcl --noinform --disable-debugger --script ${source} "$@"
    '';
  };

  artifacts = pkgs.runCommand "closurelab-logo-artifacts" { nativeBuildInputs = [ generator ]; } ''
    closurelab-logo "$out"
  '';
in
{
  inherit artifacts generator;
}
