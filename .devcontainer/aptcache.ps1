$ErrorActionPreference = "Stop"

# Create build directory and Dockerfile
$buildDir = "$env:USERPROFILE\apt-cache"
New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
@"
FROM debian:bookworm-slim
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y apt-cacher-ng && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng && \
    chmod 755 /var/cache/apt-cacher-ng
EXPOSE 3142
VOLUME /var/cache/apt-cacher-ng
CMD ["apt-cacher-ng", "-c", "/etc/apt-cacher-ng", "ForeGround=1"]
"@ | Set-Content "$buildDir\Dockerfile"

# Cleanup existing
docker stop apt-cache 2>$null | Out-Null
docker rm apt-cache 2>$null | Out-Null

# Build and run
$wslPath = "/mnt/c" + ($buildDir -replace "C:", "" -replace "\\", "/")
wsl -e sh -c "HOME=/tmp docker build -q -t apt-cache $wslPath" | Out-Null
wsl -e sh -c "HOME=/tmp docker run -d --name apt-cache -p 3142:3142 --restart=always -v apt-cache-data:/var/cache/apt-cacher-ng apt-cache" | Out-Null

# Link to devcontainer.json
[System.Environment]::SetEnvironmentVariable("APT_PROXY", "http://host.docker.internal:3142", "User")
Write-Host "Stats: http://localhost:3142/acng-report.html"
