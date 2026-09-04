{
  pkgsFor,
  preCommitFor,
}:

{ system }:

let
  pkgs = pkgsFor { inherit system; };
  preCommit = preCommitFor { inherit pkgs; };
in
pkgs.mkShell {
  name = "closurelab-logo-dev";

  packages = [
    pkgs.just
    pkgs.librsvg
    pkgs.sbcl
  ]
  ++ preCommit.enabledPackages;

  inherit (preCommit) shellHook;
}
