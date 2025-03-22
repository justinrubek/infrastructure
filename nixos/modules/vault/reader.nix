{
  config,
  lib,
  ...
}: let
  cfg = config.justinrubek.vault.reader;
in {
  options.justinrubek.vault.reader = {
    enable = lib.mkEnableOption "allow reading vault secrets";

    secret_file = lib.mkOption {
      type = lib.types.str;
      description = "sops secret file";
    };
  };

  config = lib.mkIf cfg.enable {
    detsys.vaultAgent.defaultAgentConfig = {
      vault = {address = "http://127.0.0.1:8200";};
      auto_auth = {
        method = [
          {
            type = "approle";
            config = {
              remove_secret_id_file_after_reading = false;
              role_id_file_path = config.sops.secrets."vault_role_id".path;
              secret_id_file_path = config.sops.secrets."vault_secret_id".path;
            };
          }
        ];
        template_config = {
          static_secret_render_interval = "5s";
        };
      };
    };

    sops.secrets = {
      "vault_role_id" = {
        sopsFile = cfg.secret_file;
      };
      "vault_secret_id" = {
        sopsFile = cfg.secret_file;
      };
    };
  };
}
