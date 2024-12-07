{
  inputs,
  lib,
  self,
  ...
}: {
  imports = [
    inputs.config-parts.flakeModules.home
  ];

  config-parts.home = {
    modules.shared =
      [
        ({config, ...}: {
          xdg.configHome = "${config.home.homeDirectory}/.config";
        })
      ]
      ++ builtins.attrValues self.homeModules
      ++ builtins.attrValues self.modules;

    configurations = {
      "justin@alex".system = "x86_64-linux";
      "justin@bunky".system = "x86_64-linux";
      "justin@ceylon".system = "x86_64-linux";
      "justin@huginn".system = "x86_64-linux";
      "justin@pyxis".system = "x86_64-linux";
    };
  };
}
