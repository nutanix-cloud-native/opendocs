# Using Autoscaler in combination with CAPX

!!! warning
        The scenario and features described on this page are experimental. It's important to note that they have not been fully validated.
        
[Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/README.md){target=_blank} can be used in combination with Cluster API to automatically add or remove machines in a cluster. 

Autoscaler can be used in different deployment scenarios. This page will provide an overview of multiple autoscaler deployment scenarios in combination with CAPX.
See the [Testing](#testing) section to see how scale-up/scale-down events can be triggered to validate the autoscaler behaviour.

More in-depth information on Autoscaler functionality can be found in the [Kubernetes documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/README.md){target=_blank}.

All Autoscaler configuration parameters can be found [here](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca){target=_blank}.

## Scenario 1: Management cluster managing an external workload cluster
In this scenario, Autoscaler will be running on a management cluster and it will manage an external workload cluster. See the management cluster managing an external workload cluster section of [Kubernetes documentation](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/README.md#autoscaler-running-in-management-cluster-using-service-account-credentials-with-separate-workload-cluster){target=_blank} for more information.

### Steps
1. Deploy a management cluster and workload cluster. The [CAPI quickstart](https://cluster-api.sigs.k8s.io/user/quick-start.html){target=_blank} can be used as a starting point.

    !!! note
            Make sure a CNI is installed in the workload cluster.

4. Download the example [Autoscaler deployment file](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/examples/deployment.yaml){target=_blank}.
5. Modify the `deployment.yaml` file:
    - Change the namespace of all resources to the namespaces of the workload cluster.
    - Choose an autoscale image.
    - Change the following parameters in the `Deployment` resource:
```YAML
        spec:
            containers:
                  name: cluster-autoscaler
                  command:
                      - /cluster-autoscaler
                  args:
                      - --cloud-provider=clusterapi
                      - --kubeconfig=/mnt/kubeconfig/kubeconfig.yml
                      - --clusterapi-cloud-config-authoritative
                      - -v=1
                  volumeMounts:
                      - mountPath: /mnt/kubeconfig
                        name: kubeconfig
                        readOnly: true
            ...
            volumes:
                - name: kubeconfig
                  secret:
                      secretName: <workload cluster name>-kubeconfig
                      items:
                          - key: value
                            path: kubeconfig.yml
```
7. Apply the `deployment.yaml` file.
```bash
kubectl apply -f deployment.yaml
```
8. Add the [annotations](#autoscaler-node-group-annotations) to the workload cluster `MachineDeployment` resource.
9. Test Autoscaler. Go to the [Testing](#testing) section.

## Scenario 2: Autoscaler running on workload cluster
In this scenario, Autoscaler will be deployed [on top of the workload cluster](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/README.md#autoscaler-running-in-a-joined-cluster-using-service-account-credentials){target=_blank} directly. In order for Autoscaler to work, it is required that the workload cluster resources are moved from the management cluster to the workload cluster.

### Steps
1. Deploy a management cluster and workload cluster. The [CAPI quickstart](https://cluster-api.sigs.k8s.io/user/quick-start.html){target=_blank} can be used as a starting point.
2. Get the kubeconfig file for the workload cluster and use this kubeconfig to login to the workload cluster. 
```bash
clusterctl get kubeconfig <workload cluster name> -n <workload cluster namespace > /path/to/kubeconfig
```
3. Install a CNI in the workload cluster.
4. Initialise the CAPX components on top of the workload cluster:
```bash
clusterctl init --infrastructure nutanix
```
5. Migrate the workload cluster custom resources to the workload cluster. Run following command from the management cluster:
```bash
clusterctl move -n <workload cluster ns>  --to-kubeconfig /path/to/kubeconfig
```
6. Verify if the cluster has been migrated by running following command on the workload cluster:
```bash
kubectl get cluster -A 
```
7. Download the example [autoscaler deployment file](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/clusterapi/examples/deployment.yaml){target=_blank}.
8. Create the Autoscaler namespace:
```bash
kubectl create ns autoscaler
```
9. Apply the `deployment.yaml` file
```bash
kubectl apply -f deployment.yaml
```
10. Add the [annotations](#autoscaler-node-group-annotations) to the workload cluster `MachineDeployment` resource.
11. Test Autoscaler. Go to the [Testing](#testing) section.

## Testing

1. Deploy an example Kubernetes application. For example, the one used in the [Kubernetes HorizontalPodAutoscaler Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/).
```bash
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml 
```
2. Increase the amount of replicas of the application to trigger a scale-up event:
```
kubectl scale deployment php-apache --replicas 100
```
3. Decrease the amount of replicas of the application again to trigger a scale-down event.

    !!! note
        In case of issues check the logs of the Autoscaler pods.

4. After a while CAPX, will add more machines. Refer to the [Autoscaler configuration parameters](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca){target=_blank} to tweak the behaviour and timeouts.

## Autoscaler node group annotations
Autoscaler uses following annotations to define the upper and lower boundries of the managed machines:

| Annotation                                                  | Example Value | Description                                   |
|-------------------------------------------------------------|---------------|-----------------------------------------------|
| cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size | 5             | Maximum amount of machines in this node group |
| cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size | 1             | Minimum amount of machines in this node group |

These annotations must be applied to the `MachineDeployment` resources of a CAPX cluster. 

### Example
```YAML
apiVersion: cluster.x-k8s.io/v1beta1
kind: MachineDeployment
metadata:
  annotations:
    cluster.x-k8s.io/cluster-api-autoscaler-node-group-max-size: "5"
    cluster.x-k8s.io/cluster-api-autoscaler-node-group-min-size: "1"
```