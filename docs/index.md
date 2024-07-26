<style> a, a:hover, a:focus, a:active { text-decoration: none; color: #ba00ff; } </style>

## Overview

This project sets up a Docker container that automatically connects to a VPN using configuration files stored on
Pastebin and then runs a Privoxy service to provide a privacy-enhanced web proxy.

## Requirements

- Docker
- Pastebin API Developer Key
- Pastebin User Key
- Pastebin keys for the desired OpenVPN configuration files

## Running the Docker Container

You have three options to run the Docker container:

1. pulling the pre-built image from GitHub Container Registry
2. using Docker Compose
3. using plain Docker commands to build the image locally.

### Option 1: Pulling Pre-Built Image from GitHub Container Registry

1. **Configure Environment Variables**

   Create a file named `.env` and fill in the required information, or specify environment variables directly when
   running the container.

   ```sh
   PASTE_USER_KEY=<YOUR_PASTEBIN_USER_KEY>
   PASTE_DEV_KEY=<YOUR_PASTEBIN_DEV_KEY>
   PASTE_KEYS="<ovpn_paste_key1> <ovpn_paste_key2>..."
   ```

2. **Pull the Docker Image**

   ```sh
   docker pull ghcr.io/tal-sitton/proxy-vpn:latest
   ```

3. **Run the Docker Container**

   You can use either a `.env` file or specify environment variables directly with `-e`.

   Using `.env` file:

   ```sh
   docker run --privileged --dns 1.1.1.1 --env-file .env -p 8118:8118 ghcr.io/tal-sitton/proxy-vpn:latest
   ```

   Specifying environment variables directly:

   ```sh
   docker run --privileged --dns 1.1.1.1 -e PASTE_USER_KEY=<YOUR_PASTEBIN_USER_KEY> -e PASTE_DEV_KEY=<YOUR_PASTEBIN_DEV_KEY> -e PASTE_KEYS="<ovpn_paste_key1> <ovpn_paste_key2>..." -p 8118:8118 ghcr.io/tal-sitton/proxy-vpn:latest
   ```

### For Options 2 and 3:

1. **Clone the Repository**

   ```sh
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Configure Environment Variables**

   Copy the provided [.env.example](.env.example) to `.env` and fill in the required information.

   ```sh
   cp .env.example .env
   ```

   Edit `.env` and replace placeholders with your actual Pastebin keys.

   ```sh
   PASTE_USER_KEY=<YOUR_PASTEBIN_USER_KEY>
   PASTE_DEV_KEY=<YOUR_PASTEBIN_DEV_KEY>
   PASTE_KEYS="<ovpn_paste_key1> <ovpn_paste_key2>..."
   ```

### Option 2: Using Docker Compose

**Build and Run with Docker Compose**

   ```sh
   docker compose up --build
   ```

This command will build the Docker image and start the container as defined in
the [`docker-compose.yml`](docker-compose.yml) file.

### Option 3: Using Plain Docker Commands

1. **Build the Docker Image**

   build the docker image from [Dockerfile](Dockerfile)

   ```sh
   docker build -t proxy-vpn .
   ```

2. **Run the Docker Container**

   The container needs to run with `--privileged` and a specific DNS server to work correctly. You can use either
   a `.env` file or specify environment variables directly with `-e`.

   Using `.env` file:

   ```sh
   docker run --privileged --dns 1.1.1.1 --env-file .env -p 8118:8118 proxy-vpn
   ```

   Specifying environment variables directly:

   ```sh
   docker run --privileged --dns 1.1.1.1 -e PASTE_USER_KEY=<YOUR_PASTEBIN_USER_KEY> -e PASTE_DEV_KEY=<YOUR_PASTEBIN_DEV_KEY> -e PASTE_KEYS="<ovpn_paste_key1> <ovpn_paste_key2>..." -p 8118:8118 proxy-vpn
   ```

## How It Works

1. **Entrypoint Script**

   `entrypoint.sh`:
    - Enables IPv6.
    - Creates the necessary `/dev/net/tun` device.
    - Runs `vpn.sh` to connect to the VPN.
    - Starts the Privoxy service.

2. **VPN Script**

   `vpn.sh`:
    - Retrieves OpenVPN configuration files from Pastebin.
    - Attempts to connect to the VPN using one of the retrieved configuration files.
    - Verifies if the VPN connection is successful by checking the public IP address.

## Health Check

The Dockerfile includes a health check to ensure that Privoxy is running correctly. It tries to access a URL through the
proxy every 10 seconds.

```Dockerfile
HEALTHCHECK --interval=10s --timeout=10s --start-period=15s \
  CMD curl -x http://localhost:8118 -L https://wtfismyip.com/json
```

## Privoxy Configuration

The repo includes a Privoxy configuration file [privoxy-config](privoxy-config) that sets up the proxy server on
port 8118. You can modify this file to customize the Privoxy configuration.

## Notes

- The Docker container must run with the `--privileged` flag due to the need for creating a TUN device.
- Ensure the DNS server specified (1.1.1.1 in this case) is accessible and appropriate for your network setup.
