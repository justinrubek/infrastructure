{
  config,
  lib,
  ...
}: let
  top = config.justinrubek.kubernetes;
  cfg = top.apiserver;

  all_ips = lib.attrsets.attrValues (lib.attrsets.mapAttrs (name: value: value.ip) top.nodes);
  internal_ip = "${top.nodes.${config.networking.hostName}.ip}";
  systemd_unit = "kube-apiserver";
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
      {{ with pkiCert "${mount_path}" "common_name=${common_name}" ${lib.optionalString (ipSans != null) "ip_sans=${ipSans}"} ${lib.optionalString (uriSans != null) "uri_sans=${uriSans}"} "ttl=420h" }}
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
    etcd-pki = mkCertSecret {
      inherit systemd_user;
      subdir = "etcd";
      mount_path = "cluster/pki/etcd/issue/member";
      common_name = "etcd-server";
      ip_sans = [
        internal_ip
        "127.0.0.1"
      ];
    };
    apiserver-pki = mkCertSecret {
      inherit systemd_user;
      subdir = "kube-apiserver";
      mount_path = "cluster/pki/k8s/issue/member";
      common_name = "kube-apiserver";
      ip_sans =
        [
          "10.96.0.1"
          "127.0.0.1"
        ]
        ++ all_ips;
      uri_sans = [
        "kubernetes"
        "kubernetes.default"
        "kubernetes.default.svc"
        "kubernetes.default.svc.cluster.local"
      ];
    };
    service-account-pki = mkCertSecret {
      inherit systemd_user;
      subdir = "kube-service-account";
      mount_path = "cluster/pki/k8s/issue/member";
      common_name = "service-accounts";
    };
  };

  certs = {
    etcd = {
      ca = "${config.detsys.vaultAgent.secretFilesRoot}cert/etcd/ca";
      cert = "${config.detsys.vaultAgent.secretFilesRoot}cert/etcd/cert";
      key = "${config.detsys.vaultAgent.secretFilesRoot}cert/etcd/key";
    };
    apiserver = {
      ca = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-apiserver/ca";
      cert = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-apiserver/cert";
      key = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-apiserver/key";
    };
    service-account = {
      ca = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/ca";
      cert = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/cert";
      key = "${config.detsys.vaultAgent.secretFilesRoot}cert/kube-service-account/key";
    };
  };
in {
  options = {
    justinrubek.kubernetes.apiserver = {
      enable = lib.mkEnableOption (lib.mdDoc "kubernetes api server");
    };
  };

  config = lib.mkIf cfg.enable {
    detsys.vaultAgent.systemd.services.${systemd_unit} = {
      enable = true;
      secretFiles = {
        defaultChangeAction = "restart";
        files = {
          inherit (fileSecrets) etcd-pki apiserver-pki service-account-pki;
        };
      };
    };
    services.kubernetes.apiserver = {
      enable = true;
      advertiseAddress = internal_ip;
      allowPrivileged = true;
      clientCaFile = certs.apiserver.ca;
      enableAdmissionPlugins = ["NodeRestriction" "ServiceAccount"];
      etcd = {
        servers = all_ips;
        caFile = certs.etcd.ca;
        certFile = certs.etcd.cert;
        keyFile = certs.etcd.key;
      };
      extraOpts = ''
        --apiserver-count=3 \
        --audit-log-maxage=30 \
        --audit-log-maxbackup=3 \
        --audit-log-maxsize=100 \
        --audit-log-path=/var/log/audit.log \
        --enable-swagger-ui=true \
        --enable-bootstrap-token-auth=true \
        --event-ttl=1h \
        --kubelet-https=true \
        --service-node-port-range=30000-32767
      '';
      kubeletClientCaFile = certs.apiserver.ca;
      kubeletClientCertFile = certs.apiserver.cert;
      kubeletClientKeyFile = certs.apiserver.key;
      runtimeConfig = "api/all";
      serviceAccountKeyFile = certs.service-account.key;
      serviceAccountSigningKeyFile = certs.service-account.key;
      serviceClusterIpRange = "10.96.0.0/24";
      tlsCertFile = certs.apiserver.cert;
      tlsKeyFile = certs.apiserver.key;
      verbosity = 2;
    };
  };
}
