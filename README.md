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
1.  **Registry Component**: Hosted on Gaia (Manager), but accessible to the Swarm/Overlay network.
2.  **UI Component**: Exposed via Traefik (`registry.tienzo.net`) for human management.

## Prerequisites
*   Docker & Docker Compose
*   `ops-scripts` submodule initialized.

## Setup Instructions

### 1. Installation
```bash
git clone ...
git submodule update --init --recursive
cp .env.example .env
```

## Execution
```bash
./scripts/deploy.sh "hephaestus" docker-compose.yml
```

## Services
*   **registry**: The backend distribution server.
*   **registry-ui**: The frontend interface.
