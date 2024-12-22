{
  resource = {
    vault_policy = {
      etc_member = {
        name = "etcd-member";
        policy = ''
          path "cluster/pki/etcd/issue/member"
          {
            capabilities = ["create", "update"]
          }
        '';
      };
      kube_apiserver = {
        name = "kube-apiserver";
        policy = ''
          path "cluster/pki/k8s/issue/member"
          {
            capabilities = ["create", "update"]
          }
        '';
      };
    };
    vault_approle_auth_backend_role = {
      "cluster-controller" = {
        backend = ''''${vault_auth_backend.approle.path}'';
        role_name = "cluster-controller";
        token_policies = ["etcd-member" "kube-apiserver"];
      };
      "etcd-member" = {
        backend = ''''${vault_auth_backend.approle.path}'';
        role_name = "etcd-member";
        token_policies = ["etcd-member"];
      };
      "kube-apiserver" = {
        backend = ''''${vault_auth_backend.approle.path}'';
        role_name = "k8s-apiserver";
        token_policies = ["kube-apiserver"];
      };
    };

    vault_mount = {
      "pki-etcd" = {
        path = "cluster/pki/etcd";
        type = "pki";
      };
      "pki-k8s" = {
        path = "cluster/pki/k8s";
        type = "pki";
      };
    };

    vault_pki_secret_backend_role = {
      "etcd-member" = {
        allow_any_name = true;
        backend = ''''${vault_mount.pki-etcd.path}'';
        name = "member";
      };
      "kubelet" = {
        allow_bare_domains = true;
        allow_subdomains = false;
        allowed_domains = ["kubelet"];
        backend = ''''${vault_mount.pki-k8s.path}'';
        name = "member";
      };
    };
    vault_pki_secret_backend_root_cert = {
      "etcd" = {
        backend = ''''${vault_mount.pki-etcd.path}'';
        common_name = "cluster/pki/etcd";
        key_type = "rsa";
        ttl = 315360000;
        type = "internal";
      };
      "k8s" = {
        backend = ''''${vault_mount.pki-k8s.path}'';
        common_name = "cluster/pki/k8s";
        key_type = "rsa";
        ttl = 315360000;
        type = "internal";
      };
    };
  };
}
