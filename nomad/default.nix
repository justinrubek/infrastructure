{
  config,
  inputs,
  lib,
  self,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
  in rec {
    packages = {
      nomadJobs = inputs.nix-nomad.lib.mkNomadJobs {
        inherit system;
        config = [
          ./jobs/dummy-api.nix
        ];
      };
    };
  };
}