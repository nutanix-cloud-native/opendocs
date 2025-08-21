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
4. To install Nutanix CSI Driver interacting in PC Mode

        apiVersion: crd.nutanix.com/v1alpha1
        kind: NutanixCsiStorage
        metadata:
          name: nutanixcsistorage
          namespace: openshift-cluster-csi-drivers
        spec: 
          ntnxInitConfigMap:
            usePC : true

4. To install Nutanix CSI Driver interacting in PE Mode

        apiVersion: crd.nutanix.com/v1alpha1
        kind: NutanixCsiStorage
        metadata:
          name: nutanixcsistorage
          namespace: openshift-cluster-csi-drivers
        spec: 
          ntnxInitConfigMap:
            usePC : false



### Configuring the K8s secret and storage class

In order to use this driver, create the relevant storage classes and secrets using the OpenShift CLI, by followinig the below section:

1. Depending on the mode of interaction of the CSI Driver(Interacting with PC or PE), create a secret yaml file like the below example and apply (`oc -n openshift-cluster-csi-drivers apply -f <filename>`).

        ### Create a Nutanix PC secret
        apiVersion: v1
        kind: Secret
        metadata:
          name: ntnx-pc-secret
          namespace: openshift-cluster-csi-drivers
        stringData:
          # prism-central-ip:prism-port:username:password.
          key: 1.2.3.4:9440:admin:password

        ### Create a Nutanix PE secret
        apiVersion: v1
        kind: Secret
        metadata:
          name: ntnx-pe-secret
          namespace: openshift-cluster-csi-drivers
        stringData:
          # prism-element-ip:prism-port:username:password.
          key: 1.2.3.4:9440:admin:password
          files-key: "fileserver01.sample.com:csi:password1" # For dynamic files mode

2. Create storage class yaml like the below example and apply (`oc apply -f <filename>`).

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: nutanix-volume
        provisioner: csi.nutanix.com
        parameters:
          csi.storage.k8s.io/provisioner-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/node-publish-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/node-publish-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/controller-expand-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/controller-expand-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/controller-publish-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/controller-publish-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/fstype: ext4
          storageContainer: default-container
          storageType: NutanixVolumes
          #description: "description added to each storage object created by the driver"
          #isSegmentedIscsiNetwork: "false"
          #whitelistIPMode: ENABLED
          #chapAuth: ENABLED
          #isLVMVolume: "false"
          #numLVMDisks: 4
        allowVolumeExpansion: true
        reclaimPolicy: Delete

3. For dynamic files mode example create storage class yaml like the below example and apply (`oc apply -f <filename>`).

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
          name: nutanix-volume
        provisioner: csi.nutanix.com
        parameters:
          csi.storage.k8s.io/provisioner-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/node-publish-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/node-publish-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/controller-expand-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/controller-expand-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/controller-publish-secret-name: ntnx-pe-secret
          csi.storage.k8s.io/controller-publish-secret-namespace: openshift-cluster-csi-drivers
          csi.storage.k8s.io/fstype: ext4
          storageContainer: default-container
          storageType: NutanixVolumes
          #description: "description added to each storage object created by the driver"
          #isSegmentedIscsiNetwork: "false"
          #whitelistIPMode: ENABLED
          #chapAuth: ENABLED
          #isLVMVolume: "false"
          #numLVMDisks: 4
        allowVolumeExpansion: true
        reclaimPolicy: Delete

    
**Note:** By default, new RHCOS based nodes are provisioned with the required `scsi-initiator-utils` package installed, but with the `iscsid` service disabled. This can result in messages like `iscsiadm: can not connect to iSCSI daemon (111)!`. When this occurs, confirm that the `iscsid.service` is running on worker nodes. It can be enabled and started globally using the Machine Config Operator or directly on each node using systemctl (`sudo systemctl enable --now iscsid`).
     
See the Managing Storage section of [CSI Driver documentation](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v3_3:csi-csi-plugin-storage-c.html){target=_blank} on the Nutanix Portal for more information on configuring storage classes. 

### Upgrading Nutanix CSI Driver from 2.6.x to 3.3
Please read the following instructions carefully before upgrading from 2.6.x to 3.3, for more information please refer to [documentation](https://portal.nutanix.com/page/documents/details?targetId=CSI-Volume-Driver-v3_3:CSI-Volume-Driver-v3_3) 

1. Please do not upgrade to the CSI 3.x operator if:
    * You are using LVM volumes.
    
2. To upgrade from the CSI 2.6.x to CSI 3.3 (interacting with Prism Central) operator
    * Create a Nutanix Prism Central secret as explained above.
    * Delete the csidriver object from the cluster:

        ```
        oc delete csidriver csi.nutanix.com
        ```

    * In the installed operators, go to Nutanix CSI Operator and change the subscription channel from stable to stable-3.x. 
    If you have installed the operator with automatic update approval, the operator will be automatically upgraded to CSI 3.3, and then the nutanixcsistorage resource will be upgraded.
    An update plan will be generated for manual updates. Upon approval, the operator will be successfully upgraded.
    
3. Direct upgrades from CSI 2.6.x to CSI 3.3 interacting with Prism Element are not supported. 
    The only solution is to recreate the nutanixcsistorage instance by following the below procedure:
    - In the installed operators, go to Nutanix CSI Operator and delete the nutanixcsistorage instance.
    - Next change the subscription channel from stable to stable-3.x.
    - Verify the following points:
        - Ensure a Nutanix Prism Element secret is present in the namespace.
        - Ensure that all the storage classes with provisioner: csi.nutanix.com have a controller publish secret as explained below.

            ```
            csi.storage.k8s.io/controller-publish-secret-name: ntnx-pe-secret
            csi.storage.k8s.io/controller-publish-secret-namespace: openshift-cluster-csi-drivers
            ```

            If this secret is not present in the storage class please delete and recreate the storage classes with the required secrets.
    - Create a new instance of nutanixcsistorage from this operator by specifying `usePC: false` in YAML spec section.
    - Caution: Moving from CSI driver interacting with Prism Central to CSI driver interacting with Prism Element is not supported.
    
4. Troubleshooting:
    
    If the upgrade was unsuccessful and you want to revert to version CSI 2.6.x, please delete the csidriver object as explained above, uninstall the operator (no need to delete the nutanixcsistorage custom resource), and install version CSI 2.6.x from the stable channel.


### Using the Nutanix CSI Operator on restricted networks

For OpenShift Container Platform clusters that are installed on restricted networks, also known as disconnected clusters, Operator Lifecycle Manager (OLM) by default cannot access the Red Hat-provided OperatorHub sources hosted on remote registries because those remote sources require full internet connectivity.

The Nutanix CSI Operator is fully compatible with a restricted networks architecture and supported in disconnected mode. Follow the [OpenShift documentation](https://docs.openshift.com/container-platform/latest/operators/admin/olm-restricted-networks.html){target=_blank} to configure.

You need to mirror the `certified-operator-index` and keep the `nutanixcsioperator` package in your pruned index.