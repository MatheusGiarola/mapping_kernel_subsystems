FROM python:3.10-slim

COPY ./requirements.txt /requirements.txt

RUN apt-get update && \
    apt-get install -y gcc python3-dev build-essential && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*