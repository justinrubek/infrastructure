{
  config,
  inputs,
  lib,
  self,
  ...
}: {
  imports = [
    inputs.nixos-vault-module.nixosModule
    ./hardware.nix
  ];

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  detsys.vaultAgent.systemd.services."etcd" = {
    enable = true;
    secretFiles = {
      defaultChangeAction = "restart";
      files = {
        pki = {
          changeAction = "reload";
          perms = "0440";
          template = ''
            {{ with pkiCert "cluster/pki/etcd/issue/member" "common_name=etcd-server" "ip_sans=100.96.238.57,127.0.0.1" "ttl=420h"}}
            {{ .Key }}
            {{ .CA }}
            {{ .Cert }}
            {{ .Key | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/key.pem" "etcd" "etcd" "0400" }}
            {{ .CA | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/ca.pem" "etcd" "etcd" "0400" }}
            {{ .Cert | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/cert.pem" "etcd" "etcd" "0400" }}
            {{ end }}
          '';
        };
      };
    };
  };

  # personal modules
  justinrubek = {
    nomad.enable = false;

    vault = {
      enable = true;
      reader = {
        enable = true;
        secret_file = "${self}/secrets/nodes/controller0.yaml";
      };

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
      clientCertAuth = true;
      initialCluster = ["bunky=https://100.96.238.57:2380" "ceylon=https://100.101.20.26:2380" "pyxis=https://100.100.135.61:2380"];
      # initialClusterState = "existing";
      listenClientUrls = ["https://100.96.238.57:2379" "https://127.0.0.1:2379"];
      listenPeerUrls = ["https://100.96.238.57:2380"];
      certFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/cert.pem";
      peerTrustedCaFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/ca.pem";
      keyFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/key.pem";
      peerKeyFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/key.pem";
      peerClientCertAuth = true;
      peerCertFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/cert.pem";
      trustedCaFile = "${config.detsys.vaultAgent.secretFilesRoot}cert/ca.pem";
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
