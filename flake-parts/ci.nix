_: {
  perSystem = {
    config,
    pkgs,
    system,
    inputs',
    self',
    ...
  }: let
    ciPackages = [
      pkgs.skopeo
    ];

    devShells = {
      ci = pkgs.mkShell rec {
        packages = ciPackages;

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
      };
    };
  in {
    inherit devShells;

    legacyPackages = {
      inherit ciPackages;
    };
  };
}
