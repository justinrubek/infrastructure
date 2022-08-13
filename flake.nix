{
  description = "nixos configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    unixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unixpkgs";
    };

    nurpkgs = {
      url = github:nix-community/NUR;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:pta2002/nixvim";
  };

  outputs = {
    self,
    nixpkgs,
    nurpkgs,
    home-manager,
    flake-utils,
    flake-parts,
    pre-commit-hooks,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit self;} {
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        overlays = [
          inputs.neovim-nightly-overlay.overlay
        ];

        pkgs = import nixpkgs {
          inherit system;
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
          };
        };
      in rec {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [alejandra home-manager.packages.${system}.home-manager];
            inherit (pre-commit-check) shellHook;
          };
        };

        checks = {
          pre-commit = pre-commit-check;
        };
      };
      systems = flake-utils.lib.defaultSystems;
      flake = {
        lib = import ./lib inputs;

        nixosConfigurations = import ./nixos/configurations inputs;

        homeConfigurations = import ./home/configurations inputs;
      };
    };
}
