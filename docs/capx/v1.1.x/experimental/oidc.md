# OIDC integration

!!! warning
        The scenario and features described on this page are experimental and should not be deployed in production environments.

Kubernetes allows users to authenticate using various authentication mechanisms. One of these mechanisms is OIDC. Information on how Kubernetes interacts with OIDC providers can be found in the [OpenID Connect Tokens](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens){target=_blank} section of the official Kubernetes documentation. 


Follow the steps below to configure a CAPX cluster to use an OIDC identity provider.

## Steps
1. Generate a `cluster.yaml` file with the required CAPX cluster configuration. Refer to the [Getting Started](../getting_started.md){target=_blank} page for more information on how to generate a `cluster.yaml` file. Do not apply the `cluster.yaml` file. 
2. Edit the `cluster.yaml` file and search for the `KubeadmControlPlane` resource.
3. Modify/add the `spec.kubeadmConfigSpec.clusterConfiguration.apiServer.extraArgs` attribute and add the required [API server parameters](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#configuring-the-api-server){target=_blank}. See the [example](#example) below.
4. Apply the `cluster.yaml` file 
5. Log in with the OIDC provider once the cluster is provisioned

## Example 
```YAML
kind: KubeadmControlPlane
spec:
  kubeadmConfigSpec:
    clusterConfiguration:
      apiServer:
        extraArgs:
            ...
            oidc-client-id: <oidc-client-id>
            oidc-issuer-url: <oidc-issuer-url>
            ...
```

