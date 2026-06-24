# Sample Node.js POC Project

This repository contains a proof-of-concept Express app with production-ready Docker and Kubernetes deployment, backed by a Jenkins CI/CD pipeline.
node-js-app/
├── app.js
├── app.test.js
├── Dockerfile
├── Jenkinsfile
├── setup-ubuntu.sh
├── package.json
├── package-lock.json
├── .env
├── .dockerignore
├── .gitignore
├── .gitattributes
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── registry-secret.yaml
└── readme.mdnode-js-app/
├── app.js
├── app.test.js
├── Dockerfile
├── Jenkinsfile
├── setup-ubuntu.sh
├── package.json
├── package-lock.json
├── .env
├── .dockerignore
├── .gitignore
├── .gitattributes
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── registry-secret.yaml
└── readme.md
## Files included

- `app.js` — primary Express application.
- `Dockerfile` — multi-stage production image.
- `.dockerignore` — files excluded from Docker build context.
- `.env` — environment variable file.
- `Jenkinsfile` — CI/CD pipeline for build, test, push, and deploy.
- `deployment.yaml`, `service.yaml`, `configmap.yaml` — Kubernetes deployment resources.

## Project structure

```text
node-js-app/
├── app.js
├── app.test.js
├── Dockerfile
├── Jenkinsfile
├── setup-ubuntu.sh
├── package.json
├── package-lock.json
├── .env
├── .dockerignore
├── .gitignore
├── .gitattributes
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── registry-secret.yaml
└── readme.md
```

## Ubuntu prerequisites

Install the Linux tools required to run the app and the CI/CD workflow.

```bash
sudo apt update
sudo apt install -y nodejs npm docker.io gettext-base kubectl
sudo systemctl enable --now docker
```

If you are running Docker commands without sudo, add your user to the Docker group:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

Or run the provided Ubuntu setup script:

```bash
sudo ./setup-ubuntu.sh
```

## Local development

1. Ensure `.env` is present with the required values.
2. Install dependencies:

```bash
npm ci
```

3. Start locally:

```bash
npm start
```

4. Run tests:

```bash
npm test
```

5. Open:

```text
http://localhost:3000/
```

## Environment variables

Use `.env` for local development and inject environment variables in production.

Example values are in `.env`:

```text
PORT=3000
NODE_ENV=production
APP_NAME=node-js-app
WELCOME_MESSAGE=CI/CD Pipeline Working Successfully
IMAGE_NAME=kawalepankaj/node-js-app
```

## Docker

Build the image:

```bash
docker build -t kawalepankaj/node-js-app:latest .
```

Login to Docker Hub:

```bash
docker login -u kawalepankaj
```

Push the image with your tag:

```bash
docker push kawalepankaj/node-js-app:latest
# or push a custom tag:
# docker push kawalepankaj/node-js-app:tagname
```

Run the container:

```bash
docker run -d --rm -p 3000:3000 --name node-js-app \
  -e PORT=3000 \
  -e NODE_ENV=production \
  -e APP_NAME=node-js-app \
  -e WELCOME_MESSAGE="CI/CD Pipeline Working Successfully" \
  kawalepankaj/node-js-app:latest
```

## Kubernetes

If your cluster does not support a LoadBalancer service type, this repo now uses a `NodePort` service on port `30080`.

Create a private registry secret if your image is hosted in a private Docker registry:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email>
```

Docker login to Docker Hub:

```bash
docker login -u kawalepankaj
```

Enter your Docker Hub password or personal access token when prompted.

Create the Kubernetes image pull secret if you want to avoid storing it in a manifest:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=kawalepankaj \
  --docker-password=<YOUR_DOCKER_PASSWORD_OR_TOKEN> \
  --docker-email=<YOUR_EMAIL>
```

Then apply resources:

```bash
kubectl apply -f configmap.yaml
kubectl apply -f registry-secret.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check rollout status:

```bash
kubectl rollout status deployment/node-js-app
```

To access the app from a node:

```bash
http://<node-ip>:30080/
```

## Jenkins CI/CD

The `Jenkinsfile` performs:

1. checkout
2. `npm ci` and `npm test`
3. Docker image build and push with `IMAGE_TAG`
4. Kubernetes deploy using `kubectl`

The build supports an optional Jenkins parameter named `IMAGE_TAG`. If it is left blank, the pipeline defaults to the current `BUILD_NUMBER`.

Make sure Jenkins has:

- Docker installed and able to push to Docker Hub
- `dockerhub-creds` configured as username/password credentials
- Kubernetes credentials available to `kubectl`

## Application endpoints

- `GET /` — welcome message
- `GET /health` — health check endpoint

## Notes

- `.env` is ignored by git.
- update `kawalepankaj/node-js-app` with your Docker Hub repository.
- use `configmap.yaml` for environment configuration in Kubernetes.
    