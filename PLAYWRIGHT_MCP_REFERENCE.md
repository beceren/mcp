# Playwright MCP & Rebrowser Reference Guide

## 📚 Repository Links

### Microsoft Playwright MCP
- **GitHub**: https://github.com/microsoft/playwright-mcp
- **NPM Package**: `@playwright/mcp@latest`
- **Docker Image**: `mcr.microsoft.com/playwright/mcp`

### Rebrowser Playwright (Stealth Version)
- **GitHub**: https://github.com/rebrowser/rebrowser-playwright
- **NPM Package**: `npm:rebrowser-playwright@latest`
- **Patches Repository**: https://github.com/rebrowser/rebrowser-patches
- **Bot Detector**: https://github.com/rebrowser/rebrowser-bot-detector

## 📖 Documentation Links

### Official Playwright
- **Main Documentation**: https://playwright.dev
- **API Reference**: https://playwright.dev/docs/api/class-playwright
- **CLI Documentation**: https://playwright.dev/docs/cli#install-browsers
- **Browser Channels**: https://playwright.dev/docs/browsers
- **Authentication/Storage State**: https://playwright.dev/docs/auth

### Rebrowser
- **Patches Documentation**: https://rebrowser.net/docs/patches-for-puppeteer-and-playwright
- **Main Website**: https://rebrowser.net

### MCP Protocol
- **MCP Install Guide**: https://modelcontextprotocol.io/quickstart/user
- **Windsurf MCP Docs**: https://docs.windsurf.com/windsurf/cascade/mcp

## 🚀 Installation & Configuration

### Standard Playwright MCP
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Standalone Server (SSE)
```bash
npx @playwright/mcp@latest --port 8931
```
```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://localhost:8931/sse"
    }
  }
}
```

### Docker Configuration
```json
{
  "mcpServers": {
    "playwright": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "--init", "--pull=always", "mcr.microsoft.com/playwright/mcp"]
    }
  }
}
```

### VS Code CLI Installation
```bash
code --add-mcp '{"name":"playwright","command":"npx","args":["@playwright/mcp@latest"]}'
```

## ⚙️ Configuration Options & CLI Flags

### Browser Configuration
- `--browser <browser>` - chrome, firefox, webkit, msedge
- `--executable-path <path>` - Custom browser executable
- `--headless` - Run in headless mode
- `--no-sandbox` - Disable sandbox (required for Docker)
- `--user-data-dir <path>` - Browser profile directory
- `--isolated` - In-memory profile mode

