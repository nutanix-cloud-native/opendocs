# Getting Started

This is a guide on getting started with Cluster API Provider Nutanix Cloud Infrastructure (CAPX). To learn more about cluster API in more depth, check out the [Cluster API book](https://cluster-api.sigs.k8s.io/){target=_blank}.

For more information on how install the Nutanix CSI Driver on a CAPX cluster, visit [Nutanix CSI Driver installation with CAPX](./addons/install_csi_driver.md).

For more information on how CAPX handles credentials, visit [Credential Management](./credential_management.md).

For more information on the port requirements for CAPX, visit [Port Requirements](./port_requirements.md).

!!! note
    [Nutanix Cloud Controller Manager (CCM)](../../ccm/latest/overview.md) is a mandatory component starting from CAPX v1.3.0. Ensure all CAPX-managed Kubernetes clusters are configured to use Nutanix CCM before upgrading to v1.3.0 or later. See [CAPX v1.8.x Upgrade Procedure](./tasks/capx_v18x_upgrade_procedure.md).

## Production Workflow

### Build OS image for NutanixMachineTemplate resource
Cluster API Provider Nutanix Cloud Infrastructure (CAPX) uses the [Image Builder](https://image-builder.sigs.k8s.io/){target=_blank} project to build OS images used for the Nutanix machines. 

Follow the steps detailed in [Building CAPI Images for Nutanix Cloud Platform (NCP)](https://image-builder.sigs.k8s.io/capi/providers/nutanix.html#building-capi-images-for-nutanix-cloud-platform-ncp){target=_blank} to use Image Builder on the Nutanix Cloud Platform.

For a list of operating systems visit the OS image [Configuration](https://image-builder.sigs.k8s.io/capi/providers/nutanix.html#configuration){target=_blank} page.

### Prerequisites for using Cluster API Provider Nutanix Cloud Infrastructure
The [Cluster API installation](https://cluster-api.sigs.k8s.io/user/quick-start.html#installation){target=_blank} section provides an overview of all required prerequisites:

- [Common Prerequisites](https://cluster-api.sigs.k8s.io/user/quick-start.html#common-prerequisites){target=_blank}
- [Install and/or configure a Kubernetes cluster](https://cluster-api.sigs.k8s.io/user/quick-start.html#install-andor-configure-a-kubernetes-cluster){target=_blank}
- [Install clusterctl](https://cluster-api.sigs.k8s.io/user/quick-start.html#install-clusterctl){target=_blank}
- (Optional) [Enabling Feature Gates](https://cluster-api.sigs.k8s.io/user/quick-start.html#enabling-feature-gates){target=_blank}

Make sure these prerequisites have been met before moving to the [Configure and Install Cluster API Provider Nutanix Cloud Infrastructure](#configure-and-install-cluster-api-provider-nutanix-cloud-infrastructure) step.

### Configure and Install Cluster API Provider Nutanix Cloud Infrastructure
To initialize Cluster API Provider Nutanix Cloud Infrastructure, `clusterctl` requires the following variables, which should be set in either `~/.cluster-api/clusterctl.yaml` or as environment variables.
```
NUTANIX_ENDPOINT: ""    # IP or FQDN of Prism Central
NUTANIX_USER: ""        # Prism Central user
NUTANIX_PASSWORD: ""    # Prism Central password
NUTANIX_INSECURE: false # or true

KUBERNETES_VERSION: "v1.22.9"
WORKER_MACHINE_COUNT: 3
NUTANIX_SSH_AUTHORIZED_KEY: ""

NUTANIX_PRISM_ELEMENT_CLUSTER_NAME: ""
NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME: ""
NUTANIX_SUBNET_NAME: ""

EXP_CLUSTER_RESOURCE_SET: true # Required for Nutanix CCM installation
```

You can also see the required list of variables by running the following:
```
clusterctl generate cluster mycluster -i nutanix --list-variables           
Required Variables:
  - CONTROL_PLANE_ENDPOINT_IP
  - KUBERNETES_VERSION
  - NUTANIX_ENDPOINT
  - NUTANIX_MACHINE_TEMPLATE_IMAGE_NAME
  - NUTANIX_PASSWORD
  - NUTANIX_PRISM_ELEMENT_CLUSTER_NAME
  - NUTANIX_SSH_AUTHORIZED_KEY
  - NUTANIX_SUBNET_NAME
  - NUTANIX_USER

Optional Variables:
  - CONTROL_PLANE_ENDPOINT_PORT      (defaults to "6443")
  - CONTROL_PLANE_MACHINE_COUNT      (defaults to 1)
  - KUBEVIP_LB_ENABLE                (defaults to "false")
  - KUBEVIP_SVC_ENABLE               (defaults to "false")
  - NAMESPACE                        (defaults to current Namespace in the KubeConfig file)
  - NUTANIX_INSECURE                 (defaults to "false")
  - NUTANIX_MACHINE_BOOT_TYPE        (defaults to "legacy")
  - NUTANIX_MACHINE_MEMORY_SIZE      (defaults to "4Gi")
  - NUTANIX_MACHINE_VCPU_PER_SOCKET  (defaults to "1")
  - NUTANIX_MACHINE_VCPU_SOCKET      (defaults to "2")
  - NUTANIX_PORT                     (defaults to "9440")
  - NUTANIX_SYSTEMDISK_SIZE          (defaults to "40Gi")
  - WORKER_MACHINE_COUNT             (defaults to 0)
```

!!! note
    To prevent duplicate IP assignments, it is required to assign an IP-address to the `CONTROL_PLANE_ENDPOINT_IP` variable that is not part of the Nutanix IPAM or DHCP range assigned to the subnet of the CAPX cluster. 

!!! warning
    Make sure [Cluster Resource Set (CRS)](https://cluster-api.sigs.k8s.io/tasks/experimental-features/cluster-resource-set){target=_blank} is enabled before running `clusterctl init`

Now you can instantiate Cluster API with the following:
```
clusterctl init -i nutanix
```

### Deploy a workload cluster on Nutanix Cloud Infrastructure
```
export TEST_CLUSTER_NAME=mytestcluster1
export TEST_NAMESPACE=mytestnamespace
CONTROL_PLANE_ENDPOINT_IP=x.x.x.x clusterctl generate cluster ${TEST_CLUSTER_NAME} \
    -i nutanix \
    --target-namespace ${TEST_NAMESPACE}  \
    --kubernetes-version v1.22.9 \
    --control-plane-machine-count 1 \
    --worker-machine-count 3 > ./cluster.yaml
kubectl create ns ${TEST_NAMESPACE}
kubectl apply -f ./cluster.yaml -n ${TEST_NAMESPACE}
```
To customize the configuration of the default `cluster.yaml` file generated by CAPX, visit the  [NutanixCluster](./types/nutanix_cluster.md) and  [NutanixMachineTemplate](./types/nutanix_machine_template.md) documentation.

### Access a workload cluster
To access resources on the cluster, you can get the kubeconfig with the following:
```
clusterctl get kubeconfig ${TEST_CLUSTER_NAME} -n ${TEST_NAMESPACE} > ${TEST_CLUSTER_NAME}.kubeconfig
kubectl --kubeconfig ./${TEST_CLUSTER_NAME}.kubeconfig get nodes 
```

### Install CNI on a workload cluster

You must deploy a Container Network Interface (CNI) based pod network add-on so that your pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.

!!! note
    Take care that your pod network must not overlap with any of the host networks. You are likely to see problems if there is any overlap. If you find a collision between your network plugin's preferred pod network and some of your host networks, you must choose a suitable alternative CIDR block to use instead. It can be configured inside the `cluster.yaml` generated by `clusterctl generate cluster` before applying it.

Several external projects provide Kubernetes pod networks using CNI, some of which also support [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/){target=_blank}.

See a list of add-ons that implement the [Kubernetes networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-network-model){target=_blank}. At time of writing, the most common are [Calico](https://www.tigera.io/project-calico/){target=_blank} and [Cilium](https://cilium.io){target=_blank}.

Follow the specific install guide for your selected CNI and install only one pod network per cluster.

Once a pod network has been installed, you can confirm that it is working by checking that the CoreDNS pod is running in the output of `kubectl get pods --all-namespaces`.

### Add Failure Domain to Cluster

To update your cluster to use new or modified failure domains after initial deployment, follow these steps:

1. Create NutanixFailureDomain resource

   For example, define a failure domain in example.yaml:
```
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixFailureDomain
metadata:
  name: fd-domain-1
spec:
  prismElementCluster:
    type: name
    name: "PrismClusterA"
  subnets:
    - type: name
      name: "SubnetA"
    - type: name
      name: "SubnetB"
```

2. Apply the resource

   ```
kubectl apply -f example.yaml
```

3. Edit the NutanixCluster resource to reference the failure domain(s)

   ```
kubectl edit nutanixcluster <cluster-name> -n <namespace>
```

   In the spec section, add the controlPlaneFailureDomains field:

   ```
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
metadata:
spec:
  controlPlaneFailureDomains: # add controlPlaneFailureDomains
  - name: "fd-domain-1"      # failureDomain name
  - name: "fd-domain-2"      # failureDomain name
  controlPlaneEndpoint:
  prismCentral:
```

4. Verify the update

   Check that the failure domains are registered with the cluster:

   ```
kubectl get cluster <cluster-name> -n <namespace> -o yaml
```

   Look for the failureDomains in status section:

   ```
failureDomains:
  fd-domain-1:
    controlPlane: true
  fd-domain-2:
    controlPlane: true
```

### Add Failure Domain to MachineDeployment

To associate a MachineDeployment with a specific failure domain:

1. Export the MachineDeployment definition

   ```
kubectl get machinedeployments <name> -n <namespace> -o yaml > machinedeployment.yaml
```

2. Edit the manifest to add the failure domain

   Under spec.template.spec, add a failureDomain field:

   ```
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  name: your-machinedeployment
  namespace: your-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      cluster.x-k8s.io/deployment-name: your-machinedeployment
  template:
    metadata:
      labels:
        cluster.x-k8s.io/deployment-name: your-machinedeployment
    spec:
      failureDomain: "fd-domain-1"
      # other fields like bootstrap, infrastructureRef ...
```

3. Apply the changes

   ```
kubectl apply -f machinedeployment.yaml
```

4. Verify the Update

   Confirm that the failure domain field was updated:

   ```
kubectl get machinedeployments <name> -n <namespace> -o yaml | grep failureDomain
```

5. Check placement of machines

   Ensure new machines are placed in the specified failure domain:

   ```
kubectl get machines -l cluster.x-k8s.io/deployment-name=<name> -n <namespace> -o yaml
```

### Kube-vip settings

Kube-vip is a true load balancing solution for the Kubernetes control plane. It distributes API requests across control plane nodes. It also has the capability to provide load balancing for Kubernetes services.

You can tweak kube-vip settings by using the following properties:

- `KUBEVIP_LB_ENABLE`

This setting allows control plane load balancing using IPVS. See
[Control Plane Load-Balancing documentation](https://kube-vip.io/docs/about/architecture/#control-plane-load-balancing){target=_blank} for further information.

- `KUBEVIP_SVC_ENABLE` 

This setting enables a service of type LoadBalancer. See
[Kubernetes Service Load Balancing documentation](https://kube-vip.io/docs/about/architecture/#kubernetes-service-load-balancing){target=_blank} for further information.

- `KUBEVIP_SVC_ELECTION`

This setting enables Load Balancing of Load Balancers. See [Load Balancing Load Balancers](https://kube-vip.io/docs/usage/kubernetes-services/#load-balancing-load-balancers-when-using-arp-mode-yes-you-read-that-correctly-kube-vip-v050){target=_blank} for further information.

### Delete a workload cluster
To remove a workload cluster from your management cluster, remove the cluster object and the provider will clean-up all resources. 

```
kubectl delete cluster ${TEST_CLUSTER_NAME} -n ${TEST_NAMESPACE}
```
!!! note
    Deleting the entire cluster template with `kubectl delete -f ./cluster.yaml` may lead to pending resources requiring manual cleanup.
