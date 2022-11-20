# Nutanix CSI Driver installation with CAPX

The Nutanix CSI driver is fully supported on CAPI/CAPX deployed clusters where all the nodes meet the [Nutanix CSI driver prerequisites](#capi-workload-cluster-prerequisites-for-nutanix-csi-driver).

There are three methods to install the Nutanix CSI driver on a CAPI/CAPX cluster:

- Helm
- ClusterResourceSet
- CAPX Flavor

For more information, check the next sections.

## CAPI Workload cluster prerequisites for the Nutanix CSI Driver

Kubernetes workers need the following prerequisites to use the Nutanix CSI Drivers:

- iSCSI initiator package (for Volumes based block storage)
- NFS client package (for Files based storage)

These packages may already be present in the image you use with your infrastructure provider or you can also rely on your bootstrap provider to install them. More info is available in the [Prerequisites docs](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:csi-csi-plugin-prerequisites-r.html){target=_blank}.

The package names and installation method will also vary depending on the operating system you plan to use.

In the example below, `kubeadm` bootstrap provider is used to deploy these packages on top of an Ubuntu 20.04 image. The `kubeadm` bootstrap provider allows defining `preKubeadmCommands` that will be launched before Kubernetes cluster creation. These `preKubeadmCommands` can be defined both in `KubeadmControlPlane` for master nodes and in `KubeadmConfigTemplate` for worker nodes.

In the example with an Ubuntu 20.04 image, both `KubeadmControlPlane` and `KubeadmConfigTemplate` must be modified as in the example below:

```yaml
spec:
  template:
    spec:
      # .......
      preKubeadmCommands:
      - echo "before kubeadm call" > /var/log/prekubeadm.log
      - apt update
      - apt install -y nfs-common open-iscsi
      - systemctl enable --now iscsid
```
## Install the Nutanix CSI Driver with Helm

A recent [Helm](https://helm.sh){target=_blank} version is needed (tested with Helm v3.10.1).

The example below must be applied on a ready workload cluster. The workload cluster's kubeconfig can be retrieved and used to connect with the following command:

```shell
clusterctl get kubeconfig $CLUSTER_NAME -n $CLUSTER_NAMESPACE > $CLUSTER_NAME-KUBECONFIG
export KUBECONFIG=$(pwd)/$CLUSTER_NAME-KUBECONFIG
```

Once connected to the cluster, first follow the [CSI documentation](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:csi-csi-driver-install-t.html){target=_blank}. 

Next, install the [nutanix-csi-snapshot](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-snapshot){target=_blank} chart followed by the [nutanix-csi-storage](https://github.com/nutanix/helm/tree/master/charts/nutanix-csi-storage){target=_blank} chart.

See an example below:

```shell
#Add the official Nutanix Helm repo and get the latest update
helm repo add nutanix https://nutanix.github.io/helm/
helm repo update

# Install the nutanix-csi-snapshot chart
helm install nutanix-csi-snapshot nutanix/nutanix-csi-snapshot -n ntnx-system --create-namespace

# Install the nutanix-csi-storage chart
helm install nutanix-storage nutanix/nutanix-csi-storage -n ntnx-system  --set createSecret=false
```

!!! warning
    For correct Nutanix CSI driver deployment, a fully functional CNI deployment must be present.

## Install the Nutanix CSI Driver with `ClusterResourceSet`

The `ClusterResourceSet` feature was introduced to automatically apply a set of resources (such as CNI/CSI) defined by administrators to matching created/existing workload clusters.

### Enabling the `ClusterResourceSet` feature

At the time of writing, `ClusterResourceSet` is an experimental feature that must be enabled during the initialization of a management cluster with the `EXP_CLUSTER_RESOURCE_SET` feature gate.

To do this, add `EXP_CLUSTER_RESOURCE_SET: "true"` in the `clusterctl` configuration file or just `export EXP_CLUSTER_RESOURCE_SET=true` before initializing the management cluster with `clusterctl init`.

If the management cluster is already initialized, the `ClusterResourceSet` can be enabled by changing the configuration of the `capi-controller-manager` deployment in the `capi-system` namespace.

  ```shell
  kubectl edit deployment -n capi-system capi-controller-manager
  ```

Locate the section below:

```yaml
  - args:
    - --leader-elect
    - --metrics-bind-addr=localhost:8080
    - --feature-gates=MachinePool=false,ClusterResourceSet=true,ClusterTopology=false
```

Then replace `ClusterResourceSet=false` with `ClusterResourceSet=true`.

!!! note
    Editing the `deployment` resource will cause Kubernetes to automatically start new versions of the containers with the feature enabled.



### Prepare the Nutanix CSI `ClusterResourceSet`

#### Create the `ConfigMap` for the CNI Plugin

First, create a `ConfigMap` that contains a YAML manifest with all resources to install the Nutanix CSI driver.

Since the Nutanix CSI Driver is provided as a Helm chart, use `helm` to extract it before creating the `ConfigMap`. See an example below:

```shell
helm repo add nutanix https://nutanix.github.io/helm/
helm repo update

kubectl create ns ntnx-system --dry-run=client -o yaml > nutanix-csi-namespace.yaml
helm template nutanix-csi-snapshot nutanix/nutanix-csi-snapshot -n ntnx-system > nutanix-csi-snapshot.yaml
helm template nutanix-csi-snapshot nutanix/nutanix-csi-storage -n ntnx-system > nutanix-csi-storage.yaml

kubectl create configmap nutanix-csi-crs --from-file=nutanix-csi-namespace.yaml --from-file=nutanix-csi-snapshot.yaml --from-file=nutanix-csi-storage.yaml
```

#### Create the `ClusterResourceSet`

Next, create the `ClusterResourceSet` resource that will map the `ConfigMap` defined above to clusters using a `clusterSelector`.

The `ClusterResourceSet` needs to be created inside the management cluster. See an example below:

```yaml
---
apiVersion: addons.cluster.x-k8s.io/v1alpha3
kind: ClusterResourceSet
metadata:
  name: nutanix-csi-crs
spec:
  clusterSelector:
    matchLabels:
      csi: nutanix 
  resources:
  - kind: ConfigMap
    name: nutanix-csi-crs
```

The `clusterSelector` field controls how Cluster API will match this `ClusterResourceSet` on one or more workload clusters. In the example scenario, the `matchLabels` approach is being used where the `ClusterResourceSet` will be applied to all workload clusters having the `csi: nutanix` label present. If the label isn't present, the `ClusterResourceSet` won't apply to that workload cluster.

The `resources` field references the `ConfigMap` created above, which contains the manifests for installing the Nutanix CSI driver.

#### Assign the `ClusterResourceSet` to a workload cluster

Assign this `ClusterResourceSet` to the workload cluster by adding the correct label to the `Cluster` resource.

This can be done before workload cluster creation by editing the output of the `clusterctl generate cluster` command or by modifying an already deployed workload cluster.

In both cases, `Cluster` resources should look like this:

```yaml
apiVersion: cluster.x-k8s.io/v1beta1
kind: Cluster
metadata:
  name: workload-cluster-name
  namespace: workload-cluster-namespace
  labels:
    csi: nutanix
# ...
```

!!! warning
    For correct Nutanix CSI driver deployment, a fully functional CNI deployment must be present.

## Install the Nutanix CSI Driver with a CAPX flavor

The CAPX provider can utilize a flavor to automatically deploy the Nutanix CSI using a `ClusterResourceSet`.

### Prerequisites

The following requirements must be met:

- The operating system must meet the [Nutanix CSI OS prerequisites](#capi-workload-cluster-prerequisites-for-nutanix-csi-driver).
- The Management cluster must be installed with the [`CLUSTER_RESOURCE_SET` feature gate](#enabling-clusterresourceset-feature).

### Installation

Specify the `csi` flavor during workload cluster creation. See an example below:

```shell
clusterctl generate cluster my-cluster -f csi
```

Additional environment variables are required:

- `WEBHOOK_CA`: Base64 encoded CA certificate used to sign the webhook certificate
- `WEBHOOK_CERT`: Base64 certificate for the webhook validation component
- `WEBHOOK_KEY`: Base64 key for the webhook validation component

The three components referenced above can be automatically created and referenced using [this script](https://github.com/nutanix-cloud-native/cluster-api-provider-nutanix/blob/main/scripts/gen-self-cert.sh){target=_blank}:

```
source scripts/gen-self-cert.sh
```

The certificate must reference the following names:

- csi-snapshot-webhook
- csi-snapshot-webhook.ntnx-sytem
- csi-snapshot-webhook.ntnx-sytem.svc

!!! warning
    For correct Nutanix CSI driver deployment, a fully functional CNI deployment must be present.

## Nutanix CSI Driver Configuration

After the driver is installed, it must be configured for use by minimally defining a `Secret` and `StorageClass`.

This can be done manually in the workload clusters or by using a `ClusterResourceSet` in the management cluster as explained above.

See the Managing Storage section of [CSI Driver documentation](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:csi-csi-plugin-storage-c.html){target=_blank} on the Nutanix Portal for more configuration information. 
