{
  config,
  lib,
  ...
}: let
  cfg = config.services.justinrubek.kubernetes;
in {
  options = {
    services.justinrubek.kubernetes = {
      enable = lib.mkEnableOption (lib.mdDoc "Kubernetes cluster components");
    };
  };

  config = lib.mkIf cfg.enable {};
}
