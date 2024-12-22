{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  # Linux kernel

  # Enable networking
  # networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
  systemd.network = {
    enable = true;

    networks."10-wan" = {
      matchConfig.Name = "enp1s0";
      networkConfig.DHCP = "ipv4";
      address = [
        "2a01:4ff:1f0:ad0a::1/64"
      ];
      routes = [
        {
          routeConfig.Gateway = "fe80::1";
        }
      ];
    };
  };

  # personal modules
  justinrubek = {
    tailscale = {
      enable = true;
      autoconnect.enable = true;
    };

    haproxy = {
      enable = true;
      ssl.enable = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
