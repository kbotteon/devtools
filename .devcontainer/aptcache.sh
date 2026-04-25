#!/bin/bash
set -e

BUILD_DIR="/tmp/apt-cache-build"
mkdir -p "$BUILD_DIR"

cat > "$BUILD_DIR/Dockerfile" <<'EOF'
FROM debian:bookworm-slim
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-cacher-ng && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'PassThroughPattern: .*' >> /etc/apt-cacher-ng/acng.conf && \
    chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng && \
    chmod 755 /var/cache/apt-cacher-ng
EXPOSE 3142
VOLUME /var/cache/apt-cacher-ng
CMD ["apt-cacher-ng", "-c", "/etc/apt-cacher-ng", "ForeGround=1"]
EOF

docker stop apt-cache 2>/dev/null || true
docker rm apt-cache 2>/dev/null || true

docker build -t apt-cache "$BUILD_DIR"
docker run -d --name apt-cache -p 3142:3142 --restart=always \
    -v apt-cache-data:/var/cache/apt-cacher-ng apt-cache

echo "Stats: http://localhost:3142/acng-report.html"
