# Custom Model Support
In some cases you may want to use a custom model, e.g. a custom fine-tuned model. We provide the capability to generate a MAR file with custom models and start an inference server using Kubeflow serving.<br />

## Generate Model Archive File for Custom Models

!!! note
    The model files should be placed in an NFS share accessible by the Nutanix package. This directory will be passed to the --model_path argument. You'll also need to provide the --output path where you want the model archive export to be stored.

To generate the MAR file, run the following:
```
python3 $WORK_DIR/llm/generate.py --skip_download [--repo_version <REPO_COMMIT_ID> --handler <CUSTOM_HANDLER_PATH>] --model_name <MODEL_NAME> --model_path <MODEL_PATH> --output <NFS_LOCAL_MOUNT_LOCATION>
```

* **skip_download**:    Set flag to skip downloading the model files, must be set for custom models
* **model_name**:       Name of custom model
* **repo_version**:     Any model version, defaults to "1.0" (optional)
* **model_path**:       Absolute path of custom model files (should be non empty)
* **output**:           Mount path to your nfs server to be used in the kube PV where config.properties and model archive file be stored
* **handler**:          Path to custom handler, defaults to llm/handler.py (optional)<br />

## Start Inference Server with Custom Model Archive File
Run the following command for starting Kubeflow serving and running inference on the given input with a custom MAR file:
```
bash $WORK_DIR/llm/run.sh -n <CUSTOM_MODEL_NAME> -g <NUM_GPUS> -f <NFS_ADDRESS_WITH_SHARE_PATH> -m <NFS_LOCAL_MOUNT_LOCATION> -e <KUBE_DEPLOYMENT_NAME> [OPTIONAL -d <INPUT_PATH>]
```

* **n**:    Name of custom model, this name must not be in model_config
* **d**:    Absolute path of input data folder (Optional)
* **g**:    Number of gpus to be used to execute (Set 0 to use cpu)
* **f**:    NFS server address with share path information
* **m**:    Mount path to your nfs server to be used in the kube PV where model files and model archive file be stored
* **e**:    Name of the deployment metadata

