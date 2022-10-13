## Install the Nutanix CSI Operator (Optional)

1. Follow [documentation](/openshift/operators/csi) to install the CSI Operator and provision the driver.

## OpenShift Image registry configuration (Optional)
Based on requirements, choose one of the following options:

**Note:** Block storage volumes like Nutanix Volumes with ReadWriteOnce configuration are supported but not recommended for use with the image registry on production clusters. An installation where the registry is configured on block storage is not highly available because the registry cannot have more than one replica.

### Option A: Provision a Nutanix Volumes PVC and modify the OpenShift Image registry configuration

1. Create storage class yaml like the below example and apply (`oc apply -f <filename>`).

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

2. Create a PVC yaml file like the below example and apply in the openshift-image-registry namespace (`oc -n openshift-image-registry apply -f <filename>`).

        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
            name: image-registry-claim
            namespace: openshift-image-registry
        spec:
            accessModes:
            - ReadWriteOnce
            resources:
            requests:
                storage: 100Gi
            storageClassName: nutanix-volume

3. Configure OpenShift registry storage similarly to [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html#installation-registry-storage-config_installing-bare-metal){target=_blank}:
    1. Modify the registry storage configuration:

            oc edit configs.imageregistry.operator.openshift.io

        Change the line:
    
            storage: {}
    
        To:
    
            storage:
                pvc:
                 claim: image-registry-claim
    
        Change the line:
    
            managementState: Removed
        
        To:
    
            managementState: Managed

        Change the line:
     
            rolloutStrategy: RollingUpdate
    
        To:
    
            rolloutStrategy: Recreate

**Note:** Block storage volumes like Nutanix Volumes with ReadWriteOnce configuration are supported but not recommended for use with the image registry on production clusters. An installation where the registry is configured on block storage is not highly available because the registry cannot have more than one replica. 

### Option B: Provision a Nutanix Files PVC and modify the OpenShift Image registry configuration

  **Note:** The below steps assume Nutanix Files is enabled in your cluster. Files provides a highly available and massively scalable data repository for a wide range of deployments and applications.

1. Create a dynamicly provisioned NFS storage class yaml file like the below example and apply (`oc apply -f <filename>`).

        kind: StorageClass
        apiVersion: storage.k8s.io/v1
        metadata:
            name: nutanix-files-dynamic
        provisioner: csi.nutanix.com
        parameters:
            dynamicProv: ENABLED
            nfsServerName: nfs01
            #nfsServerName above is File Server Name in Prism without DNS suffix, not the FQDN.
            csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
            csi.storage.k8s.io/provisioner-secret-namespace: openshift-cluster-csi-drivers
        storageType: NutanixFiles

2. Create a PVC yaml file like the below example and apply in the openshift-image-registry namespace (`oc -n openshift-image-registry apply -f <filename>`).

        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
            name: image-registry-claim
            namespace: openshift-image-registry
        spec:
            accessModes:
            - ReadWriteMany
            resources:
            requests:
                storage: 100Gi
            storageClassName: nutanix-files-dynamic

3. Configure OpenShift registry storage similarly to [OpenShift documentation](https://docs.openshift.com/container-platform/latest/installing/installing_bare_metal/installing-bare-metal.html#installation-registry-storage-config_installing-bare-metal){target=_blank}:
    1. Modify the registry storage configuration:

            oc edit configs.imageregistry.operator.openshift.io

        Change the line:
    
            storage: {}
    
        To:
    
            storage:
                pvc:
                claim: image-registry-claim

        Change the line:
    
            managementState: Removed
        
        To:
    
            managementState: Managed

        Change the line:
     
            replicas: 1
    
        To:
    
            replicas: 2

    
### Option C: Using Nutanix Objects as backend storage for OpenShift Image registry

  **Note:** The below steps assume Nutanix Objects is enabled in your cluster. Objects provides a highly available and massively scalable S3-compatible Object Store.

**Prerequisite:**

- Create a bucket used for the Image registry
- Create and assign a user with R/W access to the bucket
- Download the SSL CA cert from Nutanix Object Store

Optional: Assign a trusted SSL certificate to your Object Store which contains a SAN for the used DNS name or an IP-SAN if no DNS is used.

1. Add the Nutanix Objects CA certificate to OpenShift (only needed if not using a trusted certificate):

        oc create configmap custom-ca \
            --from-file=ca-bundle.crt=objectca.crt \
            -n openshift-config

        oc patch proxy/cluster \
            --type=merge \
            --patch='{"spec":{"trustedCA":{"name":"custom-ca"}}}'

2. Create a secret containing the S3 credentials:

        oc create secret generic image-registry-private-configuration-user \
        --from-literal=REGISTRY_STORAGE_S3_ACCESSKEY=your-access-key \
        --from-literal=REGISTRY_STORAGE_S3_SECRETKEY=your-secret-key \
        --namespace openshift-image-registry
 
3. Modify the Image registry storage configuration:

        oc edit configs.imageregistry.operator.openshift.io

    Change the line:

        storage: {}

    To:

            storage:
            s3:
                bucket: "your-bucket"
                regionEndpoint: "https://path-to-your-object-store"
                region: "us-east-1"

    Change the line:

        managementState: Removed

     To:

        managementState: Managed
