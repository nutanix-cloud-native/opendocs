## Download model files and Generate MAR file
Run the following command for downloading model files and generating MAR file: 
```
python3 $WORK_DIR/llm/download.py [--repo_version <REPO_COMMIT_ID>] --model_name <MODEL_NAME> --output <NFS_LOCAL_MOUNT_LOCATION> --hf_token <Your_HuggingFace_Hub_Token>
```

* **model_name**:       Name of model
* **output**:           Mount path to your nfs server to be used in the kube PV where model files and model archive file be stored
* **repo_version**:     Commit id of model's repo from HuggingFace (optional, if not provided default set in model_config will be used)
* **hf_token**:         Your HuggingFace token. Needed to download LLAMA(2) models.

The available LLMs are mpt_7b (mosaicml/mpt_7b), falcon_7b (tiiuae/falcon-7b), llama2_7b (meta-llama/Llama-2-7b-hf).

### Examples  
The following are example commands to generate the model archive file.  
  
Download MPT-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name mpt_7b --output /mnt/llm
```
Download Falcon-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name falcon_7b --output /mnt/llm
```
Download Llama2-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name llama2_7b --output /mnt/llm --hf_token <Your_HuggingFace_Hub_Token>
```
