{
  config,
  lib,
  inputs',
  pkgs,
  ...
}:
with lib; let
  cfg = config.justinrubek.services.vintagestory;

  dataDir = "/opt/vintagestory/data";
in {
  options = {
    justinrubek.services.vintagestory = {
      enable = mkEnableOption (lib.mdDoc "vintagestory server");
      package = lib.mkPackageOption inputs'.vintagestory.packages "vintagestory" {};
    };
  };

  config = mkIf cfg.enable {
    systemd.services.vintagestory = {
      description = "vintagestory game server";
      requires = ["network.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/vintagestory-server --dataPath ${dataDir}";
        ReadWritePaths = [dataDir];
        User = "vintagestory";
        WorkingDirectory = dataDir;
      };
      wantedBy = ["multi-user.target"];
    };

    users = {
      groups."vintagestory" = {};
      users."vintagestory" = {
        group = "vintagestory";
        home = "/opt/vintagestory";
        shell = pkgs.zsh;
        isSystemUser = true;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        42420 # vintagestory
      ];
      allowedUDPPorts = [
        42420 # vintagestory
      ];
    };
  };
}
