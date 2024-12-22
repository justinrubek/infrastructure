{
  config,
  lib,
  ...
}: let
  cfg = config.services.justinrubek.kubernetes;
in {
  imports = [./apiserver.nix];

  options = {
    services.justinrubek.kubernetes = {
      enable = lib.mkEnableOption (lib.mdDoc "Kubernetes cluster components");
      nodes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          ip = lib.mkOption {type = lib.types.str;};
        });
        example = ''{ hostname.ip = "10.10.10.10"; }'';
      };
    };
  };

  config = lib.mkIf cfg.enable {};
}
