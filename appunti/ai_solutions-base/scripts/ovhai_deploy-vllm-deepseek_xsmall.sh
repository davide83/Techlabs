#!/bin/bash

#### Hugging Face TOKEN
#export MY_HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxx
#### OVHcloud AI ACCESS TOKEN
#export MY_OVHAI_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

ovhai app run \
    --name techlab-ai-vllm-deepseek-xsmall \
    --default-http-port 8000 \
    --label techlab/vllm=deepseek \
    --label techlab/ai_deploy_token=_techlab_my_operator_token \
    --gpu 1 \
    --flavor l40s-1-gpu \
    -e OUTLINES_CACHE_DIR=/tmp/.outlines \
    -e HF_TOKEN=$MY_HF_TOKEN \
    -e HF_HOME=/hub \
    -e HF_DATASETS_TRUST_REMOTE_CODE=1 \
    -e HF_HUB_ENABLE_HF_TRANSFER=0 \
    -v standalone:/hub:rw \
    -v standalone:/workspace:rw \
    vllm/vllm-openai:latest \
        -- bash -c "python3 -m vllm.entrypoints.openai.api_server \
        --model deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
        --tensor-parallel-size 1"