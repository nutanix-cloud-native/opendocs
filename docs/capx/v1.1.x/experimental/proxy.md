# Proxy configuration

!!! warning
        The scenario and features described on this page are experimental and should not be deployed in production environments.

CAPX can be configured to use a proxy to connect to external networks. This proxy configuration needs to be applied to control plane and worker nodes. 

Follow the steps below to configure a CAPX cluster to use a proxy.

## Steps
1. Generate a `cluster.yaml` file with the required CAPX cluster configuration. Refer to the [Getting Started](../getting_started.md){target=_blank} page for more information on how to generate a `cluster.yaml` file. Do not apply the `cluster.yaml` file. 
2. Edit the `cluster.yaml` file and modify the following resources as shown in the [example](#example) below to add the proxy configuration.
    1. `KubeadmControlPlane`: 
        * Add the proxy configuration to the `spec.kubeadmConfigSpec.files` list. Do not modify other items in the list.
        * Add `systemctl` commands to apply the proxy config in `spec.kubeadmConfigSpec.preKubeadmCommands`. Do not modify other items in the list.
    2. `KubeadmConfigTemplate`: 
        * Add the proxy configuration to the `spec.template.spec.files` list. Do not modify other items in the list.
        * Add `systemctl` commands to apply the proxy config in `spec.template.spec.preKubeadmCommands`. Do not modify other items in the list.
4. Apply the `cluster.yaml` file 

## Example 

```YAML
---
# controlplane proxy settings
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    files:
      - content: |
          [Service]
          Environment="HTTP_PROXY=<my-http-proxy-configuration>"
          Environment="HTTPS_PROXY=<my-https-proxy-configuration>"
          Environment="NO_PROXY=<my-no-proxy-configuration>"
        owner: root:root
        path: /etc/systemd/system/containerd.service.d/http-proxy.conf
      ...
    preKubeadmCommands:
      - sudo systemctl daemon-reload
      - sudo systemctl restart containerd
      ...
---
# worker proxy settings
kind: KubeadmConfigTemplate
spec:
  template:
    spec:
      files:
        - content: |
            [Service]
            Environment="HTTP_PROXY=<my-http-proxy-configuration>"
            Environment="HTTPS_PROXY=<my-https-proxy-configuration>"
            Environment="NO_PROXY=<my-no-proxy-configuration>"
          owner: root:root
          path: /etc/systemd/system/containerd.service.d/http-proxy.conf
        ...
      preKubeadmCommands:
        - sudo systemctl daemon-reload
        - sudo systemctl restart containerd
      ...
```

