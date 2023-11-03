## Start and run Kubeflow Serving

Run the following command for starting Kubeflow serving and running inference on the given input:
```
bash $WORK_DIR/llm/run.sh  -n <MODEL_NAME> -g <NUM_GPUS> -f <NFS_ADDRESS_WITH_SHARE_PATH> -m <NFS_LOCAL_MOUNT_LOCATION> -e <KUBE_DEPLOYMENT_NAME> [OPTIONAL -d <INPUT_PATH> -v <REPO_COMMIT_ID> -t <Your_HuggingFace_Hub_Token>]
```

* **n**:    Name of model
* **d**:    Absolute path of input data folder (Optional)
* **g**:    Number of gpus to be used to execute (Set 0 to use cpu)
* **f**:    NFS server address with share path information
* **m**:    Mount path to your nfs server to be used in the kube PV where model files and model archive file be stored
* **e**:    Name of the deployment metadata
* **v**:    Commit id of model's repo from HuggingFace (optional, if not provided default set in model_config will be used)
* **t**:    Your HuggingFace token. Needed for LLAMA(2) model.

The available LLMs model names are mpt_7b (mosaicml/mpt_7b), falcon_7b (tiiuae/falcon-7b), llama2_7b (meta-llama/Llama-2-7b-hf).  
Should print "Inference Run Successful" as a message once the Inference Server has successfully started.  

### Examples  
The following are example commands to start the Inference Server.

For 1 GPU Inference with official MPT-7B model and keep inference server alive:
```
bash $WORK_DIR/llm/run.sh -n mpt_7b -d data/translate -g 1 -e llm-deploy -f '1.1.1.1:/llm' -m /mnt/llm
```
For 1 GPU Inference with official Falcon-7B model and keep inference server alive:
```
bash $WORK_DIR/llm/run.sh -n falcon_7b -d data/qa -g 1 -e llm-deploy -f '1.1.1.1:/llm' -m /mnt/llm
```
For 1 GPU Inference with official Llama2-7B model and keep inference server alive:
```
bash $WORK_DIR/llm/run.sh -n llama2_7b -d data/summarize -g 1 -e llm-deploy -f '1.1.1.1:/llm' -m /mnt/llm -t <Your_HuggingFace_Hub_Token>
```

### Cleanup Inference deployment

Run the following command to stop the inference server and unmount PV and PVC.
```
python3 $WORK_DIR/llm/cleanup.py --deploy_name <DEPLOYMENT_NAME>
```
Example:
```
python3 $WORK_DIR/llm/cleanup.py --deploy_name llm-deploy
```