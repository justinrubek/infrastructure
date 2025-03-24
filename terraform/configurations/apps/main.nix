{
  # configure hcloud
  provider = {
    nomad = {};
  };

  justinrubek.nomadVolumes = {
    valheim_data = {
      enable = true;

      server = "alex";
      path = "/var/nfs/valheim/data";
    };

    valheim_config = {
      enable = true;

      server = "alex";
      path = "/var/nfs/valheim/config";
    };

    jellyfin_cache = {
      enable = true;

      server = "alex";
      path = "/var/nfs/jellyfin/cache";
    };

    jellyfin_config = {
      enable = true;

      server = "alex";
      path = "/var/nfs/jellyfin/config";
    };

    jellyfin_media = {
      enable = true;

      server = "alex";
      path = "/var/nfs/jellyfin/media";
    };

    ### paperless-ngx
    ### https://github.com/paperless-ngx/paperless-ngx/blob/800e842ab304ce2fcb1c126d491dac0770ad66ff/Dockerfile#L255

    paperless_consume = {
      enable = true;

      server = "alex";
      path = "/var/nfs/paperless/consume";
    };

    paperless_data = {
      enable = true;

      server = "alex";
      path = "/var/nfs/paperless/data";
    };

    paperless_media = {
      enable = true;

      server = "alex";
      path = "/var/nfs/paperless/media";
    };

    ### conduit matrix homeserver

    conduit_data = {
      enable = true;

      server = "alex";
      path = "/var/nfs/conduit/data";
    };

    factorio_data = {
      enable = true;

      server = "alex";
      path = "/var/nfs/factorio/data";
    };

    nix_cache_postgres = {
      enable = true;

      server = "alex";
      path = "/var/nfs/nix-cache/postgres";
    };

    lockpad_postgres = {
      enable = true;

      server = "alex";
      path = "/var/nfs/lockpad/postgres";
    };
  };
}
