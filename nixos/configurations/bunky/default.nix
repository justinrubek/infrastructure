{
  config,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # personal modules
  justinrubek = {
    nomad.enable = false;

    vault = {
      enable = true;

      # retry_join = [
      #   "http://pyxis:8200"
      #   "http://ceylon:8200"
      # ];
    };

    consul = {
      enable = false;

      retry_join = [
        "pyxis"
        "ceylon"
      ];

      acl.enable = true;
    };

    tailscale = {
      enable = true;
      autoconnect.enable = true;
    };
  };

  services = {
    etcd = {
      enable = true;
      initialCluster = ["bunky=http://100.96.238.57:2380" "ceylon=http://100.101.20.26:2380" "pyxis=http://100.100.135.61:2380"];
      # initialClusterState = "existing";
      listenClientUrls = ["http://100.96.238.57:2379" "http://127.0.0.1:2379"];
      listenPeerUrls = ["http://100.96.238.57:2380"];
    };
    # rpc.statd fix
    nfs.server.enable = true;
  };

  networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
    allowedTCPPorts = [
      # etcd
      2379
      2380
    ];
    allowedTCPPortRanges = [];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
