<p align="center"><img src="https://raw.githubusercontent.com/mendableai/firecrawl/main/img/firecrawl_logo.png" alt="Firecrawl Logo" width="300"></p>

# Firecrawl MCP Server

<p align="center">
  <a href="https://hub.docker.com/r/mekayelanik/firecrawl-mcp"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mekayelanik/firecrawl-mcp?style=flat-square&logo=docker"></a>
  <a href="https://hub.docker.com/r/mekayelanik/firecrawl-mcp"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/mekayelanik/firecrawl-mcp?style=flat-square&logo=docker"></a>
  <a href="https://github.com/mekayelanik/firecrawl-mcp-docker/pkgs/container/firecrawl-mcp"><img alt="GHCR" src="https://img.shields.io/badge/GHCR-ghcr.io%2Fmekayelanik%2Ffirecrawl-mcp-blue?style=flat-square&logo=github"></a>
  <a href="https://github.com/mekayelanik/firecrawl-mcp-docker/blob/main/LICENSE"><img alt="License: GPL-3.0" src="https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square"></a>
  <a href="https://hub.docker.com/r/mekayelanik/firecrawl-mcp"><img alt="Platforms" src="https://img.shields.io/badge/Platforms-amd64%20%7C%20arm64-lightgrey?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/firecrawl-mcp-docker/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/MekayelAnik/firecrawl-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/firecrawl-mcp-docker/forks"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/MekayelAnik/firecrawl-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/firecrawl-mcp-docker/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/MekayelAnik/firecrawl-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/firecrawl-mcp-docker/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/MekayelAnik/firecrawl-mcp-docker?style=flat-square"></a>
</p>

### Multi-Architecture Docker Image for Web Scraping & Crawling

---

