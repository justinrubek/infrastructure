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
          justinrubek.administration.enable = true;
          nix.settings.trusted-users = ["@wheel"];
          nixpkgs.config.allowUnfree = true;
        }
        {
          i18n = {
            defaultLocale = "en_US.UTF-8";
            extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
          };
          time.timeZone = "America/Chicago";
        }
        ({pkgs, ...}: {
          programs.zsh.enable = true;
          users.users = {
            justin = {
              isNormalUser = true;
              description = "Justin";
              extraGroups = ["networkmanager" "wheel"];
              shell = pkgs.zsh;

              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1Uj62/yt8juK3rSfrVuX/Ut+xzw1Z75KZS/7fOLm6l justin@eunomia"
              ];
            };
          };
        })
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
