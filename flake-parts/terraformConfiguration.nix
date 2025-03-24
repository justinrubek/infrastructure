{
  inputs,
  self,
  lib,
  ...
}: {
  imports = [];

  perSystem = {
    self',
    pkgs,
    lib,
    system,
    inputs',
    ...
  }: {
    thoenix.terraformConfigurations = {
      enable = true;

      configDirectory = ../terraform/configurations;

      terranixModules = lib.mapAttrsToList (name: value: value) self.terraformModules;
    };
  };
}
