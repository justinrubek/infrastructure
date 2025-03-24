_: let
  server_type = "cpx11";
  location = "hil";
  image = "\${data.hcloud_image.nixos_base.id}";

  public_net = {
    ipv4_enabled = true;
    ipv6_enabled = true;
  };
in {
  # configure hcloud
  provider = {
    minio = {
      minio_region = "fsn1";
      minio_ssl = true;
    };
  };

  data.hcloud_image.nixos_base = {
    id = "92487340";
  };

  resource = {
    hcloud_server = {
      factorio = {
        name = "factorio";

        server_type = "cpx31";
        inherit location image;
        inherit public_net;
      };
    };

    # minio_s3_bucket.nix_cache = {
    #   bucket = "rubek-nix-cache";
    #   acl = "private";
    # };
  };
}
