{nomadJobs, ...}: let
  nomad_jobs = nomadJobs;
in {
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

  justinrubek.nomadJobs = {
    valheim = {
      enable = false;
      jobspec = "${nomad_jobs}/valheim.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.valheim_data" "resource.nomad_volume.valheim_config"];
      };
    };

    rubek_site = {
      enable = true;
      jobspec = "${nomad_jobs}/rubek_site.json";
    };

    rubek_site_nix = {
      enable = false;
      jobspec = "${nomad_jobs}/rubek_site_nix.json";
    };

    dummy_api_nix = {
      enable = false;
      jobspec = "${nomad_jobs}/dummy_api_nix.json";
    };

    storage_controller = {
      enable = true;
      jobspec = "${nomad_jobs}/storage_controller.json";
    };

    storage_node = {
      enable = true;
      jobspec = "${nomad_jobs}/storage_node.json";
    };

    jellyfin = {
      enable = false;
      jobspec = "${nomad_jobs}/jellyfin.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.jellyfin_cache" "resource.nomad_volume.jellyfin_config" "resource.nomad_volume.jellyfin_media"];
      };
    };

    paperless = {
      enable = false;
      jobspec = "${nomad_jobs}/paperless.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.paperless_consume" "resource.nomad_volume.paperless_data" "resource.nomad_volume.paperless_media"];
      };
    };

    postgres = {
      enable = false;
      jobspec = "${nomad_jobs}/postgres.json";
    };

    conduit = {
      enable = false;
      jobspec = "${nomad_jobs}/conduit.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.conduit_data"];
      };
    };

    factorio = {
      enable = false;
      jobspec = "${nomad_jobs}/factorio.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.factorio_data"];
      };
    };

    flake-builder = {
      enable = true;
      jobspec = "${nomad_jobs}/flake_builder.json";
    };

    nix-cache = {
      enable = true;
      jobspec = "${nomad_jobs}/nix_cache.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.nix_cache_postgres"];
      };
    };

    lockpad = {
      enable = false;
      jobspec = "${nomad_jobs}/lockpad.json";
      extraArgs = {
        depends_on = ["resource.nomad_volume.lockpad_postgres"];
      };
    };

    annapurna = {
      enable = false;
      jobspec = "${nomad_jobs}/annapurna.json";
    };
  };
}
