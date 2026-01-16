# Hephaestus (The Forge)
> I am **Hephaestus**, the Blacksmith of the Yggdrasil ecosystem. My domain is the **Registry**, the **Pipeline**, and the **Build**. I forge the tools that allow others to create.

## Mission
To establish a self-hosted, sovereign software supply chain. I provide the Docker Registry that allows custom images (like `charon-archive`) to be distributed across the swarm, breaking the dependency on external hubs or local caches.

## Core Philosophy
1.  **Sovereignty:** We own our tools. We own our images.
2.  **Reliability:** The build must work. The image must pull. Every time.

---

## Tech Stack
*   **Docker Registry (v2)**: The core distribution server.
*   **Docker Registry UI**: A lightweight web interface for browsing repositories.
*   **Authelia**: SSO protection for accessing the registry UI and API.

## Architecture
1.  **Registry Backend**:
    *   **Internal URL**: `http://registry:5000` (Swarm Network) or `https://registry.<DOMAIN_NAME>` (Traefik Loopback).
    *   **No Auth**: Currently configured for internal trust. Relies on Network isolation and Split-DNS.
    *   **CORS**: Configured via Traefik Middleware to allow `registry-ui` to access it.
2.  **Registry UI**:
    *   **External URL**: `https://registry-ui.<DOMAIN_NAME>`
    *   **Security**: Protected by **Authelia** (Single Sign-On). Only authenticated users can browse or delete images.

## Prerequisites
*   Docker Swarm Cluster
*   Traefik Proxy (External) & Authelia (Optional but recommended for UI)
*   `ops-scripts` submodule initialized.

## Setup Instructions

### 1. Host Preparation
Ensure the storage directory exists on the host (Manager Node):
```bash
./setup_host.sh
```

### 2. Deployment
Because this stack uses Traefik middleware for CORS, ensure your Traefik instance is up and running.

```bash
./scripts/deploy.sh "hephaestus" docker-compose.yml
```

## Services
*   **registry**: The backend distribution server (v2).
    *   *Storage*: `/mnt/storage/registry` (Host Bind Mount).
    *   *Network*: `aether-net` (Public/Swarm), `internal` (Backend).
    *   *Port*: 5000.
*   **registry-ui**: The frontend interface by `joxit`.
    *   *Network*: `aether-net`.
    *   *Auth*: Middleware `authelia@docker`.

## Troubleshooting
*   **CORS Errors in UI**: If you see "Access-Control-Allow-Origin" errors, ensure the Traefik Middleware `registry-cors` is correctly applied to the `registry` router.
*   **Pushing Images**:
    ```bash
    docker tag my-image registry.<DOMAIN_NAME>/my-image:latest
    docker push registry.<DOMAIN_NAME>/my-image:latest
    ```
    *Note: If pushing from outside the cluster, ensure DNS resolves to your Traefik IP.*
