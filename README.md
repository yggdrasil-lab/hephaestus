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
    *   **External URL**: `https://registry.<DOMAIN_NAME>`
    *   **Public Access**: Anonymous Pulls enabled (`docker pull ...`).
    *   **Private Access**: Push/Write operations protected by basic auth (`htpasswd`).
    *   **Internal URL**: `http://registry:5000` (Swarm Network).
2.  **Registry UI**:
    *   **External URL**: `https://registry-ui.<DOMAIN_NAME>`
    *   **Public Access**: Read-Only "Library Check Mode".
    *   **Mechanism**: The UI proxies requests to `http://registry:5000` across the internal overlay network. Anonymous catalog read access is enabled on the registry backend (`REGISTRY_AUTH_ANONYMOUS_ENABLED: "true"`).
    *   **Safety**: HTTP Methods are strictly limited to `GET`, `HEAD`, `OPTIONS` via Traefik to prevent unauthorized modification or deletion.

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

### 2. Secrets Configuration
The following secret must be available in GitHub Actions (or manually created in Swarm):

| Secret Name | Description |
|---|---|
| `REGISTRY_HTPASSWD` | The contents of an `htpasswd` file (e.g., `admin:HASH`). Required for push/write authentication. |

### 3. Deployment
```bash
./scripts/deploy.sh "hephaestus" docker-compose.yml
```

## Services
*   **registry**: The backend distribution server (v2).
    *   *Storage*: `/mnt/storage/registry` (Host Bind Mount).
    *   *Network*: `aether-net`, `internal`.
    *   *Features*: In-memory blob descriptor cache, manifest deletion enabled.
*   **registry-ui**: The frontend interface by `joxit`.
    *   *Network*: `aether-net`, `internal` (to reach registry).
    *   *Proxy*: Forwards API requests to `http://registry:5000`.

## Maintenance & Troubleshooting
*   **Garbage Collection**:
    Docker Registry v2 does not reclaim disk storage automatically when tags are overwritten. To prune untagged manifests and orphaned blobs:
    ```bash
    CID=$(docker ps -q --filter label=com.docker.swarm.service.name=hephaestus_registry)
    docker exec "$CID" registry garbage-collect /etc/docker/registry/config.yml -m
    ```
*   **UI Nginx Error "host not found in upstream"**:
    *   This occurs if the internal Nginx proxy tries to resolve the `registry` hostname before the container is fully available in Swarm DNS.
    *   **Fix**: Ensure `NGINX_RESOLVER=127.0.0.11` is set in the environment variables. This forces Nginx to use the Docker embedded DNS resolver at runtime.
*   **Pushing Images**:
    To push images, access the registry directly using your credentials:
    ```bash
    docker tag my-image registry.<DOMAIN_NAME>/my-image:latest
    docker push registry.<DOMAIN_NAME>/my-image:latest
    ```