## 📋 Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
- [Available Tags](#available-tags)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Configuration](#mcp-client-configuration)
- [Network Configuration](#network-configuration)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Support & License](#support--license)
- [Major Changes](#major-changes)

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
<a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
</a>
</p>

## Overview

Firecrawl MCP Server provides web scraping and crawling capabilities through the Model Context Protocol via the Firecrawl API. Built on Alpine Linux for minimal footprint and maximum security.

### Key Features

✨ **Multi-Architecture Support** - Native support for x86-64 and ARM64  
🚀 **Multiple Transport Protocols** - HTTP, SSE, and WebSocket support  
🔒 **Secure by Design** - Alpine-based with minimal attack surface  
⚡ **High Performance** - ZSTD compression for faster deployments  
🎯 **Production Ready** - Stable releases with comprehensive testing  
🔧 **Easy Configuration** - Simple environment variable setup

---

## Supported Architectures

| Architecture | Tag Prefix | Status |
|:-------------|:-----------|:------:|
| **x86-64** | `amd64-<version>` | ✅ Stable |
| **ARM64** | `arm64v8-<version>` | ✅ Stable |

> 💡 Multi-arch images automatically select the correct architecture for your system.

---

## Available Tags

| Tag | Stability | Description | Use Case |
|:----|:---------:|:------------|:---------|
| `stable` | ⭐⭐⭐ | Most stable release | **Recommended for production** |
| `latest` | ⭐⭐⭐ | Latest stable release | Stay current with stable features |
| `3.11.0` | ⭐⭐⭐ | Specific version | Version pinning for consistency |
| `beta` | ⚠️ | Beta releases | **Testing only** |

### System Requirements

- **Docker Engine:** 23.0+
- **RAM:** Minimum 512MB
- **CPU:** Single core sufficient

> 🔒 **CRITICAL:** Do NOT expose this container directly to the internet without proper security measures (reverse proxy, SSL/TLS, authentication, firewall rules).

---

## Quick Start

### Docker Compose (Recommended)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    container_name: firecrawl-mcp
    restart: unless-stopped
    ports:
      - "8016:8016"
    environment:
      - PORT=8016
      - INTERNAL_PORT=38011
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Dhaka
      - NODE_ENV=production
      - PROTOCOL=HTTP
      - ENABLE_HTTPS=false
      - HTTP_VERSION_MODE=auto
      # Optional: require Bearer token auth at HAProxy layer
      # - API_KEY=replace-with-strong-secret
    hostname: firecrawl-mcp
    domainname: local
```

**Deploy:**
```bash
docker compose up -d
docker compose logs -f firecrawl-mcp
```

### Docker CLI

```bash
docker run -d \
  --name=firecrawl-mcp \
  --restart=unless-stopped \
  -p 8016:8016 \
  -e PORT=8016 \
  -e INTERNAL_PORT=38011 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Dhaka \
  -e NODE_ENV=production \
  -e PROTOCOL=HTTP \
  -e ENABLE_HTTPS=false \
  -e HTTP_VERSION_MODE=auto \
  mekayelanik/firecrawl-mcp:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8016/mcp` | Best compatibility (recommended) |
| **SSE** | `http://host-ip:8016/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8016/message` | Bidirectional communication |

When HTTPS is enabled (`ENABLE_HTTPS=true`), use TLS endpoints:

| Protocol | Endpoint |
|:---------|:---------|
| **SHTTP** | `https://host-ip:8016/mcp` |
| **SSE** | `https://host-ip:8016/sse` |
| **WebSocket** | `wss://host-ip:8016/message` |

> ⚠️ **Security Warning:** The container now defaults to HTTP (`ENABLE_HTTPS=false`) for easier local setup. Use `ENABLE_HTTPS=true` for production, public networks, or any untrusted environment.
>
> ⏱️ **ARM Devices:** Allow 30-60 seconds for initialization before accessing endpoints.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `8016` | Internal server port |
| `INTERNAL_PORT` | `38011` | Internal MCP server port used by supergateway |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Asia/Dhaka` | Container timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `NODE_ENV` | `production` | Node.js environment |
| `PROTOCOL` | `SHTTP` | Default transport protocol |
| `API_KEY` | *(empty)* | Enables Bearer token auth (`Authorization: Bearer <API_KEY>`) |
| `CORS` | *(empty)* | Comma-separated CORS origins, supports `*` |
| `ENABLE_HTTPS` | `false` | Enables TLS termination in HAProxy |
| `TLS_CERT_PATH` | `/etc/haproxy/certs/server.crt` | TLS cert path |
| `TLS_KEY_PATH` | `/etc/haproxy/certs/server.key` | TLS private key path |
| `TLS_PEM_PATH` | `/etc/haproxy/certs/server.pem` | Combined PEM file used by HAProxy |
| `TLS_CN` | `localhost` | CN for auto-generated certificate |
| `TLS_SAN` | `DNS:<TLS_CN>` | SAN for auto-generated certificate |
| `TLS_DAYS` | `365` | Auto-generated cert validity period |
| `TLS_MIN_VERSION` | `TLSv1.3` | Minimum TLS protocol (`TLSv1.2` or `TLSv1.3`) |
| `HTTP_VERSION_MODE` | `auto` | `auto`, `all`, `h1`, `h2`, `h3`, `h1+h2` |
| `DEBUG_MODE` | *(empty)* | Enables debug hold mode when set truthy |

### HTTPS and HTTP Version Notes

- If `ENABLE_HTTPS=true` and cert files are missing, the container auto-generates a self-signed certificate.
- If `TLS_CERT_PATH` and `TLS_KEY_PATH` exist, they are merged into `TLS_PEM_PATH` and used directly.
- `HTTP_VERSION_MODE=h3` (or `auto`) enables HTTP/3 only when HAProxy build includes QUIC; otherwise it safely falls back.

### API Key Authentication Notes

- Set `API_KEY` to enforce authentication at reverse proxy level.
- Expected header format: `Authorization: Bearer <API_KEY>`.
- Localhost health checks remain accessible for liveness/readiness.

### User & Group IDs

Find your IDs and set them to avoid permission issues:

```bash
id username
# uid=1000(user) gid=1000(group)
```

### Timezone Examples

```yaml
- TZ=Asia/Dhaka        # Bangladesh
- TZ=America/New_York  # US Eastern
- TZ=Europe/London     # UK
- TZ=UTC               # Universal Time
```

---

## MCP Client Configuration

### Transport Support

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | ✅ | ✅ | ❌ | HTTP |
| **Claude Desktop** | ✅ | ✅ | ⚠️* | HTTP |
| **Claude CLI** | ✅ | ✅ | ⚠️* | HTTP |
| **Codex CLI** | ✅ | ✅ | ⚠️* | HTTP |
| **Codeium (Windsurf)** | ✅ | ✅ | ⚠️* | HTTP |
| **Cursor** | ✅ | ✅ | ⚠️* | HTTP |

> ⚠️ *WebSocket is experimental ([Issue #1288](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1288))

---

### VS Code (Cline/Roo-Cline)

Configure in `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "firecrawl": {
      "url": "http://host-ip:8016/mcp",
      "transport": "http"
    }
  }
}
```

---

### Claude Desktop App/Claude Code

**Configuration:**
### **With API_KEY**
```
claude mcp add-json github '{"type":"http","url":"http://localhost:8045/mcp","headers":{"Authorization":"Bearer <YOUR_API_KEY>"}}'
```
### **Without API_KEY**
```
claude mcp add-json github '{"type":"http","url":"http://localhost:8045/mcp"}'
```

---

### Codex CLI

Configure in `~/.codex/config.json`:

```json
{
  "mcpServers": {
    "firecrawl": {
      "transport": "http",
      "url": "http://host-ip:8016/mcp"
    }
  }
}
```

---

### Codeium (Windsurf)

Configure in `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "firecrawl": {
      "transport": "http",
      "url": "http://host-ip:8016/mcp"
    }
  }
}
```

---

### Cursor

Configure in `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "firecrawl": {
      "transport": "http",
      "url": "http://host-ip:8016/mcp"
    }
  }
}
```

---

### Testing Configuration

Verify with [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```bash
npm install -g @modelcontextprotocol/inspector
mcp-inspector http://host-ip:8016/mcp
```

---

## Network Configuration

### Comparison

| Network Mode | Complexity | Performance | Use Case |
|:-------------|:----------:|:-----------:|:---------|
| **Bridge** | ⭐ Easy | ⭐⭐⭐ Good | Default, isolated |
| **Host** | ⭐⭐ Moderate | ⭐⭐⭐⭐ Excellent | Direct host access |
| **MACVLAN** | ⭐⭐⭐ Advanced | ⭐⭐⭐⭐ Excellent | Dedicated IP |

---

### Bridge Network (Default)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    ports:
      - "8016:8016"
```

**Benefits:** Container isolation, easy setup, works everywhere
**Access:** `http://localhost:8016/mcp`

---

### Host Network (Linux Only)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    network_mode: host
```

**Benefits:** Maximum performance, no NAT overhead, no port mapping needed
**Considerations:** Linux only, shares host network namespace
**Access:** `http://localhost:8016/mcp`

---

### MACVLAN Network (Advanced)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    mac_address: "AB:BC:CD:DE:EF:01"
    networks:
      macvlan-net:
        ipv4_address: 192.168.1.100

networks:
  macvlan-net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

**Benefits:** Dedicated IP, direct LAN access
**Considerations:** Linux only, requires additional setup
**Access:** `http://192.168.1.100:8016/mcp`

---

## Updating

### Docker Compose

```bash
docker compose pull
docker compose up -d
docker image prune -f
```

### Docker CLI

```bash
docker pull mekayelanik/firecrawl-mcp:stable
docker stop firecrawl-mcp && docker rm firecrawl-mcp
# Run your original docker run command
docker image prune -f
```

### One-Time Update with Watchtower

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once \
  firecrawl-mcp
```

---

## Troubleshooting

### Pre-Flight Checklist

- ✅ Docker Engine 23.0+
- ✅ Port 8016 available
- ✅ Sufficient startup time (ARM devices)
- ✅ Latest stable image
- ✅ Correct configuration

### Common Issues

#### Container Won't Start

```bash
# Check Docker version
docker --version

# Verify port availability
sudo netstat -tulpn | grep 8016

# Check logs
docker logs firecrawl-mcp
```

#### Permission Errors

```bash
# Get your IDs
id $USER

# Update configuration with correct PUID/PGID
# Fix volume permissions if needed
sudo chown -R 1000:1000 /path/to/volume
```

#### Client Cannot Connect

```bash
# Test connectivity
curl http://localhost:8016/mcp
curl http://host-ip:8016/mcp
curl -k https://localhost:8016/mcp
curl -k https://host-ip:8016/mcp

# Check firewall
sudo ufw status

# Verify container
docker inspect firecrawl-mcp | grep IPAddress
```

#### Slow ARM Performance

- Wait 30-60 seconds after start
- Monitor: `docker logs -f firecrawl-mcp`
- Check resources: `docker stats firecrawl-mcp`
- Use faster storage (SSD vs SD card)

### Debug Information

When reporting issues, include:

```bash
# System info
docker --version && uname -a

# Container logs
docker logs firecrawl-mcp --tail 200 > logs.txt

# Container config
docker inspect firecrawl-mcp > inspect.json
```

---

## Additional Resources

### Documentation
- 📚 [Firecrawl Official Docs](https://github.com/nicholasgriffintn/firecrawl-mcp)
- 📦 [NPM Package](https://www.npmjs.com/package/firecrawl-mcp)
- 🔧 [MCP Inspector](https://github.com/modelcontextprotocol/inspector)

### Docker Resources
- 🐳 [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- 🌐 [Docker Networking](https://docs.docker.com/network/)
- 🛡️ [Docker Security](https://docs.docker.com/engine/security/)

### Monitoring
- 📊 [Diun - Update Notifier](https://crazymax.dev/diun/)
- ⚡ [Watchtower](https://containrrr.dev/watchtower/)

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
  <a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
  </a>
</p>

## Support & License

### Getting Help

**Docker Image Issues:**
- GitHub: [firecrawl-mcp-docker/issues](https://github.com/MekayelAnik/firecrawl-mcp/issues)

**Firecrawl MCP Issues:**
- GitHub: [nicholasgriffintn/firecrawl-mcp/issues](https://github.com/nicholasgriffintn/firecrawl-mcp/issues)
- Website: [firecrawl.dev](https://firecrawl.dev/)

### Contributing

We welcome contributions:
1. Report bugs via GitHub Issues
2. Suggest features
3. Improve documentation
4. Test beta releases

### License

GPL License. See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/firecrawl-mcp-docker/refs/heads/main/LICENSE) for details.

Firecrawl MCP server has its own license - see [Main NPM repo](https://github.com/nicholasgriffintn/firecrawl-mcp).

---

### Major Changes

<ul>
  <li><strong>Initial Release:</strong> Full CI/CD pipeline with HAProxy, HTTPS/TLS, QUIC/HTTP3, API key auth</li>
</ul>

<p></p>

<div align="center">

[⬆ Back to Top](#firecrawl-mcp-server)

</div>
