$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force .\https\certs | Out-Null
docker build -t thm-https:local ./https
if ($LASTEXITCODE -ne 0) { throw "HTTPS image build failed" }
$certs = (Resolve-Path .\https\certs).Path
docker run --rm --mount "type=bind,source=$certs,target=/certs" `
  thm-https:local openssl req -x509 -nodes -newkey rsa:3072 `
  -sha256 -days 365 -keyout /certs/thm.key -out /certs/thm.crt `
  -subj "/CN=thm.de" -addext "subjectAltName=DNS:thm.de"
if ($LASTEXITCODE -ne 0) { throw "Certificate generation failed" }
docker compose up -d --build https
if ($LASTEXITCODE -ne 0) { throw "HTTPS startup failed" }
docker compose exec https nginx -t
if ($LASTEXITCODE -ne 0) { throw "NGINX validation failed" }
