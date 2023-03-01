# Creating a workload CAPX cluster in a Nutanix Flow VPC

!!! warning
        The scenario and features described on this page are experimental and should not be deployed in production environments.

!!! note
    Nutanix Flow VPCs are only validated with CAPX 1.1.3+

[Nutanix Flow Virtual Networking](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Flow-Virtual-Networking-Guide-vpc_2022_9:Nutanix-Flow-Virtual-Networking-Guide-vpc_2022_9){target=_blank} allows users to create Virtual Private Clouds (VPCs) with Overlay networking. 
The steps below will illustrate how a CAPX cluster can be deployed inside an overlay subnet (NAT) inside a VPC while the management cluster resides outside of the VPC.


## Steps
1. [Request a floating IP](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Flow-Networking-Guide:ear-flow-nw-request-floating-ip-pc-t.html){target=_blank}
2. Link the floating IP to an internal IP address inside the overlay subnet that will be used to deploy the CAPX cluster. This address will be assigned to the CAPX loadbalancer. To prevent IP conflicts, make sure the IP address is not part of the IP-pool defined in the subnet. 
3. Generate a `cluster.yaml` file with the required CAPX cluster configuration where the `CONTROL_PLANE_ENDPOINT_IP` is set to the floating IP requested in the first step. Refer to the [Getting Started](../getting_started.md){target=_blank} page for more information on how to generate a `cluster.yaml` file. Do not apply the `cluster.yaml` file. 
4. Edit the `cluster.yaml` file and search for the `KubeadmControlPlane` resource.
5. Modify the `spec.kubeadmConfigSpec.files.*.content` attribute and change the `kube-vip` definition similar to [example](#example) below.
6. Apply the `cluster.yaml` file.
7. When CAPX workload cluster is deployed, it will be reachable via the floating IP.

## Example 
```YAML
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    files:
      - content: |
          apiVersion: v1
          kind: Pod
          metadata:
            name: kube-vip
            namespace: kube-system
          spec:
            containers:
              - env:
                  - name: address
                    value: "<internal overlay subnet address>"                  
```

