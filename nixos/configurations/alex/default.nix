{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
  ];

  services.justinrubek.postgresql = {
    enable = true;
    package = inputs.nix-postgres.packages.${pkgs.system}."psql_15/bin";
    port = 5435;

    ensureDatabases = ["lockpad" "annapurna" "nix-cache"];
    ensureUsers = [
      {
        name = "annapurna";
        ensureDBOwnership = true;
      }
      {
        name = "nix-cache";
        ensureDBOwnership = true;
      }
    ];

    identMap = ''
      superuser_map justin postgres
      superuser_map postgres postgres
      superuser_map      /^(.*)$   \1
    '';
    authentication = ''
      local all all peer map=superuser_map
      host all all 100.64.0.0/10 scram-sha-256
    '';
    enableTCPIP = true;
  };

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

  # personal modules
  justinrubek = {
    tailscale = {
      enable = true;
      autoconnect.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    justin = {
      isNormalUser = true;
      description = "Justin";
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1Uj62/yt8juK3rSfrVuX/Ut+xzw1Z75KZS/7fOLm6l justin@eunomia"
      ];
    };
  };

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    inputs.nix-postgres.packages.${pkgs.system}."psql_15/bin"
  ];

  # services.openssh = {
  #   enable = true;
  #   permitRootLogin = "no";
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  networking.firewall.interfaces.${config.services.tailscale.interfaceName} = {
    allowedTCPPorts = [
      config.services.justinrubek.postgresql.port
    ];
  };

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
