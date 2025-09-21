FROM python:3.11-slim

# System deps for Pillow, OpenCV-lite bits, Paddle OCR runtime, and healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 libsm6 libxext6 libxrender1 libgl1 ca-certificates wget curl \
 && rm -rf /var/lib/apt/lists/*

# Faster pip, no cache
ENV PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY requirements.txt /app/

# Install Paddle dependencies first
RUN pip install --upgrade pip && \
    pip install paddlepaddle-cpu && \
    pip install -r requirements.txt

COPY main.py /app/
EXPOSE 8000

# Simple healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  wget -qO- http://127.0.0.1:8000/healthz || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--no-access-log"]
