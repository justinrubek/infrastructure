{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    system,
    inputs',
    self',
    ...
  }: let
    hashicorp_pkgs = inputs.hashicorp_nixpkgs.legacyPackages.${system};
  in {
    packages = {
      inherit (inputs'.neovim-config.packages) neovim;

      nomad = hashicorp_pkgs.callPackage ./nomad {};
      vault-bin = hashicorp_pkgs.callPackage ./vault-bin {};
    };
  };
}
