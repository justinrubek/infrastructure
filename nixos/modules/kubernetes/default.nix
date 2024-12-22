{
  config,
  lib,
  ...
}: let
  cfg = config.justinrubek.kubernetes;
in {
  imports = [./apiserver.nix];

  options = {
    justinrubek.kubernetes = {
      enable = lib.mkEnableOption (lib.mdDoc "Kubernetes cluster components");
      nodes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            ip = lib.mkOption {type = lib.types.str;};
          };
        });
        example = ''{ hostname.ip = "10.10.10.10"; }'';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.kubernetes.masterAddress = "${cfg.nodes.${config.networking.hostName}.ip}";
  };
}
