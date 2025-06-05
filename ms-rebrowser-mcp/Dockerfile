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

# Pre-install Chromium to avoid installation on each restart (Chrome not available on ARM64)
RUN npx playwright install chromium

EXPOSE 3333

# Set rebrowser-patches environment variables for stealth mode
ENV REBROWSER_PATCHES_RUNTIME_FIX_MODE=alwaysIsolated
ENV REBROWSER_PATCHES_SOURCE_URL=jquery.min.js

# Start the server with proper stealth configuration
CMD ["node", "cli.js", "--port", "3333", "--host", "0.0.0.0", "--browser", "chromium", "--no-sandbox"]