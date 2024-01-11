# CAPX v1.3.x Upgrade Procedure

Starting from CAPX v1.3.0, it is required for all CAPX-managed Kubernetes clusters to use the Nutanix Cloud Controller Manager (CCM). 

Before upgrading CAPX instances to v1.3.0 or later, it is required to follow the [steps](#steps) detailed below for each of the CAPX-managed Kubernetes clusters that don't use Nutanix CCM.


## Steps

This procedure uses [Cluster Resource Set (CRS)](https://cluster-api.sigs.k8s.io/tasks/experimental-features/cluster-resource-set){target=_blank} to install Nutanix CCM but it can also be installed using the [Nutanix CCM Helm chart](https://artifacthub.io/packages/helm/nutanix/nutanix-cloud-provider){target=_blank}. 

Perform following steps for each of the CAPX-managed Kubernetes clusters that are not configured to use Nutanix CCM:

1. Add the `cloud-provider: external` configuration in the `KubeadmConfigTemplate` resources:
  ```YAML
  apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
  kind: KubeadmConfigTemplate
  spec:
    template:
      spec:
        joinConfiguration:
          nodeRegistration:
            kubeletExtraArgs:
              cloud-provider: external
  ```
2. Add the `cloud-provider: external` configuration in the `KubeadmControlPlane` resource:
```YAML
---
apiVersion: bootstrap.cluster.x-k8s.io/v1beta1
kind: KubeadmConfigTemplate
spec:
  template:
    spec:
      joinConfiguration:
        nodeRegistration:
          kubeletExtraArgs:
            cloud-provider: external
---
apiVersion: controlplane.cluster.x-k8s.io/v1beta1
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        extraArgs:
          cloud-provider: external
      controllerManager:
        extraArgs:
          cloud-provider: external
    initConfiguration:
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: external
    joinConfiguration:
      nodeRegistration:
        kubeletExtraArgs:
          cloud-provider: external
```
3. Add the Nutanix CCM CRS resources:

    - [nutanix-ccm-crs.yaml](https://github.com/nutanix-cloud-native/cluster-api-provider-nutanix/blob/v1.3.0/templates/base/nutanix-ccm-crs.yaml){target=_blank}
    - [nutanix-ccm-secret.yaml](https://github.com/nutanix-cloud-native/cluster-api-provider-nutanix/blob/v1.3.0/templates/base/nutanix-ccm-secret.yaml)
    - [nutanix-ccm.yaml](https://github.com/nutanix-cloud-native/cluster-api-provider-nutanix/blob/v1.3.0/templates/base/nutanix-ccm.yaml)

    Make sure to update each of the variables before applying the `YAML` files.

4. Add the `ccm: nutanix` label to the `Cluster` resource:
  ```YAML
  apiVersion: cluster.x-k8s.io/v1beta1
  kind: Cluster
  metadata:
    labels:
      ccm: nutanix
  ```
5. Verify if the Nutanix CCM pod is up and running: 
```
kubectl get pod -A -l k8s-app=nutanix-cloud-controller-manager
```
6. Trigger a new rollout of the Kubernetes nodes by performing a Kubernetes upgrade or by using `clusterctl alpha rollout restart`. See the [clusterctl alpha rollout](https://cluster-api.sigs.k8s.io/clusterctl/commands/alpha-rollout#restart){target=_blank} for more information.
7. Upgrade CAPX to v1.3.0 by following the [clusterctl upgrade](https://cluster-api.sigs.k8s.io/clusterctl/commands/upgrade.html?highlight=clusterctl%20upgrade%20pla#clusterctl-upgrade){target=_blank} documentation