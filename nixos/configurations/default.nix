{
  inputs,
  self,
  ...
}: {
  imports = [
    inputs.config-parts.flakeModules.nixos
  ];

  config-parts.nixos = {
    modules.shared =
      [
        {
          boot.tmp.cleanOnBoot = true;
          caches.enable = true;
          documentation.man = {
            enable = true;
            generateCaches = true;
          };
          i18n.extraLocaleSettings = {
            LC_TIME = "en_GB.UTF-8";
          };
          justinrubek.administration.enable = true;
          nix.settings.trusted-users = ["@wheel"];
        }
        inputs.sops-nix.nixosModules.sops
      ]
      ++ builtins.attrValues self.nixosModules
      ++ builtins.attrValues self.modules;

    configurations = {
      alex.system = "x86_64-linux";
      bunky.system = "x86_64-linux";
      ceylon.system = "x86_64-linux";
      factorio.system = "x86_64-linux";
      hetzner-base.system = "x86_64-linux";
      huginn.system = "x86_64-linux";
      pyxis.system = "x86_64-linux";
    };
  };
}
