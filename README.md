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
    *   **Internal URL**: `http://registry:5000` (Swarm Network).
    *   **No Auth**: Configured for internal trust (Network isolation).
    *   **Proxy**: Accessed via `registry-ui` (which acts as a reverse proxy).
2.  **Registry UI**:
    *   **External URL**: `https://registry-ui.<DOMAIN_NAME>`
    *   **Security**: Protected by **Authelia** (Single Sign-On).
    *   **Function**: Acts as both UI and API Proxy (via `NGINX_PROXY_PASS_URL`).

## Prerequisites
*   Docker Swarm Cluster
*   Traefik Proxy (External) & Authelia
*   `ops-scripts` submodule initialized.

## Setup Instructions

### 1. Host Preparation
Ensure the storage directory exists on the host (Manager Node):
```bash
./setup_host.sh
```

### 2. Deployment
```bash
./scripts/deploy.sh "hephaestus" docker-compose.yml
```

## Services
*   **registry**: The backend distribution server (v2).
    *   *Storage*: `/mnt/storage/registry` (Host Bind Mount).
    *   *Network*: `aether-net`, `internal`.
*   **registry-ui**: The frontend interface by `joxit`.
    *   *Network*: `aether-net`, `internal` (to reach registry).
    *   *Auth*: Middleware `authelia@docker`.
    *   *Proxy*: Forwards API requests to `http://registry:5000`.

## Troubleshooting
*   **Pushing Images**:
    To push images, you can still access the registry directly if you expose it, or use the internal service name `registry:5000` from within the cluster.
    ```bash
    docker tag my-image registry.<DOMAIN_NAME>/my-image:latest
    docker push registry.<DOMAIN_NAME>/my-image:latest
    ```
