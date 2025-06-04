# FROM node:20

# # Clone Microsoft Playwright MCP repo
# RUN git clone https://github.com/microsoft/playwright-mcp.git /app
# WORKDIR /app

# # Use rebrowser-playwright instead of patchright
# RUN sed -i 's/"playwright": "[^"]*"/"playwright": "npm:rebrowser-playwright@latest"/' package.json

# RUN npm install
# RUN npm run build

# EXPOSE 3333
# CMD ["node", "dist/server.js"]


# ms-rebrowser-mcp/Dockerfile
# FROM mcr.microsoft.com/playwright:v1.53.0-noble
FROM mcr.microsoft.com/playwright:latest

WORKDIR /app

# Clone the official Microsoft Playwright MCP
RUN git clone https://github.com/microsoft/playwright-mcp.git .

# Replace playwright with rebrowser-playwright (this is the key line!)
RUN sed -i 's/"playwright": "[^"]*"/"playwright": "npm:rebrowser-playwright@latest"/' package.json

# Install dependencies (will install rebrowser-playwright as "playwright")
RUN npm install

# Build the project
RUN npm run build

EXPOSE 3333

# Start the server
CMD ["node", "cli.js", "--port", "3333", "--host", "0.0.0.0"]