{
  inputs = {
    config-parts = {
      url = "github:justinrubek/config-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    factorio-server = {
      url = "github:justinrubek/factorio-server";
      inputs = {
        fenix.follows = "fenix";
        nixpkgs.follows = "nixpkgs";
      };
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    hashicorp_nixpkgs.url = "github:nixos/nixpkgs/f91ee3065de91a3531329a674a45ddcb3467a650";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-config = {
      url = "github:justinrubek/neovim-config";
      inputs = {
        fenix.follows = "fenix";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-nomad = {
      url = "github:tristanpemble/nix-nomad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-postgres = {
      url = "github:justinrubek/nix-postgres";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-vault-module = {
      url = "github:justinrubek/nixos-vault-service";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    terranix = {
      url = "github:justinrubek/terranix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thoenix = {
      url = "github:justinrubek/thoenix";
    };
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [
        inputs.thoenix.flakeModule
        inputs.thoenix.customOutputModule
        ./flake-parts/shells.nix
        ./flake-parts/ci.nix
        ./containers
        ./packages

        ./modules

        ./nixos/configurations
        ./nixos/modules

        ./home/configurations
        ./home/modules

        ./deploy

        ./flake-parts/terraform.nix
        ./flake-parts/terraformConfiguration.nix
        ./terraform/modules

        ./nomad

        ./flake-parts/pre-commit.nix
        ./flake-parts/formatting.nix
        inputs.pre-commit-hooks.flakeModule
      ];
    };
}
