FROM registry.lazycat.cloud/x/clip_trt:r36.4.3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-key adv --fetch-keys https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
RUN echo "deb https://repo.download.nvidia.com/jetson/ffmpeg main main" | tee -a /etc/apt/sources.list

# Ubuntu 24.04 源
# RUN sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources
# Ubuntu 22.04 源
RUN sed -i 's@//.*ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list

RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update && \
    apt-get install -y --no-install-recommends curl

# RUN --mount=type=cache,target=/root/.cache/pip \
#     --mount=type=bind,source=requirements-nvidia.txt,target=requirements-nvidia.txt \
#     pip3 install -r requirements-nvidia.txt -i https://pypi.jetson-ai-lab.dev/jp6/cu128/+simple

# RUN --mount=type=cache,target=/root/.cache/pip \
#     --mount=type=bind,source=packages,target=/packages \
#     --mount=type=bind,source=requirements-nvidia.txt,target=requirements-nvidia.txt \
#     pip3 install -r requirements-nvidia.txt -i http://192.168.1.239:10608/simple --trusted-host 192.168.1.239

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    pip3 install -r requirements.txt -i http://192.168.1.239:10608/simple --trusted-host 192.168.1.239

WORKDIR /app

# COPY models models

# 复制模型文件夹
# RUN mkdir -p /data/models/huggingface

# 特别坑，注意容器内设置了 TRANSFORMERS_CACHE 和 HF_HOME 都为 /data/models/huggingface
# 只会使用 TRANSFORMERS_CACHE
# 所以这里需要复制 hub 目录到 /data/models/huggingface 才行
# COPY models/hub/models--thu-ml--zh-clip-vit-roberta-large-patch14 /data/models/huggingface/models--thu-ml--zh-clip-vit-roberta-large-patch14
# COPY models/hub/.locks /data/models/huggingface/.locks

# COPY dist/clip clip

COPY app app

# COPY server.py .

ENV HF_ENDPOINT=https://hf-mirror.com

# ENV HF_HOME=/data/models/huggingface

# ENV HF_OFFLINE=1

EXPOSE 3000

# CMD ["python3", "-m", "uvicorn", "app.gpt:app", "--host", "0.0.0.0", "--port", "3000"]
CMD ["python3", "-m", "uvicorn", "app.blip:app", "--host", "0.0.0.0", "--port", "3000"]