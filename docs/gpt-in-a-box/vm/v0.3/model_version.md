# Model Version Support
We provide the capability to download and register various commits of the single model from HuggingFace. Follow the steps below for the same :

- [Generate MAR files](generating_mar.md) for the required HuggingFace commits by passing it's commit ID in the "--repo_version" argument
- [Deploy TorchServe](inference_server.md) with any one of the versions passed through the "--repo_version" argument
- Register the rest of the required versions through the [register additional models](management_requests.md#register-additional-models) request.

## Set Default Model Version
If multiple versions of the same model are registered, we can set a particular version as the default for inferencing by running the following command:
```
curl -v -X PUT "http://{inference_server_endpoint}:{management_port}/{model_name}/{repo_version}/set-default"
```
