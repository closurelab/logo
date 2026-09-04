{
  logoFor,
  pkgsFor,
  preCommitFor,
}:

{ system }:

let
  pkgs = pkgsFor { inherit system; };
  logo = logoFor { inherit pkgs; };
  preCommit = preCommitFor { inherit pkgs; };
in
pkgs.mkShell {
  name = "closurelab-logo-dev";

  packages = [
    logo.generator
    pkgs.just
  ]
  ++ preCommit.enabledPackages;

  inherit (preCommit) shellHook;
}
