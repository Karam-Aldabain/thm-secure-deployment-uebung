FROM debian:bookworm-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 python3-venv ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m venv /opt/venv
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN groupadd --gid 10001 appuser \
 && useradd --uid 10001 --gid appuser --no-create-home \
      --shell /usr/sbin/nologin appuser \
 && mkdir -p /data \
 && chown appuser:appuser /data
COPY server.py .
USER 10001:10001
EXPOSE 5000
CMD ["python", "server.py"]
