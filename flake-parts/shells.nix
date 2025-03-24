{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    system,
    inputs',
    self',
    ...
  }: let
    hashicorp-pkgs = inputs.hashicorp_nixpkgs.legacyPackages.${system};
  in {
    devShells = {
      default = pkgs.mkShell rec {
        packages = with pkgs; [
          pkgs.openssl
          pkgs.openssl.dev

          alejandra
          pkgs.attic-client
          hcloud
          hashicorp-pkgs.packer
          inputs'.deploy-rs.packages.deploy-rs

          pkgs.age
          pkgs.ssh-to-age
          pkgs.sops

          inputs'.thoenix.packages.cli
          self'.packages.terraform

          inputs'.nix-postgres.packages."psql_15/bin"
        ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;

        shellHook = ''
          ${config.pre-commit.installationScript}
        '';
      };
    };
  };
}
