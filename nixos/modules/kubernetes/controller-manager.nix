{
  config,
  lib,
  ...
}: let
  top = config.justinrubek.kubernetes;
  cfg = top.controller-manager;

  all_ips = lib.attrsets.attrValues (lib.attrsets.mapAttrs (name: value: value.ip) top.nodes);
  etcd_ips = lib.attrsets.attrValues (lib.attrsets.mapAttrs (name: value: "${value.ip}:2379") top.nodes);
  internal_ip = "${top.nodes.${config.networking.hostName}.ip}";
  systemd_unit = "kube-controller-manager";
  systemd_user = config.systemd.services.${systemd_unit}.serviceConfig.User;

  mkCertSecret = {
    subdir,
    mount_path,
    common_name,
    ip_sans ? null,
    systemd_user,
    uri_sans ? null,
  }: let
    ipSans =
      if (ip_sans != null)
      then (lib.strings.concatStringsSep "," ip_sans)
      else null;
    uriSans =
      if (uri_sans != null)
      then (lib.strings.concatStringsSep "," uri_sans)
      else null;
  in {
    changeAction = "reload";
    perms = "0400";
    template = ''
      {{ with pkiCert "${mount_path}" "common_name=${common_name}" ${lib.optionalString (ipSans != null) ''"ip_sans=${ipSans}"''} ${lib.optionalString (uriSans != null) ''"uri_sans=${uriSans}"''} "ttl=420h" }}
      {{ .CA }}
      {{ .Cert }}
      {{ .Key }}
      {{ .CA | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/${subdir}/ca" "${systemd_user}" "${systemd_user}" "0400" }}
      {{ .Cert | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/${subdir}/cert" "${systemd_user}" "${systemd_user}" "0400" }}
      {{ .Key | writeToFile "${config.detsys.vaultAgent.secretFilesRoot}cert/${subdir}/key" "${systemd_user}" "${systemd_user}" "0400" }}
      {{ end }}
    '';
  };

  fileSecrets = {
    controller-manager-pki = mkCertSecret {
      inherit systemd_user;
      subdir = "controller-manager";
      mount_path = "cluster/pki/k8s/issue/member";
      common_name = "system:kube-controller-manager";
    };
    service-account-pki = mkCertSecret {
      inherit systemd_user;
      subdir = "kube-service-account";
      mount_path = "cluster/pki/k8s/issue/member";
      common_name = "service-accounts";
    };
  };

  certs = {
    controller-manager = {
      ca = "${config.detsys.vaultAgent.secretFilesRoot}cert/controller-manager/ca";
      cert = "${config.detsys.vaultAgent.secretFilesRoot}cert/controller-manager/cert";
      key = "${config.detsys.vaultAgent.secretFilesRoot}cert/controller-manager/key";
    };
    service-account = {
      ca = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/ca";
      cert = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/cert";
      key = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/key";
    };
  };
in {
  options = {
    justinrubek.kubernetes.controller-manager = {
      enable = lib.mkEnableOption (lib.mdDoc "kubernetes controller-manager");
    };
  };

  config = lib.mkIf cfg.enable {
    detsys.vaultAgent.systemd.services.${systemd_unit} = {
      enable = true;
      secretFiles = {
        defaultChangeAction = "restart";
        files = {
          inherit (fileSecrets) controller-manager-pki service-account-pki;
        };
      };
    };
    services.kubernetes.controllerManager = {
      enable = true;
      clusterCidr = "192.168.5.0/24";
      kubeconfig = {
        keyFile = certs.controller-manager.key;
        certFile = certs.controller-manager.cert;
        caFile = certs.controller-manager.ca;
        server = "https://127.0.0.1:6443";
      };
      rootCaFile = certs.controller-manager.ca;
      serviceAccountKeyFile = certs.service-account.key;
      tlsCertFile = certs.controller-manager.cert;
      tlsKeyFile = certs.controller-manager.key;
      verbosity = 2;
    };
  };
}
