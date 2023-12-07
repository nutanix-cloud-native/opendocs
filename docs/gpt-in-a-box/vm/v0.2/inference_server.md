# Deploying Inference Server
Run the following command to start TorchServe (Inference Server) and run inference on the provided input:
```
bash $WORK_DIR/llm/run.sh -n <MODEL_NAME> -a <MAR_EXPORT_PATH> [OPTIONAL -d <INPUT_PATH> -v <REPO_VERSION>]
```
Where the arguments are :

- **n**:    Name of model
- **v**:    Commit ID of model's HuggingFace repository (optional, if not provided default set in model_config will be used)
- **d**:    Absolute path of input data folder (optional)
- **a**:    Absolute path to the Model Store directory

The available LLMs model names are mpt_7b (mosaicml/mpt_7b), falcon_7b (tiiuae/falcon-7b), llama2_7b (meta-llama/Llama-2-7b-hf).

Once the Inference Server has successfully started, you should see a "Ready For Inferencing" message.

### Examples
The following are example commands to start the Inference Server.

For Inference with official MPT-7B model:
```
bash $WORK_DIR/llm/run.sh -n mpt_7b -d $WORK_DIR/data/translate -a /home/ubuntu/models/model_store
```
For Inference with official Falcon-7B model:
```
bash $WORK_DIR/llm/run.sh -n falcon_7b -d $WORK_DIR/data/qa -a /home/ubuntu/models/model_store
```
For Inference with official Llama2-7B model:
```
bash $WORK_DIR/llm/run.sh -n llama2_7b -d $WORK_DIR/data/summarize -a /home/ubuntu/models/model_store
```

## Stop Inference Server and Cleanup
Run the following command to stop the Inference Server and clean up temporarily generate files.
```
python3 $WORK_DIR/llm/cleanup.py
```