{
  flake.nixosModules = {
    cachix = ./cachix;
    nix = ./nix.nix;
    flake = ./flake.nix;

    containers = ./containers.nix;

    nomad = ./nomad;
    vault = ./vault;
    consul = ./consul;

    tailscale = ./tailscale;

    haproxy = ./haproxy;

    admin_ssh = ./admin_ssh.nix;

    "filesystem/zfs" = ./filesystem/zfs;

    "cloudhost/hetzner" = ./cloudhost/hetzner;

    postgres = ./data/postgres;
    vintagestory = ./vintagestory.nix;
  };
}
