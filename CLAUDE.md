# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an MCP (Model Context Protocol) browser automation setup providing two browser automation servers accessible through Claude Code:

1. **Standard Playwright MCP** - Microsoft's official browser automation (port 3333)
2. **Rebrowser MCP** - Stealth-enhanced version for bot detection bypass (port 3334)

Both services run via Docker with Traefik reverse proxy handling HTTPS routing and have been fully tested and validated.

## Quick Start

```bash
# Setup certificates and start services
./setup-dev-certs.sh
docker compose build rebrowser-mcp
docker compose up -d

# Verify services
docker compose ps
curl http://localhost:3333  # Standard Playwright
curl http://localhost:3334  # Stealth Rebrowser

# Test commands
mcp__playwright-mcp__browser_navigate https://example.com
mcp__rebrowser-mcp__browser_navigate https://bot-detector.rebrowser.net/
```

## Architecture & Network

### Service Architecture
- **Traefik**: Reverse proxy with HTTPS termination, TLS 1.3, security headers
- **Playwright MCP**: Standard automation at `https://playwright.localhost` (port 3333)
- **Rebrowser MCP**: Stealth automation at `https://rebrowser.localhost` (port 3334)
- **Custom Network**: `mcp-network` for container isolation

### Access Patterns
- **HTTPS**: Through Traefik proxy (playwright.localhost, rebrowser.localhost)
- **Direct HTTP**: localhost:3333 (playwright), localhost:3334 (rebrowser)
- **Dashboard**: https://traefik.localhost:8080

## MCP Integration

Add these servers to Claude Code configuration:
```json
{
  "mcpServers": {
    "playwright-mcp": {
      "command": "npx",
      "args": ["-y", "@microsoft/playwright-mcp"],
      "env": {
        "PLAYWRIGHT_MCP_BASE_URL": "http://localhost:3333"
      }
    },
    "rebrowser-mcp": {
      "command": "npx", 
      "args": ["-y", "@microsoft/playwright-mcp"],
      "env": {
        "PLAYWRIGHT_MCP_BASE_URL": "http://localhost:3334"
      }
    }
  }
}
```

## Browser Automation Tools (25+ Available)

### Core Interactions
- `browser_navigate` - Navigate to URLs
- `browser_snapshot` - Accessibility tree snapshot (recommended over screenshots)
- `browser_click` - Click elements with element + ref parameters
- `browser_type` - Type text with optional submit/slow typing
- `browser_hover` - Hover over elements
- `browser_drag` - Drag and drop between elements
- `browser_select_option` - Select dropdown options
- `browser_press_key` - Keyboard input (ArrowLeft, Enter, etc.)
- `browser_wait_for` - Wait for text/elements/time

### Navigation
- `browser_navigate_back` - Go back
- `browser_navigate_forward` - Go forward

### Tab Management
- `browser_tab_list` - List all tabs
- `browser_tab_new` - Open new tab with optional URL
- `browser_tab_select` - Switch to tab by index
- `browser_tab_close` - Close tab by index

### Data Extraction & Resources
- `browser_take_screenshot` - Visual capture (viewport or specific element)
- `browser_pdf_save` - Save page as PDF
- `browser_network_requests` - Network activity log since page load
- `browser_console_messages` - Browser console logs
- `browser_file_upload` - Upload files to forms

### Utilities
- `browser_install` - Install browsers in container
- `browser_close` - Close browser instance
- `browser_resize` - Window resizing
- `browser_handle_dialog` - Handle alerts/prompts/confirms

### Testing
- `browser_generate_playwright_test` - Generate Playwright test scripts

## Configuration Options & CLI Flags

### Browser Configuration
- `--browser <browser>` - chrome, firefox, webkit, msedge
- `--executable-path <path>` - Custom browser executable
- `--headless` - Run in headless mode
- `--no-sandbox` - Disable sandbox (required for Docker)
- `--isolated` - In-memory profile mode
- `--user-data-dir <path>` - Browser profile directory

### Display & Input
- `--device <device>` - Device emulation (e.g., "iPhone 15")
- `--viewport-size <size>` - Window size in pixels (e.g., "1280,720")
- `--user-agent <ua string>` - Custom user agent
- `--vision` - Enable vision mode (coordinates instead of accessibility)

