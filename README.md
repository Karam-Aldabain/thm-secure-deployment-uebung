# Übungsblatt 2 - Secure Deployment
Karam Aldabain | Aufgabenblatt: 1. November 2026

Windows: Docker Desktop (Linux containers / WSL 2), PowerShell, Git;
GitHub CLI for repository creation. Start Docker Desktop first.
All commands below run from this folder.

## HTTPS
Run `powershell -ExecutionPolicy Bypass -File .\setup-https.ps1`.
In an administrator editor, add `127.0.0.1 thm.de` to
`C:\Windows\System32\drivers\etc\hosts`, then `ipconfig /flushdns`.
Run `curl.exe -k --noproxy "*" https://thm.de/`.
Expected: `HTTPS fuer thm.de funktioniert.`
Self-signed local lab certificate; -k disables validation for this test only.
No public DNS change. Delete the hosts entry after the exercise.
Use `docker compose exec https openssl x509 -in /etc/nginx/certs/thm.crt -noout -ext subjectAltName`
to inspect the certificate name. Private keys are gitignored.

## App
```powershell
docker build -t uebung2-app:local ./src
$appFile = (Resolve-Path .\src\app.txt).Path
docker run -d --name uebung2-app -p 127.0.0.1:5000:5000 --mount "type=bind,source=$appFile,target=/data/app.txt,readonly" uebung2-app:local
curl.exe --noproxy "*" http://localhost:5000/
docker exec uebung2-app id -u
```
Expected body: `<p>sse</p>`; expected UID: `10001`.
Alternative: `docker compose up -d --build app` (do not run both on port 5000).
Original server changed only from debug=True to debug=False.
Original requirements retained: numpy, matplotlib, flask (not pinned).
This uses Flask's development server for the local exercise, not production hosting.

## GitHub
Repository: https://github.com/Karam-Aldabain/thm-secure-deployment-uebung

The workflow runs on pushes to main. It builds the Debian app image, checks
UID 10001 and the HTTP response, tests NGINX HTTPS, then publishes to
`ghcr.io/karam-aldabain/thm-secure-deployment-uebung` using SHA and latest tags.
GitHub supplies GITHUB_TOKEN. No token or private TLS key belongs in source control.

## Verification
See the repository Actions tab for the actual result of each build.
The Windows commands still need to be run locally; CI runs Linux containers
on an Ubuntu runner and does not verify the Windows hosts-file configuration.

## Cleanup
`docker rm -f uebung2-app`; `docker compose down`.
Remove only the `127.0.0.1 thm.de` hosts entry added for this exercise.
