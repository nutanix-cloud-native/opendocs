# Nutanix CSI Operator

## Overview

The Nutanix CSI Operator for Kubernetes packages, deploys, manages, and upgrades the Nutanix CSI Driver on Kubernetes and OpenShift for dynamic provisioning of persistent volumes on the Nutanix Enterprise Cloud platform.

### Nutanix CSI Driver

The Nutanix Container Storage Interface (CSI) Driver for Kubernetes leverages Nutanix Volumes and Nutanix Files to provide scalable and persistent storage for stateful applications.

With Nutanix CSI Provider you can:

 - Provide persistent storage to your containers

   - Leverage PVC ressources to consume dynamicaly Nutanix storage

   - With Files storage classes, applications on multiple pods can access the same storage, and also have the benefit of multi-pod read and write access.

### Installing the Operator

1. Follow [OpenShift documentation](https://docs.openshift.com/container-platform/latest/operators/admin/olm-adding-operators-to-cluster.html){target=_blank} for adding Operators to a cluster.
    1. Filter by the keyword "Nutanix" to find the CSI Operator.

        <image src=images/operatorhub-csi.png>

    2. Install the Operator by using the "openshift-cluster-csi-drivers" namespace and selecting defaults.

### Installing the CSI Driver using the Operator

1. In the OpenShift web console, navigate to the Operators → Installed Operators page.
2. Select **Nutanix CSI Operator**.
3. Select **Create instance** and then **Create**.

    <image src=images/operator-csi-deploy.png>

### Configuring the K8s secret and storage class

In order to use this driver, create the relevant storage classes and secrets using the OpenShift CLI, by followinig the below section:

1. Create a secret yaml file like the below example and apply (`oc -n openshift-cluster-csi-drivers apply -f <filename>`).

        apiVersion: v1
        kind: Secret
        metadata:
          name: ntnx-secret
          namespace: openshift-cluster-csi-drivers
        stringData:
          # prism-element-ip:prism-port:admin:password
          key: 10.0.0.14:9440:admin:password

2. Create storage class yaml like the below example and apply (`oc apply -f <filename>`).

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: nutanix-volume
        provisioner: csi.nutanix.com
        parameters:
          csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
          csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/node-publish-secret-name: ntnx-secret
          csi.storage.k8s.io/node-publish-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/controller-expand-secret-name: ntnx-secret
          csi.storage.k8s.io/controller-expand-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/fstype: ext4
          dataServiceEndPoint: 10.0.0.15:3260
          storageContainer: default-container
          storageType: NutanixVolumes
          #whitelistIPMode: ENABLED
          #chapAuth: ENABLED
        allowVolumeExpansion: true
        reclaimPolicy: Delete

    
**Note:** By default, new RHCOS based nodes are provisioned with the required `scsi-initiator-utils` package installed, but with the `iscsid` service disabled. This can result in messages like `iscsiadm: can not connect to iSCSI daemon (111)!`. When this occurs, confirm that the `iscsid.service` is running on worker nodes. It can be enabled and started globally using the Machine Config Operator or directly on each node using systemctl (`sudo systemctl enable --now iscsid`).
     
See the Managing Storage section of [CSI Driver documentation](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v2_5:csi-csi-plugin-storage-c.html){target=_blank} on the Nutanix Portal for more information on configuring storage classes. 

### Using the Nutanix CSI Operator on restricted networks

For OpenShift Container Platform clusters that are installed on restricted networks, also known as disconnected clusters, Operator Lifecycle Manager (OLM) by default cannot access the Red Hat-provided OperatorHub sources hosted on remote registries because those remote sources require full internet connectivity.

The Nutanix CSI Operator is fully compatible with a restricted networks architecture and supported in disconnected mode. Follow the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/operators/admin/olm-restricted-networks.html){target=_blank} to configure.

You need to mirror the `certified-operator-index` and keep the `nutanixcsioperator` package in your pruned index.