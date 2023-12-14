# Model Version Support
We provide the capability to download and register various commits of the single model from HuggingFace. By specifying the commit ID as "repo_version", you can produce MAR files for multiple iterations of the same model and register them simultaneously. To transition between these versions, you can set a default version within TorchServe while it is running and inference the desired version.

## Set Default Model Version
If multiple versions of the same model are registered, we can set a particular version as the default for inferencing by running the following command:
```
curl -v -X PUT "http://{inference_server_endpoint}:{management_port}/{model_name}/{repo_version}/set-default"
```
