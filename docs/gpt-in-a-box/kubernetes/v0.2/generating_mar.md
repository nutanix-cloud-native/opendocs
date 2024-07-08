# Generate PyTorch Model Archive File
We will download the model files and generate a Model Archive file for the desired LLM, which will be used by TorchServe to load the model. Find out more about Torch Model Archiver [here](https://github.com/pytorch/serve/blob/master/model-archiver/README.md).

Run the following command for downloading model files and generating MAR file: 
```
python3 $WORK_DIR/llm/generate.py [--hf_token <HUGGINGFACE_HUB_TOKEN> --repo_version <REPO_COMMIT_ID>] --model_name <MODEL_NAME> --output <NFS_LOCAL_MOUNT_LOCATION>
```

* **model_name**:       Name of a [validated model](validated_models.md)
* **output**:           Mount path to your nfs server to be used in the kube PV where model files and model archive file be stored
* **repo_version**:     Commit ID of model's HuggingFace repository (optional, if not provided default set in model_config will be used)
* **hf_token**:         Your HuggingFace token. Needed to download LLAMA(2) models. (It can alternatively be set using the environment variable 'HF_TOKEN')

### Examples  
The following are example commands to generate the model archive file.  
  
Download MPT-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/generate.py --model_name mpt_7b --output /mnt/llm
```
Download Falcon-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/generate.py --model_name falcon_7b --output /mnt/llm
```
Download Llama2-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/generate.py --model_name llama2_7b --output /mnt/llm --hf_token <HUGGINGFACE_HUB_TOKEN>
```