### Network & Security
- `--allowed-origins <origins>` - Semicolon-separated allowed origins
- `--blocked-origins <origins>` - Semicolon-separated blocked origins
- `--ignore-https-errors` - Ignore HTTPS errors
- `--proxy-server <proxy>` - Proxy server (http:// or socks5://)

### Capabilities
- `--caps <caps>` - Comma-separated: tabs, pdf, history, wait, files, install, testing
- `--save-trace` - Save Playwright traces
- `--storage-state <path>` - Authentication state file

## Docker Configuration

### Complete docker-compose.yaml Structure
```yaml
services:
  traefik:
    image: traefik:v3.4.1
    ports: ["80:80", "443:443", "8080:8080"]
    volumes:
      - ./traefik/traefik.yaml:/etc/traefik/traefik.yaml
      - ./traefik/dynamic.yaml:/etc/traefik/dynamic.yaml
      - ./traefik/certs:/etc/traefik/certs:ro

  playwright-mcp:
    image: mcr.microsoft.com/playwright:latest
    ports: ["3333:3333"]
    command: ["sh", "-c", "npm install -g @playwright/mcp && npx playwright install chromium && npx @playwright/mcp --port 3333 --host 0.0.0.0 --browser chromium --no-sandbox --isolated"]

  rebrowser-mcp:
    build: ./ms-rebrowser-mcp
    ports: ["3334:3333"]
```

### Rebrowser Dockerfile (ms-rebrowser-mcp/Dockerfile)
Key stealth modifications applied:
```dockerfile
# Replace playwright with rebrowser-playwright for stealth
RUN sed -i 's/"playwright": "[^"]*"/"playwright": "npm:rebrowser-playwright@latest"/' package.json

# Stealth configuration improvements
RUN sed -i "s/channel: 'chrome'/channel: undefined/" src/config.ts
RUN sed -i "s/viewport: null/viewport: { width: 1366, height: 768 }/" src/config.ts

# CRITICAL: Disable webdriver detection
RUN sed -i '/chromiumSandbox: true,/a\      args: ["--disable-blink-features=AutomationControlled", "--disable-features=VizDisplayCompositor"],' src/config.ts

# Stealth environment variables
ENV REBROWSER_PATCHES_RUNTIME_FIX_MODE=alwaysIsolated
ENV REBROWSER_PATCHES_SOURCE_URL=jquery.min.js
```

## Key Differences: Standard vs Rebrowser

| Feature | Standard Playwright MCP | Rebrowser MCP |
|---------|------------------------|---------------|
| **Bot Detection** | Basic evasion | Advanced stealth patches |
| **Cloudflare Bypass** | ❌ Often blocked | ✅ Successfully bypasses |
| **WebDriver Detection** | ⚠️ Mixed results | ✅ Hidden with proper config |
| **Viewport** | Default or random | Custom 1366x768 |
| **Performance** | Fast | Slightly slower (patch overhead) |
| **Use Case** | Internal testing | Sites with bot detection |

## Critical Technical Insights

### Rebrowser Stealth Configuration
The rebrowser-mcp has been fully optimized with:
- **WebDriver Property Hiding**: `--disable-blink-features=AutomationControlled` flag
- **Custom Viewport**: 1366x768 instead of detectable defaults
- **Channel Removal**: `channel: undefined` instead of 'chrome'
- **Runtime Patches**: rebrowser-patches environment variables

### Bot Detection Test Results
**rebrowser-mcp (Fully Optimized):**
- ✅ navigatorWebdriver: "No webdriver presented"
- ✅ viewport: Custom 1366x768 resolution
- ⚠️ useragent: Chromium detection (minor issue)

**Real-World Performance:**
- ❌ playwright-mcp: Blocked by Cloudflare on Bulgarian govt site
- ✅ rebrowser-mcp: Successfully bypassed Cloudflare challenge

## Common Commands

### Setup & Installation
```bash
# Generate development HTTPS certificates
./setup-dev-certs.sh

# Build custom stealth container
docker compose build rebrowser-mcp

# Start all services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f rebrowser-mcp
```

### Development
```bash
# Rebuild specific service
docker compose up -d --build rebrowser-mcp

# Check service status
docker compose ps

# Test service health
curl http://localhost:3333/health
curl http://localhost:3334/health

# Access Traefik dashboard
open https://traefik.localhost:8080
```

## Troubleshooting

### Certificate Issues
```bash
# Regenerate certificates if HTTPS fails
./setup-dev-certs.sh
docker compose restart traefik
```

### Browser Installation Failures
```bash
# Rebuild container to trigger browser installation
docker compose build rebrowser-mcp --no-cache
docker compose restart rebrowser-mcp
```

### Port Conflicts
```bash
# Check and resolve port conflicts
lsof -i :3333 -i :3334 -i :8080
docker compose down && docker compose up -d
```

### Service Not Responding
```bash
# Verify network and service status
docker compose ps
docker network ls | grep mcp-network
docker exec mcp-rebrowser-mcp-1 curl localhost:3333
```

### Container Debugging
```bash
# View container logs
docker compose logs rebrowser-mcp
docker compose logs playwright-mcp

# Execute commands in container
docker exec mcp-rebrowser-mcp-1 ps aux
docker exec mcp-rebrowser-mcp-1 which chromium-browser
```

## Testing & Validation

### Bot Detection Test Sites
- **Primary**: https://bot-detector.rebrowser.net/
- **Alternative**: https://bot.sannysoft.com/
- **Real-world**: https://publicbg.mjs.bg/BgSubmissionDoc (Cloudflare-protected)

### Test Commands
```bash
# Test standard Playwright
mcp__playwright-mcp__browser_navigate https://bot-detector.rebrowser.net/
mcp__playwright-mcp__browser_snapshot

# Test stealth Rebrowser
mcp__rebrowser-mcp__browser_navigate https://bot-detector.rebrowser.net/
mcp__rebrowser-mcp__browser_snapshot
```

## Security & Best Practices

### Development Security
- **Self-signed certificates**: mkcert for local HTTPS
- **Container isolation**: Custom Docker network
- **Secure headers**: Via Traefik middleware
- **Sandbox restrictions**: Disabled only where necessary

### Production Considerations
```bash
# For production deployment:
- Replace mkcert with valid SSL certificates
- Disable Traefik dashboard or secure with auth
- Apply network restrictions
- Enable API authentication
```

### Container Security
- No privileged containers used
- Read-only certificate mounts
- Custom network isolation (`mcp-network`)
- Security headers enforced by Traefik

## Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| Docker | 20.10+ | Required for Compose v2 |
| Docker Compose | 2.0+ | Uses `docker compose` syntax |
| Node.js | 18+ | Required by Playwright MCP |
| Playwright | 1.52.0 | Base version |
| rebrowser-playwright | 1.52.0 | Matches Playwright version |
| Traefik | 3.4.1 | Latest stable |
| Chromium | 137.x | Auto-installed |

## Important Files

- `docker-compose.yaml`: Service orchestration and networking
- `ms-rebrowser-mcp/Dockerfile`: Custom stealth browser build
- `traefik/traefik.yaml`: Reverse proxy with HTTPS enforcement
- `traefik/dynamic.yaml`: Security headers and certificates
- `setup-dev-certs.sh`: Automated mkcert certificate generation

## User Profile Locations

### Persistent Browser Profiles
```bash
# Windows: %USERPROFILE%\AppData\Local\ms-playwright\mcp-{channel}-profile
# macOS: ~/Library/Caches/ms-playwright/mcp-{channel}-profile
# Linux: ~/.cache/ms-playwright/mcp-{channel}-profile
```

## Key Success Metrics

✅ **Both MCP servers**: Fully functional with 25+ browser automation tools  
✅ **Bot detection**: Major webdriver detection issue FIXED in rebrowser-mcp  
✅ **Real-world testing**: Cloudflare bypass confirmed for rebrowser-mcp  
✅ **Production ready**: Both servers tested and validated  
✅ **Complete documentation**: All configurations and troubleshooting covered