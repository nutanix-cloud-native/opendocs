# Registry Mirror configuration

!!! warning
        The scenario and features described on this page are experimental. It's important to note that they have not been fully validated.

CAPX can be configured to use a private registry to act as a mirror of an external public registry. This registry mirror configuration needs to be applied to control plane and worker nodes. 

Follow the steps below to configure a CAPX cluster to use a registry mirror.

## Steps
1. Generate a `cluster.yaml` file with the required CAPX cluster configuration. Refer to the [Getting Started](../getting_started.md){target=_blank} page for more information on how to generate a `cluster.yaml` file. Do not apply the `cluster.yaml` file. 
2. Edit the `cluster.yaml` file and modify the following resources as shown in the [example](#example) below to add the proxy configuration.
    1. `KubeadmControlPlane`: 
        * Add the registry mirror configuration to the `spec.kubeadmConfigSpec.files` list. Do not modify other items in the list.
        * Update `/etc/containerd/config.toml` commands to apply the registry mirror config in `spec.kubeadmConfigSpec.preKubeadmCommands`. Do not modify other items in the list.
    2. `KubeadmConfigTemplate`: 
        * Add the registry mirror configuration to the `spec.template.spec.files` list. Do not modify other items in the list.
        * Update `/etc/containerd/config.toml` commands to apply the registry mirror config in `spec.template.spec.preKubeadmCommands`. Do not modify other items in the list.
4. Apply the `cluster.yaml` file 

## Example 

This example will configure a registry mirror for the following namespace:

* registry.k8s.io
* ghcr.io
* quay.io

and redirect them to corresponding projects of the `<mirror>` registry.

```YAML
---
# controlplane proxy settings
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    files:
      - content: |
          [host."https://<mirror>/v2/registry.k8s.io"]
            capabilities = ["pull", "resolve"]
            skip_verify = false
            override_path = true
        owner: root:root
        path: /etc/containerd/certs.d/registry.k8s.io/hosts.toml
      - content: |
          [host."https://<mirror>/v2/ghcr.io"]
            capabilities = ["pull", "resolve"]
            skip_verify = false
            override_path = true
        owner: root:root
        path: /etc/containerd/certs.d/ghcr.io/hosts.toml
      - content: |
          [host."https://<mirror>/v2/quay.io"]
            capabilities = ["pull", "resolve"]
            skip_verify = false
            override_path = true
        owner: root:root
        path: /etc/containerd/certs.d/quay.io/hosts.toml
      ...
    preKubeadmCommands:
      - echo '\n[plugins."io.containerd.grpc.v1.cri".registry]\n  config_path = "/etc/containerd/certs.d"' >> /etc/containerd/config.toml
      ...
---
# worker proxy settings
kind: KubeadmConfigTemplate
spec:
  template:
    spec:
      files:
        - content: |
            [host."https://<mirror>/v2/registry.k8s.io"]
              capabilities = ["pull", "resolve"]
              skip_verify = false
              override_path = true
          owner: root:root
          path: /etc/containerd/certs.d/registry.k8s.io/hosts.toml
        - content: |
            [host."https://<mirror>/v2/ghcr.io"]
              capabilities = ["pull", "resolve"]
              skip_verify = false
              override_path = true
          owner: root:root
          path: /etc/containerd/certs.d/ghcr.io/hosts.toml
        - content: |
            [host."https://<mirror>/v2/quay.io"]
              capabilities = ["pull", "resolve"]
              skip_verify = false
              override_path = true
          owner: root:root
          path: /etc/containerd/certs.d/quay.io/hosts.toml
        ...
      preKubeadmCommands:
        - echo '\n[plugins."io.containerd.grpc.v1.cri".registry]\n  config_path = "/etc/containerd/certs.d"' >> /etc/containerd/config.toml
      ...
```

