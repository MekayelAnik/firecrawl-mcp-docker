#!/bin/bash
set -ex
# Set variables first
REPO_NAME='firecrawl-mcp'
BASE_IMAGE=$(cat ./build_data/base-image 2>/dev/null || echo "node:alpine")
FIRECRAWL_MCP_VERSION=$(cat ./build_data/version 2>/dev/null || exit 1)
SUPERGATEWAY_REPO=$(cat ./build_data/supergateway_repo 2>/dev/null || echo "supergateway")
SUPERGATEWAY_VERSION=$(cat ./build_data/supergateway_version 2>/dev/null || echo "latest")
FIRECRAWL_MCP_REPO="firecrawl-mcp"
FIRECRAWL_MCP_PKG="${FIRECRAWL_MCP_REPO}@${FIRECRAWL_MCP_VERSION}"
SUPERGATEWAY_PKG="${SUPERGATEWAY_REPO}@${SUPERGATEWAY_VERSION}"
DOCKERFILE_NAME="Dockerfile.$REPO_NAME"
OTHER_NPM_DEPENDENCIES=$(cat ./build_data/npm_dependencies 2>/dev/null || echo "")

# Create a temporary file safely
TEMP_FILE=$(mktemp "${DOCKERFILE_NAME}.XXXXXX") || {
    echo "Error creating temporary file" >&2
    exit 1
}

# Check if this is a publication build
if [ -e ./build_data/publication ]; then
    # For publication builds, create a minimal Dockerfile that just tags the existing image
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "FROM $BASE_IMAGE"
    } > "$TEMP_FILE"
else
    # Write the Dockerfile content to the temporary file first
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        cat << EOF
FROM $BASE_IMAGE AS build

# Author info:
LABEL org.opencontainers.image.authors="MOHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>"
LABEL org.opencontainers.image.description="Firecrawl MCP Server - Web scraping and content extraction MCP server"
LABEL org.opencontainers.image.source="https://github.com/mekayelanik/firecrawl-mcp-docker"

# Copy the entrypoint script into the container and make it executable
COPY ./resources/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/banner.sh

# Install required APK packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk --update-cache --no-cache add bash shadow su-exec tzdata bc && \
    rm -rf /var/cache/apk/*

# Create node user with specific UID/GID if they don't exist
RUN if ! id -u node >/dev/null 2>&1; then \
        addgroup -g 1000 node && \
        adduser -u 1000 -G node -D node; \
    fi

# Install Firecrawl MCP server
RUN echo "Installing Firecrawl MCP server: ${FIRECRAWL_MCP_PKG}" && \
    npm install -g ${FIRECRAWL_MCP_PKG} --loglevel verbose && \
    echo "Package installed successfully"

# Install Supergateway
RUN echo "Installing Supergateway..." && \
    npm install -g ${SUPERGATEWAY_PKG} --loglevel verbose && \
    npm cache clean --force

EOF

        # Add Other NPM Dependencies if they exist
        if [ -n "$OTHER_NPM_DEPENDENCIES" ]; then
            cat << EOF
# Install Other NPM Dependencies
RUN echo "Installing other NPM Dependencies: ${OTHER_NPM_DEPENDENCIES}" && \
    npm install -g ${OTHER_NPM_DEPENDENCIES} --loglevel verbose && \
    echo "Packages installed successfully"

EOF
        fi

        cat << EOF
# Use an ARG for the default port
ARG PORT=8030

# Set an ENV variable from the ARG for runtime
ENV PORT=\${PORT}

# Firecrawl specific environment variables with defaults
ENV FIRECRAWL_RETRY_MAX_ATTEMPTS=3
ENV FIRECRAWL_RETRY_INITIAL_DELAY=1000
ENV FIRECRAWL_RETRY_MAX_DELAY=10000
ENV FIRECRAWL_RETRY_BACKOFF_FACTOR=2
ENV FIRECRAWL_CREDIT_WARNING_THRESHOLD=1000
ENV FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=100

# Expose the port
EXPOSE \${PORT}

# Health check using nc (netcat) to check if the port is open
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \\
    CMD nc -z localhost \${PORT:-8016} || exit 1

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EOF
    } > "$TEMP_FILE"
fi

# Atomically replace the target file with the temporary file
if mv -f "$TEMP_FILE" "$DOCKERFILE_NAME"; then
    echo "Dockerfile for $REPO_NAME created successfully."
else
    echo "Error: Failed to create Dockerfile for $REPO_NAME" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi