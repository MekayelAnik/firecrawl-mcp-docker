# Firecrawl MCP Server
### Multi-Architecture Docker Image for Distributed Deployment

<div align="left">

<img alt="firecrawl-mcp" src="https://img.shields.io/badge/Firecrawl-MCP-FF6B6B?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMiA3TDEyIDEyTDIyIDdMMTIgMloiIGZpbGw9IndoaXRlIi8+CjxwYXRoIGQ9Ik0yIDEyTDEyIDE3TDIyIDEyIiBzdHJva2U9IndoaXRlIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIvPgo8cGF0aCBkPSJNMiAxN0wxMiAyMkwyMiAxNyIgc3Ryb2tlPSJ3aGl0ZSIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz4KPC9zdmc+&logoColor=white" width="400">

[![Docker Pulls](https://img.shields.io/docker/pulls/mekayelanik/firecrawl-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/firecrawl-mcp)
[![Docker Stars](https://img.shields.io/docker/stars/mekayelanik/firecrawl-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/firecrawl-mcp)
[![License](https://img.shields.io/badge/license-GPL-blue.svg?style=flat-square)](https://raw.githubusercontent.com/MekayelAnik/firecrawl-mcp-docker/refs/heads/main/LICENSE)

**[Official Website](https://www.firecrawl.dev/)** • **[Documentation](https://github.com/mendableai/firecrawl)** • **[Docker Hub](https://hub.docker.com/r/mekayelanik/firecrawl-mcp)**

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
- [Available Tags](#available-tags)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Configuration](#mcp-client-configuration)
- [Network Configuration](#network-configuration)
- [Firecrawl Tools](#firecrawl-tools)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Support & License](#support--license)

---

## Overview

Firecrawl MCP Server is a powerful web scraping and content extraction Model Context Protocol server with enterprise-grade features. Built on Alpine Linux for a minimal footprint and maximum security, it provides comprehensive web data extraction capabilities. This can be used with AI IDEs (VS Code, Claude CLI, Codex, Cursor, etc.), AI clients (Ollama, LM Studio, VLLM, etc.), or directly in RAG applications.

### Key Features

✨ **Multi-Architecture Support** - Native support for x86-64 and ARM64  
🚀 **Multiple Transport Protocols** - HTTP, SSE, and WebSocket support  
🔥 **Advanced Web Scraping** - Single page, batch, crawl, and search capabilities  
🎯 **Structured Data Extraction** - LLM-powered content extraction with schemas  
🔄 **Automatic Retries** - Exponential backoff with configurable retry logic  
📊 **Credit Monitoring** - Built-in usage tracking and alerts  
🔒 **Secure by Design** - Alpine-based with minimal attack surface  
⚡ **High Performance** - Parallel processing and rate limiting  
🛡️ **Production Ready** - Stable releases with comprehensive testing

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
| `3.0.x` | ⭐⭐⭐ | Specific version | Version pinning for consistency |
| `beta` | ⚠️ | Beta releases | **Testing only** |

### System Requirements

- **Docker Engine:** 23.0+
- **RAM:** Minimum 512MB
- **CPU:** Single core sufficient
- **Firecrawl API Key:** Required (obtain from [firecrawl.dev](https://www.firecrawl.dev/app/api-keys))

> 🔐 **CRITICAL:** Do NOT expose this container directly to the internet without proper security measures (reverse proxy, SSL/TLS, authentication, firewall rules).

---

## Quick Start

### Obtaining API Key

**Required:** You must have a Firecrawl API key to use this server.

1. Visit [https://www.firecrawl.dev/app/api-keys](https://www.firecrawl.dev/app/api-keys)
2. Create an account if you don't have one
3. Generate a new API key (starts with `fc-`)

### Docker Compose (Recommended)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    container_name: firecrawl-mcp
    restart: unless-stopped
    ports:
      - "8030:8030"
    environment:
      # REQUIRED: Your Firecrawl API key
      - FIRECRAWL_API_KEY=fc-your-api-key-here
      
      # Basic Configuration
      - PORT=8030
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Dhaka
      - NODE_ENV=production
      - PROTOCOL=SHTTP
      
      # Optional: Self-hosted instance
      # - FIRECRAWL_API_URL=https://firecrawl.your-domain.com
      
      # Optional: Retry Configuration (defaults shown)
      # - FIRECRAWL_RETRY_MAX_ATTEMPTS=3
      # - FIRECRAWL_RETRY_INITIAL_DELAY=1000
      # - FIRECRAWL_RETRY_MAX_DELAY=10000
      # - FIRECRAWL_RETRY_BACKOFF_FACTOR=2
      
      # Optional: Credit Monitoring (defaults shown)
      # - FIRECRAWL_CREDIT_WARNING_THRESHOLD=1000
      # - FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=100
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
  -p 8030:8030 \
  -e FIRECRAWL_API_KEY=fc-your-api-key-here \
  -e PORT=8030 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Dhaka \
  -e NODE_ENV=production \
  -e PROTOCOL=SHTTP \
  mekayelanik/firecrawl-mcp:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8030/mcp` | Best compatibility (recommended) |
| **SSE** | `http://host-ip:8030/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8030/message` | Bidirectional communication |

> ⏱️ **ARM Devices:** Allow 30-60 seconds for initialization before accessing endpoints.

---

## Configuration

### Environment Variables

#### Required Configuration

| Variable | Required | Description |
|:---------|:--------:|:------------|
| `FIRECRAWL_API_KEY` | **YES** | Your Firecrawl API key (starts with `fc-`) |

#### Basic Configuration

| Variable | Default | Description | OPTIONS |
|:---------|:-------:|:------------|:-------|
| `PORT` | `8030` | Internal server port | Any Valid Port |
| `PUID` | `1000` | User ID for file permissions | Any valid UNIX user's UID |
| `PGID` | `1000` | Group ID for file permissions | Any valid UNIX Group's GID |
| `TZ` | `Asia/Dhaka` | Any valid UNIX Timezone | UNIX timezones ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `NODE_ENV` | `production` | Node.js environment | `production` or `test` or `development` |
| `PROTOCOL` | `SHTTP` | Default transport protocol |`SHTTP` (For Streamable HTTP transport) or `SSE` (For Server-Sent Events (SSE) transport) or `WS` (For WebSocket (WS) transport)  |

#### Optional: Self-Hosted Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `FIRECRAWL_API_URL` | Cloud API | Custom API endpoint for self-hosted instances |

#### Optional: Retry Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `FIRECRAWL_RETRY_MAX_ATTEMPTS` | `3` | Maximum number of retry attempts |
| `FIRECRAWL_RETRY_INITIAL_DELAY` | `1000` | Initial delay before first retry (ms) |
| `FIRECRAWL_RETRY_MAX_DELAY` | `10000` | Maximum delay between retries (ms) |
| `FIRECRAWL_RETRY_BACKOFF_FACTOR` | `2` | Exponential backoff multiplier |

#### Optional: Credit Monitoring

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `FIRECRAWL_CREDIT_WARNING_THRESHOLD` | `1000` | Warn when credits reach this level |
| `FIRECRAWL_CREDIT_CRITICAL_THRESHOLD` | `100` | Critical alert at this credit level |

### Advanced Configuration Examples

#### Cloud API with Custom Retry Logic

```yaml
environment:
  - FIRECRAWL_API_KEY=fc-your-api-key-here
  - FIRECRAWL_RETRY_MAX_ATTEMPTS=5
  - FIRECRAWL_RETRY_INITIAL_DELAY=2000
  - FIRECRAWL_RETRY_MAX_DELAY=30000
  - FIRECRAWL_RETRY_BACKOFF_FACTOR=3
```

#### Self-Hosted Instance

```yaml
environment:
  - FIRECRAWL_API_KEY=your-instance-key
  - FIRECRAWL_API_URL=https://firecrawl.your-domain.com
  - FIRECRAWL_RETRY_MAX_ATTEMPTS=10
```

#### Production with Aggressive Monitoring

```yaml
environment:
  - FIRECRAWL_API_KEY=fc-your-api-key-here
  - FIRECRAWL_CREDIT_WARNING_THRESHOLD=2000
  - FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=500
```

---

## MCP Client Configuration

### Transport Support

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | ✅ | ✅ | ❌ | HTTP |
| **Claude Desktop** | ✅ | ✅ | ⚠️* | HTTP |
| **Cursor** | ✅ | ✅ | ⚠️* | HTTP |
| **Windsurf (Codeium)** | ✅ | ✅ | ⚠️* | HTTP |

> ⚠️ *WebSocket is experimental

---

### VS Code (Cline/Roo-Cline)

Configure in `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "firecrawl": {
      "url": "http://host-ip:8030/mcp",
      "transport": "http"
    }
  }
}
```

---

### Claude Desktop App

**Config Locations:**
- **Linux:** `~/.config/Claude/claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

**Configuration:**
```json
{
  "mcpServers": {
    "firecrawl": {
      "transport": "http",
      "url": "http://localhost:8030/mcp"
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
      "url": "http://host-ip:8030/mcp"
    }
  }
}
```

---

### Windsurf (Codeium)

Configure in `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "firecrawl": {
      "transport": "http",
      "url": "http://host-ip:8030/mcp"
    }
  }
}
```

---

### Auto-Approve Tool List

To enable auto-approval in your MCP client, add these tools:

```json
{
  "autoApprove": [
    "firecrawl_scrape",
    "firecrawl_batch_scrape",
    "firecrawl_check_batch_status",
    "firecrawl_map",
    "firecrawl_search",
    "firecrawl_crawl",
    "firecrawl_check_crawl_status",
    "firecrawl_extract"
  ]
}
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
      - "8030:8030"
```

**Access:** `http://localhost:8030/mcp`

---

### Host Network (Linux Only)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
    network_mode: host
```

**Access:** `http://localhost:8030/mcp`

---

### MACVLAN Network (Advanced)

```yaml
services:
  firecrawl-mcp:
    image: mekayelanik/firecrawl-mcp:stable
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
```

**Access:** `http://192.168.1.100:8030/mcp`

---

## Firecrawl Tools

### Tool Selection Guide

| Scenario | Recommended Tool |
|:---------|:----------------|
| Single known URL | `firecrawl_scrape` |
| Multiple known URLs | `firecrawl_batch_scrape` |
| Discover site URLs | `firecrawl_map` |
| Search the web | `firecrawl_search` |
| Extract structured data | `firecrawl_extract` |
| Full site analysis | `firecrawl_crawl` (with limits) |

### Available Tools

#### 1. Scrape (`firecrawl_scrape`)
Extract content from a single URL with advanced options.

**Best for:** Single page content extraction  
**Example:** "Get the content from https://example.com"

#### 2. Batch Scrape (`firecrawl_batch_scrape`)
Scrape multiple URLs efficiently with parallel processing.

**Best for:** Multiple known pages  
**Example:** "Get content from these 5 blog posts"

#### 3. Map (`firecrawl_map`)
Discover all indexed URLs on a website.

**Best for:** URL discovery before scraping  
**Example:** "List all URLs on example.com"

#### 4. Search (`firecrawl_search`)
Search the web and extract content from results.

**Best for:** Finding information across websites  
**Example:** "Find recent AI research papers"

#### 5. Crawl (`firecrawl_crawl`)
Asynchronous crawl job for comprehensive site extraction.

**Best for:** Multi-page comprehensive extraction  
**Warning:** Can be large - use limits to avoid token overflow

#### 6. Extract (`firecrawl_extract`)
LLM-powered structured data extraction with schemas.

**Best for:** Structured data like prices, names, specs  
**Example:** "Extract product details from these pages"

#### 7. Check Batch Status (`firecrawl_check_batch_status`)
Monitor batch operation progress.

#### 8. Check Crawl Status (`firecrawl_check_crawl_status`)
Monitor crawl job progress.

### Rate Limiting & Performance

- Automatic rate limit handling with exponential backoff
- Efficient parallel processing for batch operations
- Smart request queuing and throttling
- Configurable retry logic with monitoring

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

### Watchtower (One-Time)

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
- ✅ Valid Firecrawl API key
- ✅ Port 8030 available
- ✅ Sufficient startup time
- ✅ Latest stable image

### Common Issues

#### Container Won't Start - Missing API Key

```bash
# Check logs for API key error
docker logs firecrawl-mcp

# Error message: "FIRECRAWL_API_KEY environment variable is REQUIRED"
# Solution: Add your API key to the environment variables
```

#### Invalid API Key Format

```bash
# Warning: "API key doesn't match expected format"
# Solution: Ensure your key starts with 'fc-'
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
curl http://localhost:8030/mcp
curl http://host-ip:8030/mcp

# Check firewall
sudo ufw status

# Verify container
docker inspect firecrawl-mcp | grep IPAddress
```

#### Rate Limiting Issues

Check logs for rate limit messages and adjust retry configuration:

```yaml
environment:
  - FIRECRAWL_RETRY_MAX_ATTEMPTS=5
  - FIRECRAWL_RETRY_MAX_DELAY=30000
```

#### Credit Usage Warnings

Monitor logs for credit alerts and adjust thresholds:

```yaml
environment:
  - FIRECRAWL_CREDIT_WARNING_THRESHOLD=2000
  - FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=500
```

### Debug Mode

Enable verbose logging:

```yaml
environment:
  - DEBUG_MODE=verbose
```

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
- 📚 [Firecrawl Official Docs](https://docs.firecrawl.dev)
- 🔥 [Firecrawl GitHub](https://github.com/mendableai/firecrawl)
- 📦 [NPM Package](https://www.npmjs.com/package/firecrawl-mcp)
- 🎮 [MCP Playground](https://mcp.so/playground?server=firecrawl-mcp-server)

### MCP Resources
- 📖 [MCP Documentation](https://modelcontextprotocol.io)
- 🔧 [MCP Inspector](https://github.com/modelcontextprotocol/inspector)

### Docker Resources
- 🐳 [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- 🌐 [Docker Networking](https://docs.docker.com/network/)
- 🛡️ [Docker Security](https://docs.docker.com/engine/security/)

---

## Support & License

### Getting Help

**Docker Image Issues:**
- GitHub: [firecrawl-mcp-docker/issues](https://github.com/MekayelAnik/firecrawl-mcp-docker/issues)

**Firecrawl MCP Issues:**
- GitHub: [firecrawl/issues](https://github.com/mendableai/firecrawl/issues)
- Website: [firecrawl.dev](https://www.firecrawl.dev/)
- Discord: [Join Community](https://discord.gg/firecrawl)

### API Key Support

For API key issues, billing, or account questions:
- Visit: [Firecrawl Dashboard](https://www.firecrawl.dev/app)
- Email: support@firecrawl.dev

### Contributing

We welcome contributions:
1. Report bugs via GitHub Issues
2. Suggest features
3. Improve documentation
4. Test beta releases

### License

GPL License. See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/firecrawl-mcp-docker/refs/heads/main/LICENSE) for details.

Firecrawl MCP server has its own license - see [official repo](https://github.com/mendableai/firecrawl).

---

## Disclaimer

This is an unofficial Docker image for Firecrawl MCP Server. This publisher is NOT affiliated with Firecrawl or Anthropic.

**Web Scraping Notice:** This tool performs web scraping on public search results. Users are responsible for complying with website terms of service, robots.txt directives, rate limiting, ethical scraping practices, and local laws.

**Privacy:** This Docker image DOES NOT collect, store, or transmit your scraping, search queries, or personal data. All searches are performed directly against the Cloud or Local Firecrawl Server using the API.

---

<div align="center">

[⬆️ Back to Top](#firecrawl-mcp-server)

</div>
