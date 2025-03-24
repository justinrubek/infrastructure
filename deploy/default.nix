{
  inputs,
  self,
  ...
}: let
  mkDeployNode = {
    hostname,
    address ? hostname,
  }: {
    hostname = address;
    profiles.system = {
      sshUser = "admin";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostname};
      user = "root";
    };
  };
in {
  flake.deploy = {
    nodes = {
      factorio = mkDeployNode {
        hostname = "factorio";
      };
    };
  };
}