### Network & Security
- `--allowed-origins <origins>` - Semicolon-separated allowed origins
- `--blocked-origins <origins>` - Semicolon-separated blocked origins
- `--block-service-workers` - Block service workers
- `--ignore-https-errors` - Ignore HTTPS errors
- `--proxy-server <proxy>` - Proxy server (http:// or socks5://)
- `--proxy-bypass <bypass>` - Comma-separated domains to bypass proxy

### Display & Input
- `--device <device>` - Device emulation (e.g., "iPhone 15")
- `--viewport-size <size>` - Window size in pixels (e.g., "1280,720")
- `--user-agent <ua string>` - Custom user agent
- `--vision` - Enable vision mode (screenshots instead of accessibility)

### Capabilities & Features
- `--caps <caps>` - Comma-separated capabilities: tabs, pdf, history, wait, files, install, testing
- `--save-trace` - Save Playwright traces
- `--storage-state <path>` - Authentication state file

### Server Options
- `--host <host>` - Bind host (default: localhost, use 0.0.0.0 for all interfaces)
- `--port <port>` - Server port
- `--config <path>` - Configuration file path
- `--output-dir <path>` - Output directory

## 🎭 Available Tools (25+ Browser Automation Tools)

### Core Interactions
- `browser_navigate` - Navigate to URL
- `browser_snapshot` - Accessibility tree snapshot (recommended over screenshots)
- `browser_click` - Click elements
- `browser_type` - Type text with optional submit/slow typing
- `browser_hover` - Hover over elements
- `browser_drag` - Drag and drop
- `browser_select_option` - Select dropdown options
- `browser_press_key` - Keyboard input
- `browser_wait_for` - Wait for text/time

### Navigation
- `browser_navigate_back` - Go back
- `browser_navigate_forward` - Go forward

### Tab Management
- `browser_tab_list` - List all tabs
- `browser_tab_new` - Open new tab
- `browser_tab_select` - Switch to tab by index
- `browser_tab_close` - Close tab

### Resources & Data
- `browser_take_screenshot` - Visual capture
- `browser_pdf_save` - Save as PDF
- `browser_network_requests` - Network activity log
- `browser_console_messages` - Console logs
- `browser_file_upload` - Upload files

### Utilities
- `browser_install` - Install browsers
- `browser_close` - Close browser
- `browser_resize` - Window resizing
- `browser_handle_dialog` - Handle alerts/prompts

### Vision Mode (Coordinate-based)
- `browser_screen_capture` - Screenshot
- `browser_screen_click` - Click at X,Y coordinates
- `browser_screen_move_mouse` - Mouse positioning
- `browser_screen_drag` - Drag between coordinates
- `browser_screen_type` - Type text in vision mode

### Testing
- `browser_generate_playwright_test` - Generate test scripts

## 🕵️ Stealth Configuration (Rebrowser)

### Environment Variables
```dockerfile
ENV REBROWSER_PATCHES_RUNTIME_FIX_MODE=alwaysIsolated
ENV REBROWSER_PATCHES_SOURCE_URL=jquery.min.js
```

### Chrome Arguments for Anti-Detection
```typescript
args: [
  "--disable-blink-features=AutomationControlled",
  "--disable-features=VizDisplayCompositor"
]
```

### Stealth Best Practices
- Use rebrowser-playwright as drop-in replacement
- Set custom viewport (avoid default 800x600)
- Use `channel: undefined` instead of specific Chrome channel
- Apply rebrowser patches environment variables
- Disable AutomationControlled blink feature

## 🏗️ Complete Infrastructure Setup

### Prerequisites
```bash
# Install mkcert for HTTPS certificates
# macOS:
brew install mkcert nss

# Linux: https://github.com/FiloSottile/mkcert#installation
# Windows: https://github.com/FiloSottile/mkcert#installation
```

### Certificate Setup Script
```bash
#!/bin/bash
# setup-dev-certs.sh

echo "🔧 Setting up development HTTPS certificates..."

# Check if mkcert is installed
if ! command -v mkcert &>/dev/null; then
  echo "❌ mkcert not found. Installing..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install mkcert nss
  else
    echo "Please install mkcert manually: https://github.com/FiloSottile/mkcert#installation"
    exit 1
  fi
fi

# Install CA
echo "🔐 Installing CA certificate..."
mkcert -install

# Create certs directory
mkdir -p ./traefik/certs

# Generate certificates
echo "📜 Generating *.localhost certificates..."
mkcert -cert-file ./traefik/certs/localhost-cert.pem -key-file ./traefik/certs/localhost-key.pem localhost traefik.localhost playwright.localhost rebrowser.localhost "*.localhost"

echo "🔄 Restarting containers to load certificates..."
docker compose restart traefik

echo "✅ Development HTTPS setup complete!"
echo "🌐 Visit: https://traefik.localhost:8080"
```

## 🐳 Complete Docker Compose Configuration

### docker-compose.yaml
```yaml
services:
  traefik:
    image: traefik:v3.4.1
    container_name: traefik
    command: --configFile=/etc/traefik/traefik.yaml
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik/traefik.yaml:/etc/traefik/traefik.yaml
      - ./traefik/dynamic.yaml:/etc/traefik/dynamic.yaml
      - ./traefik/certs:/etc/traefik/certs:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(`traefik.localhost`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.traefik.tls=true"
      - "traefik.http.routers.traefik.middlewares=secure-headers@file"

  # Regular Playwright MCP (optional - for comparison)
  playwright-mcp:
    image: mcr.microsoft.com/playwright:latest
    working_dir: /app
    ports:
      - "3333:3333"
    command: ["sh", "-c", "npm install -g @playwright/mcp && npx playwright install chromium && npx @playwright/mcp --port 3333 --host 0.0.0.0 --browser chromium --no-sandbox --isolated"]
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.playwright.rule=Host(`playwright.localhost`)"
      - "traefik.http.routers.playwright.entrypoints=websecure"
      - "traefik.http.routers.playwright.tls=true"
      - "traefik.http.routers.playwright.middlewares=secure-headers@file"
      - "traefik.http.services.playwright.loadbalancer.server.port=3333"

  # Rebrowser Playwright MCP (stealth version)
  rebrowser-mcp:
    build: ./ms-rebrowser-mcp
    ports:
      - "3334:3333"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.rebrowser.rule=Host(`rebrowser.localhost`)"
      - "traefik.http.routers.rebrowser.entrypoints=websecure"
      - "traefik.http.routers.rebrowser.tls=true"
      - "traefik.http.routers.rebrowser.middlewares=secure-headers@file"
      - "traefik.http.services.rebrowser.loadbalancer.server.port=3333"

networks:
  default:
    name: mcp-network
```

### Traefik Configuration

#### traefik/traefik.yaml
```yaml
api:
  dashboard: true
  insecure: true  # For local dev only

entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https

  websecure:
    address: ":443"
    http:
      tls:
        options: default

providers:
  docker:
    exposedByDefault: false
    network: mcp-network

  file:
    filename: /etc/traefik/dynamic.yaml
    watch: true

tls:
  options:
    default:
      minVersion: "VersionTLS13"

  certificates:
    - certFile: /etc/traefik/certs/localhost-cert.pem
      keyFile: /etc/traefik/certs/localhost-key.pem

log:
  level: INFO
```

#### traefik/dynamic.yaml
```yaml
tls:
  stores:
    default:
      defaultCertificate:
        certFile: /etc/traefik/certs/localhost-cert.pem
        keyFile: /etc/traefik/certs/localhost-key.pem

http:
  middlewares:
    secure-headers:
      headers:
        accessControlAllowMethods:
          - GET
          - OPTIONS
          - PUT
          - POST
          - DELETE
        accessControlMaxAge: 100
        hostsProxyHeaders:
          - "X-Forwarded-Host"
        referrerPolicy: "same-origin"
        sslRedirect: true
        stsSeconds: 31536000
        stsIncludeSubdomains: true
        stsPreload: true
        forceSTSHeader: true
```

## 🐳 Docker Configuration Templates

### Standard Playwright MCP
```dockerfile
FROM mcr.microsoft.com/playwright:latest
WORKDIR /app
RUN git clone https://github.com/microsoft/playwright-mcp.git .
RUN npm install && npm run build
EXPOSE 3333
CMD ["node", "cli.js", "--port", "3333", "--host", "0.0.0.0", "--no-sandbox"]
```

### Rebrowser MCP (Stealth) - ms-rebrowser-mcp/Dockerfile
```dockerfile
FROM mcr.microsoft.com/playwright:latest

WORKDIR /app

# Clone the official Microsoft Playwright MCP
RUN git clone https://github.com/microsoft/playwright-mcp.git .

# Replace playwright with rebrowser-playwright (this is the key line!)
RUN sed -i 's/"playwright": "[^"]*"/"playwright": "npm:rebrowser-playwright@latest"/' package.json

# Fix config to improve stealth - remove chrome channel and set better defaults
RUN sed -i "s/channel: 'chrome'/channel: undefined/" src/config.ts
RUN sed -i "s/viewport: null/viewport: { width: 1366, height: 768 }/" src/config.ts

# Add Chrome args to disable webdriver detection
RUN sed -i '/chromiumSandbox: true,/a\      args: ["--disable-blink-features=AutomationControlled", "--disable-features=VizDisplayCompositor"],' src/config.ts

# Install dependencies (will install rebrowser-playwright as "playwright")
RUN npm install

# Build the project
RUN npm run build

EXPOSE 3333

# Set rebrowser-patches environment variables for stealth mode
ENV REBROWSER_PATCHES_RUNTIME_FIX_MODE=alwaysIsolated
ENV REBROWSER_PATCHES_SOURCE_URL=jquery.min.js

# Start the server with proper stealth configuration
CMD ["node", "cli.js", "--port", "3333", "--host", "0.0.0.0", "--no-sandbox"]
```

## 📁 User Profile Locations

### Persistent Profile Paths
```bash
# Windows
%USERPROFILE%\AppData\Local\ms-playwright\mcp-{channel}-profile

# macOS
~/Library/Caches/ms-playwright/mcp-{channel}-profile

# Linux
~/.cache/ms-playwright/mcp-{channel}-profile
```

## 🔧 Programmatic Usage Example
```javascript
import { createConnection } from '@playwright/mcp';
import { SSEServerTransport } from '@modelcontextprotocol/sdk/server/sse.js';

const connection = await createConnection({ 
  browser: { launchOptions: { headless: true } } 
});
const transport = new SSEServerTransport('/messages', res);
await connection.connect(transport);
```

## 🎯 Key Differences: Standard vs Rebrowser

| Feature | Standard Playwright MCP | Rebrowser MCP |
|---------|------------------------|---------------|
| **Bot Detection** | Basic (some detection) | Advanced stealth patches |
| **Cloudflare Bypass** | ❌ Often blocked | ✅ Better success rate |
| **WebDriver Detection** | ⚠️ Mixed results | ✅ Can be hidden with proper config |
| **User Agent** | Standard Chromium | Standard Chromium (same issue) |
| **Performance** | Fast | Slightly slower (patches overhead) |
| **Maintenance** | Microsoft official | Community-driven |
| **Use Case** | General automation | Stealth/scraping scenarios |

## 🚀 Complete Deployment Process

### Step-by-Step Setup
```bash
# 1. Clone and setup certificates
git clone <your-repo> && cd <project>
chmod +x setup-dev-certs.sh
./setup-dev-certs.sh

# 2. Create directory structure
mkdir -p traefik/certs
mkdir -p ms-rebrowser-mcp

# 3. Build and start services
docker compose build rebrowser-mcp
docker compose up -d

# 4. Verify services
docker compose ps
curl http://localhost:3333  # playwright-mcp
curl http://localhost:3334  # rebrowser-mcp

# 5. Test HTTPS endpoints
curl https://playwright.localhost
curl https://rebrowser.localhost
```

### Startup Commands
```bash
# Start all services
docker compose up -d

# Build specific service
docker compose build rebrowser-mcp

# Restart with logs
docker compose restart rebrowser-mcp && docker compose logs -f rebrowser-mcp

# Stop all services
docker compose down
```

## 🔧 Troubleshooting Guide

### Common Issues & Solutions

#### 1. Browser Installation Failures
```bash
# Symptoms: "Browser specified in your config is not installed"
# Solution: Rebuild container to trigger browser installation
docker compose build rebrowser-mcp --no-cache
docker compose restart rebrowser-mcp
```

#### 2. Certificate Trust Issues
```bash
# Symptoms: HTTPS errors, certificate warnings
# Solution: Reinstall mkcert CA
mkcert -install
./setup-dev-certs.sh
```

#### 3. Port Conflicts
```bash
# Symptoms: "Port already in use"
# Solution: Check and kill conflicting services
lsof -i :3333 -i :3334 -i :8080
docker compose down && docker compose up -d
```

#### 4. Container Sandbox Issues
```bash
# Symptoms: "Chromium crashes" or "No usable sandbox"
# Solution: Ensure --no-sandbox flag is used
# Already configured in our Docker commands
```

#### 5. Network Connectivity
```bash
# Symptoms: "Connection refused" from Claude Code
# Solution: Verify network and service status
docker network ls | grep mcp-network
docker compose ps
```

### Debug Commands
```bash
# View container logs
docker compose logs rebrowser-mcp
docker compose logs playwright-mcp

# Execute commands in container
docker exec mcp-rebrowser-mcp-1 ps aux
docker exec mcp-rebrowser-mcp-1 curl localhost:3333

# Check browser installation in container
docker exec mcp-rebrowser-mcp-1 which chromium-browser
```

## 🚨 Important Notes & Best Practices

1. **Version Matching**: rebrowser-playwright versions match original Playwright major.minor versions
2. **Drop-in Replacement**: Can replace standard playwright without code changes
3. **Docker Limitations**: Only supports headless Chromium in containers
4. **Vision vs Snapshot**: Snapshot mode (default) is faster and more reliable than vision mode
5. **Stealth Detection**: Use bot-detector.rebrowser.net for testing detection evasion
6. **Profile Management**: Use `--isolated` for testing, persistent for regular use
7. **Certificate Security**: mkcert certificates are for development only
8. **Container Resources**: Each browser session uses ~100-200MB RAM
9. **Network Isolation**: Containers use custom mcp-network for security
10. **Service Dependencies**: Traefik must start before MCP services

## 📋 Version Compatibility Matrix

| Component | Version | Notes |
|-----------|---------|-------|
| Docker | 20.10+ | Required for Docker Compose v2 |
| Docker Compose | 2.0+ | Uses `docker compose` (not `docker-compose`) |
| Node.js | 18+ | Required by Playwright MCP |
| Playwright | 1.52.0 | Base version for rebrowser |
| rebrowser-playwright | 1.52.0 | Matches Playwright version |
| Traefik | 3.4.1 | Latest stable for HTTPS proxy |
| Chromium | 137.x | Auto-installed in containers |
| mkcert | Latest | For development certificates |

## 🔒 Security Configuration

### Development vs Production
```bash
# Development (current setup)
- Self-signed certificates via mkcert
- Traefik dashboard exposed (:8080)
- Insecure API enabled for debugging

# Production (modifications needed)
- Valid SSL certificates
- Dashboard disabled or secured
- API secured with authentication
- Network restrictions applied
```

### Container Security
```bash
# Current security measures:
- Custom Docker network isolation
- No privileged containers
- Read-only certificate mounts
- Sandbox disabled only where required
- Secure headers via Traefik middleware
```

## 🔗 Testing URLs
- **Bot Detection**: https://bot-detector.rebrowser.net/
- **Alternative Bot Test**: https://bot.sannysoft.com/
- **Cloudflare Test**: https://publicbg.mjs.bg/BgSubmissionDoc (Bulgarian govt site)

---

*Last updated: January 2025*
*Temp folder cleanup safe after this reference is created*