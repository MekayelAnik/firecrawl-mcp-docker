#!/bin/bash
set -e
/usr/local/bin/banner.sh

# Default values
readonly DEFAULT_PUID=1000
readonly DEFAULT_PGID=1000
readonly DEFAULT_PORT=8016
readonly DEFAULT_PROTOCOL="SHTTP"
readonly FIRST_RUN_FILE="/tmp/first_run_complete"

# Firecrawl default configuration values
readonly DEFAULT_RETRY_MAX_ATTEMPTS=3
readonly DEFAULT_RETRY_INITIAL_DELAY=1000
readonly DEFAULT_RETRY_MAX_DELAY=10000
readonly DEFAULT_RETRY_BACKOFF_FACTOR=2
readonly DEFAULT_CREDIT_WARNING_THRESHOLD=1000
readonly DEFAULT_CREDIT_CRITICAL_THRESHOLD=100

# Function to trim whitespace using parameter expansion
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

# Validate positive integers
is_positive_int() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -gt 0 ]
}

# Validate floating point numbers (for backoff factor)
is_positive_float() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [ "$(echo "$1 > 0" | bc -l 2>/dev/null || echo 1)" -eq 1 ]
}

# Validate directory path
validate_directory() {
    local dir="$1"
    [[ -n "$dir" ]] && [[ "$dir" =~ ^/ ]] && [[ ! "$dir" =~ \.\. ]] && [[ "${#dir}" -le 255 ]]
}

# First run handling
handle_first_run() {
    local uid_gid_changed=0

    # Handle PUID/PGID logic
    if [[ -z "$PUID" && -z "$PGID" ]]; then
        PUID="$DEFAULT_PUID"
        PGID="$DEFAULT_PGID"
        echo "PUID and PGID not set. Using defaults: PUID=$PUID, PGID=$PGID"
    elif [[ -n "$PUID" && -z "$PGID" ]]; then
        if is_positive_int "$PUID"; then
            PGID="$PUID"
        else
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    elif [[ -z "$PUID" && -n "$PGID" ]]; then
        if is_positive_int "$PGID"; then
            PUID="$PGID"
        else
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PUID="$DEFAULT_PUID"
            PGID="$DEFAULT_PGID"
        fi
    else
        if ! is_positive_int "$PUID"; then
            echo "Invalid PUID: '$PUID'. Using default: $DEFAULT_PUID"
            PUID="$DEFAULT_PUID"
        fi
        
        if ! is_positive_int "$PGID"; then
            echo "Invalid PGID: '$PGID'. Using default: $DEFAULT_PGID"
            PGID="$DEFAULT_PGID"
        fi
    fi

    # Check existing UID/GID conflicts
    local current_user current_group
    current_user=$(id -un "$PUID" 2>/dev/null || true)
    current_group=$(getent group "$PGID" | cut -d: -f1 2>/dev/null || true)

    [[ -n "$current_user" && "$current_user" != "node" ]] &&
        echo "Warning: UID $PUID already in use by $current_user - may cause permission issues"

    [[ -n "$current_group" && "$current_group" != "node" ]] &&
        echo "Warning: GID $PGID already in use by $current_group - may cause permission issues"

    # Modify UID/GID if needed - use test command instead of arithmetic expressions
    if [ "$(id -u node)" -ne "$PUID" ]; then
        if usermod -o -u "$PUID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change UID to $PUID. Using existing UID $(id -u node)"
            PUID=$(id -u node)
        fi
    fi

    if [ "$(id -g node)" -ne "$PGID" ]; then
        if groupmod -o -g "$PGID" node 2>/dev/null; then
            uid_gid_changed=1
        else
            echo "Error: Failed to change GID to $PGID. Using existing GID $(id -g node)"
            PGID=$(id -g node)
        fi
    fi

    [ "$uid_gid_changed" -eq 1 ] && echo "Updated UID/GID to PUID=$PUID, PGID=$PGID"
    touch "$FIRST_RUN_FILE"
}

# Validate and set PORT
validate_port() {
    # Ensure PORT has a value
    PORT=${PORT:-$DEFAULT_PORT}
    
    # Check if PORT is a positive integer
    if ! is_positive_int "$PORT"; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    elif [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Invalid PORT: '$PORT'. Using default: $DEFAULT_PORT"
        PORT="$DEFAULT_PORT"
    fi
    
    # Check if port is privileged - use test command instead of arithmetic expression
    if [ "$PORT" -lt 1024 ] && [ "$(id -u)" -ne 0 ]; then
        echo "Warning: Port $PORT is privileged and might require root"
    fi
}

# Build MCP server command with environment variables
build_mcp_server_cmd() {
    # Start with the base command
    MCP_SERVER_CMD="npx -y firecrawl-mcp"
    
    # Build environment variable arguments array
    FIRECRAWL_ENV_ARGS=()
    
    # Add FIRECRAWL_API_KEY (required)
    if [[ -n "${FIRECRAWL_API_KEY:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_API_KEY=$FIRECRAWL_API_KEY")
    fi
    
    # Add FIRECRAWL_API_URL (optional)
    if [[ -n "${FIRECRAWL_API_URL:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_API_URL=$FIRECRAWL_API_URL")
    fi
    
    # Add retry configuration (optional)
    if [[ -n "${FIRECRAWL_RETRY_MAX_ATTEMPTS:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_RETRY_MAX_ATTEMPTS=$FIRECRAWL_RETRY_MAX_ATTEMPTS")
    fi
    
    if [[ -n "${FIRECRAWL_RETRY_INITIAL_DELAY:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_RETRY_INITIAL_DELAY=$FIRECRAWL_RETRY_INITIAL_DELAY")
    fi
    
    if [[ -n "${FIRECRAWL_RETRY_MAX_DELAY:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_RETRY_MAX_DELAY=$FIRECRAWL_RETRY_MAX_DELAY")
    fi
    
    if [[ -n "${FIRECRAWL_RETRY_BACKOFF_FACTOR:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_RETRY_BACKOFF_FACTOR=$FIRECRAWL_RETRY_BACKOFF_FACTOR")
    fi
    
    # Add credit monitoring (optional)
    if [[ -n "${FIRECRAWL_CREDIT_WARNING_THRESHOLD:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_CREDIT_WARNING_THRESHOLD=$FIRECRAWL_CREDIT_WARNING_THRESHOLD")
    fi
    
    if [[ -n "${FIRECRAWL_CREDIT_CRITICAL_THRESHOLD:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=$FIRECRAWL_CREDIT_CRITICAL_THRESHOLD")
    fi
    
    # Add HTTP_STREAMABLE_SERVER (optional)
    if [[ -n "${HTTP_STREAMABLE_SERVER:-}" ]]; then
        FIRECRAWL_ENV_ARGS+=(env "HTTP_STREAMABLE_SERVER=$HTTP_STREAMABLE_SERVER")
    fi
    
    # Combine env args with the base command
    if [[ ${#FIRECRAWL_ENV_ARGS[@]} -gt 0 ]]; then
        MCP_SERVER_CMD="${FIRECRAWL_ENV_ARGS[@]} $MCP_SERVER_CMD"
    fi
}

# Validate CORS patterns
validate_cors() {
    CORS_ARGS=()
    ALLOW_ALL_CORS=false
    local cors_value

    if [[ -n "${CORS:-}" ]]; then
        IFS=',' read -ra CORS_VALUES <<< "$CORS"
        for cors_value in "${CORS_VALUES[@]}"; do
            cors_value=$(trim "$cors_value")
            [[ -z "$cors_value" ]] && continue

            if [[ "$cors_value" =~ ^(all|\*)$ ]]; then
                ALLOW_ALL_CORS=true
                CORS_ARGS=(--cors)
                echo "Caution! CORS allowing all origins - security risk in production!"
                break
            elif [[ "$cors_value" =~ ^/.*/$ ]] ||
                 [[ "$cors_value" =~ ^https?:// ]] ||
                 [[ "$cors_value" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^https?://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?$ ]] ||
                 [[ "$cors_value" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]+)?$ ]]
            then
                CORS_ARGS+=(--cors "$cors_value")
            else
                echo "Warning: Invalid CORS pattern '$cors_value' - skipping"
            fi
        done
    fi
}

# Generate client configuration example
generate_client_config_example() {
    echo ""
    echo "=== FIRECRAWL MCP TOOL LIST ==="
    echo "To enable auto-approval in your MCP client, add this to your configuration:"
    echo ""
    echo "\"TOOL LIST\": ["
    echo "  \"firecrawl_scrape\","
    echo "  \"firecrawl_batch_scrape\","
    echo "  \"firecrawl_check_batch_status\","
    echo "  \"firecrawl_map\","
    echo "  \"firecrawl_search\","
    echo "  \"firecrawl_crawl\","
    echo "  \"firecrawl_check_crawl_status\","
    echo "  \"firecrawl_extract\""
    echo "]"
    echo ""
    echo "=== END TOOL LIST ==="
    echo ""
}

# Validate and set Firecrawl environment variables
validate_firecrawl_env() {
    # STRICT VALIDATION: FIRECRAWL_API_KEY is REQUIRED
    if [[ -z "${FIRECRAWL_API_KEY:-}" ]]; then
        echo "❌ ERROR: FIRECRAWL_API_KEY environment variable is REQUIRED."
        echo ""
        echo "The Firecrawl MCP server cannot start without an API key."
        echo ""
        echo "You can obtain an API key by:"
        echo "  1. Visiting: https://www.firecrawl.dev/app/api-keys"
        echo "  2. Creating an account if you don't have one"
        echo "  3. Generating a new API key"
        echo ""
        echo "Then set the environment variable:"
        echo "  docker run -e FIRECRAWL_API_KEY=fc-your-api-key ..."
        echo ""
        echo "For self-hosted instances, you still need an API key from your instance."
        echo ""
        return 1
    fi

    # Validate API key format (basic check for Firecrawl format)
    if [[ ! "$FIRECRAWL_API_KEY" =~ ^fc- ]]; then
        echo "⚠️  Warning: FIRECRAWL_API_KEY doesn't match expected format (should start with 'fc-')"
    fi

    # Validate FIRECRAWL_API_URL if set (optional)
    if [[ -n "${FIRECRAWL_API_URL:-}" ]]; then
        if [[ ! "$FIRECRAWL_API_URL" =~ ^https?:// ]]; then
            echo "❌ ERROR: FIRECRAWL_API_URL must start with http:// or https://"
            return 1
        fi
    fi

    # Validate optional retry configuration only if set
    if [[ -n "${FIRECRAWL_RETRY_MAX_ATTEMPTS:-}" ]]; then
        if ! is_positive_int "$FIRECRAWL_RETRY_MAX_ATTEMPTS"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_RETRY_MAX_ATTEMPTS: '$FIRECRAWL_RETRY_MAX_ATTEMPTS'. Using default: $DEFAULT_RETRY_MAX_ATTEMPTS"
            export FIRECRAWL_RETRY_MAX_ATTEMPTS="$DEFAULT_RETRY_MAX_ATTEMPTS"
        fi
    fi

    if [[ -n "${FIRECRAWL_RETRY_INITIAL_DELAY:-}" ]]; then
        if ! is_positive_int "$FIRECRAWL_RETRY_INITIAL_DELAY"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_RETRY_INITIAL_DELAY: '$FIRECRAWL_RETRY_INITIAL_DELAY'. Using default: $DEFAULT_RETRY_INITIAL_DELAY"
            export FIRECRAWL_RETRY_INITIAL_DELAY="$DEFAULT_RETRY_INITIAL_DELAY"
        fi
    fi

    if [[ -n "${FIRECRAWL_RETRY_MAX_DELAY:-}" ]]; then
        if ! is_positive_int "$FIRECRAWL_RETRY_MAX_DELAY"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_RETRY_MAX_DELAY: '$FIRECRAWL_RETRY_MAX_DELAY'. Using default: $DEFAULT_RETRY_MAX_DELAY"
            export FIRECRAWL_RETRY_MAX_DELAY="$DEFAULT_RETRY_MAX_DELAY"
        fi
    fi

    if [[ -n "${FIRECRAWL_RETRY_BACKOFF_FACTOR:-}" ]]; then
        if ! is_positive_float "$FIRECRAWL_RETRY_BACKOFF_FACTOR"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_RETRY_BACKOFF_FACTOR: '$FIRECRAWL_RETRY_BACKOFF_FACTOR'. Using default: $DEFAULT_RETRY_BACKOFF_FACTOR"
            export FIRECRAWL_RETRY_BACKOFF_FACTOR="$DEFAULT_RETRY_BACKOFF_FACTOR"
        fi
    fi

    # Validate optional credit monitoring only if set
    if [[ -n "${FIRECRAWL_CREDIT_WARNING_THRESHOLD:-}" ]]; then
        if ! is_positive_int "$FIRECRAWL_CREDIT_WARNING_THRESHOLD"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_CREDIT_WARNING_THRESHOLD: '$FIRECRAWL_CREDIT_WARNING_THRESHOLD'. Using default: $DEFAULT_CREDIT_WARNING_THRESHOLD"
            export FIRECRAWL_CREDIT_WARNING_THRESHOLD="$DEFAULT_CREDIT_WARNING_THRESHOLD"
        fi
    fi

    if [[ -n "${FIRECRAWL_CREDIT_CRITICAL_THRESHOLD:-}" ]]; then
        if ! is_positive_int "$FIRECRAWL_CREDIT_CRITICAL_THRESHOLD"; then
            echo "⚠️  Warning: Invalid FIRECRAWL_CREDIT_CRITICAL_THRESHOLD: '$FIRECRAWL_CREDIT_CRITICAL_THRESHOLD'. Using default: $DEFAULT_CREDIT_CRITICAL_THRESHOLD"
            export FIRECRAWL_CREDIT_CRITICAL_THRESHOLD="$DEFAULT_CREDIT_CRITICAL_THRESHOLD"
        fi
    fi

    return 0
}

# Display Firecrawl configuration summary (only show set optional variables)
display_config_summary() {
    echo ""
    echo "=== FIRECRAWL MCP SERVER CONFIGURATION ==="
    
    # Always show API configuration
    echo "🔑 API Key: ${FIRECRAWL_API_KEY:0:8}...${FIRECRAWL_API_KEY: -4} (length: ${#FIRECRAWL_API_KEY})"
    
    if [[ -n "${FIRECRAWL_API_URL:-}" ]]; then
        echo "🏠 API URL: $FIRECRAWL_API_URL"
    fi
    
    # Only show retry settings if any were customized
    local show_retry_settings=false
    if [[ "${FIRECRAWL_RETRY_MAX_ATTEMPTS:-}" != "$DEFAULT_RETRY_MAX_ATTEMPTS" ]] ||
       [[ "${FIRECRAWL_RETRY_INITIAL_DELAY:-}" != "$DEFAULT_RETRY_INITIAL_DELAY" ]] ||
       [[ "${FIRECRAWL_RETRY_MAX_DELAY:-}" != "$DEFAULT_RETRY_MAX_DELAY" ]] ||
       [[ "${FIRECRAWL_RETRY_BACKOFF_FACTOR:-}" != "$DEFAULT_RETRY_BACKOFF_FACTOR" ]]; then
        show_retry_settings=true
    fi
    
    if [[ "$show_retry_settings" == true ]]; then
        echo "🔄 Retry Settings:"
        [[ "${FIRECRAWL_RETRY_MAX_ATTEMPTS:-}" != "$DEFAULT_RETRY_MAX_ATTEMPTS" ]] && echo "   - Max Attempts: $FIRECRAWL_RETRY_MAX_ATTEMPTS"
        [[ "${FIRECRAWL_RETRY_INITIAL_DELAY:-}" != "$DEFAULT_RETRY_INITIAL_DELAY" ]] && echo "   - Initial Delay: $FIRECRAWL_RETRY_INITIAL_DELAY ms"
        [[ "${FIRECRAWL_RETRY_MAX_DELAY:-}" != "$DEFAULT_RETRY_MAX_DELAY" ]] && echo "   - Max Delay: $FIRECRAWL_RETRY_MAX_DELAY ms"
        [[ "${FIRECRAWL_RETRY_BACKOFF_FACTOR:-}" != "$DEFAULT_RETRY_BACKOFF_FACTOR" ]] && echo "   - Backoff Factor: $FIRECRAWL_RETRY_BACKOFF_FACTOR"
    fi
    
    # Only show credit monitoring if customized
    if [[ "${FIRECRAWL_CREDIT_WARNING_THRESHOLD:-}" != "$DEFAULT_CREDIT_WARNING_THRESHOLD" ]] ||
       [[ "${FIRECRAWL_CREDIT_CRITICAL_THRESHOLD:-}" != "$DEFAULT_CREDIT_CRITICAL_THRESHOLD" ]]; then
        echo "💰 Credit Monitoring:"
        [[ "${FIRECRAWL_CREDIT_WARNING_THRESHOLD:-}" != "$DEFAULT_CREDIT_WARNING_THRESHOLD" ]] && echo "   - Warning Threshold: $FIRECRAWL_CREDIT_WARNING_THRESHOLD credits"
        [[ "${FIRECRAWL_CREDIT_CRITICAL_THRESHOLD:-}" != "$DEFAULT_CREDIT_CRITICAL_THRESHOLD" ]] && echo "   - Critical Threshold: $FIRECRAWL_CREDIT_CRITICAL_THRESHOLD credits"
    fi
    
    # Show HTTP mode if enabled
    if [[ "${HTTP_STREAMABLE_SERVER:-}" == "true" ]]; then
        echo "🌐 HTTP Streamable Server mode enabled"
        echo "   Access at: http://localhost:${PORT}/mcp"
    fi
    
    # Always show server configuration
    echo "📡 Server:"
    echo "   - Port: $PORT"
    echo "   - Protocol: $PROTOCOL_DISPLAY"
    
    echo "=========================================="
    echo ""
}

# Main execution
main() {
    # Trim all input parameters
    [[ -n "${PUID:-}" ]] && PUID=$(trim "$PUID")
    [[ -n "${PGID:-}" ]] && PGID=$(trim "$PGID")
    [[ -n "${PORT:-}" ]] && PORT=$(trim "$PORT")
    [[ -n "${PROTOCOL:-}" ]] && PROTOCOL=$(trim "$PROTOCOL")
    [[ -n "${CORS:-}" ]] && CORS=$(trim "$CORS")
    
    # Trim Firecrawl specific environment variables
    [[ -n "${FIRECRAWL_API_KEY:-}" ]] && FIRECRAWL_API_KEY=$(trim "$FIRECRAWL_API_KEY")
    [[ -n "${FIRECRAWL_API_URL:-}" ]] && FIRECRAWL_API_URL=$(trim "$FIRECRAWL_API_URL")
    [[ -n "${FIRECRAWL_RETRY_MAX_ATTEMPTS:-}" ]] && FIRECRAWL_RETRY_MAX_ATTEMPTS=$(trim "$FIRECRAWL_RETRY_MAX_ATTEMPTS")
    [[ -n "${FIRECRAWL_RETRY_INITIAL_DELAY:-}" ]] && FIRECRAWL_RETRY_INITIAL_DELAY=$(trim "$FIRECRAWL_RETRY_INITIAL_DELAY")
    [[ -n "${FIRECRAWL_RETRY_MAX_DELAY:-}" ]] && FIRECRAWL_RETRY_MAX_DELAY=$(trim "$FIRECRAWL_RETRY_MAX_DELAY")
    [[ -n "${FIRECRAWL_RETRY_BACKOFF_FACTOR:-}" ]] && FIRECRAWL_RETRY_BACKOFF_FACTOR=$(trim "$FIRECRAWL_RETRY_BACKOFF_FACTOR")
    [[ -n "${FIRECRAWL_CREDIT_WARNING_THRESHOLD:-}" ]] && FIRECRAWL_CREDIT_WARNING_THRESHOLD=$(trim "$FIRECRAWL_CREDIT_WARNING_THRESHOLD")
    [[ -n "${FIRECRAWL_CREDIT_CRITICAL_THRESHOLD:-}" ]] && FIRECRAWL_CREDIT_CRITICAL_THRESHOLD=$(trim "$FIRECRAWL_CREDIT_CRITICAL_THRESHOLD")
    [[ -n "${HTTP_STREAMABLE_SERVER:-}" ]] && HTTP_STREAMABLE_SERVER=$(trim "$HTTP_STREAMABLE_SERVER")

    # First run handling
    if [[ ! -f "$FIRST_RUN_FILE" ]]; then
        handle_first_run
    fi

    # Validate configurations
    validate_port
    validate_cors
    
    # Validate Firecrawl environment - this will exit if configuration is invalid
    if ! validate_firecrawl_env; then
        echo "❌ Firecrawl MCP Server cannot start due to configuration errors."
        exit 1
    fi

    # Build MCP server command with environment variables
    build_mcp_server_cmd

    # Generate client configuration example if auto-approve is enabled
    generate_client_config_example

    # Protocol selection
    local PROTOCOL_UPPER=${PROTOCOL:-$DEFAULT_PROTOCOL}
    PROTOCOL_UPPER=${PROTOCOL_UPPER^^}

    case "$PROTOCOL_UPPER" in
        "SHTTP"|"STREAMABLEHTTP")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
        "SSE")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --ssePath /sse --outputTransport sse "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SSE/Server-Sent Events"
            ;;
        "WS"|"WEBSOCKET")
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --messagePath /message --outputTransport ws "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="WS/WebSocket"
            ;;
        *)
            echo "Invalid PROTOCOL: '$PROTOCOL'. Using default: $DEFAULT_PROTOCOL"
            CMD_ARGS=(npx --yes supergateway --port "$PORT" --streamableHttpPath /mcp --outputTransport streamableHttp "${CORS_ARGS[@]}" --healthEndpoint /healthz --stdio "$MCP_SERVER_CMD")
            PROTOCOL_DISPLAY="SHTTP/streamableHttp"
            ;;
    esac

    # Display configuration summary
    display_config_summary

    # Debug mode handling
    case "${DEBUG_MODE:-}" in
        [1YyTt]*|[Oo][Nn]|[Yy][Ee][Ss]|[Ee][Nn][Aa][Bb][Ll][Ee]*)
            echo "DEBUG MODE: Installing nano and pausing container"
            apk add --no-cache nano 2>/dev/null || echo "Warning: Failed to install nano"
            echo "Container paused for debugging. Exec into container to investigate."
            exec tail -f /dev/null
            ;;
        *)
            # Normal execution
            echo "🚀 Launching Firecrawl MCP Server with protocol: $PROTOCOL_DISPLAY on port: $PORT"
            
            # Check for npx availability
            if ! command -v npx &>/dev/null; then
                echo "❌ Error: npx not available. Cannot start server."
                exit 1
            fi

            # Final check - ensure API key is set (should already be validated, but double-check)
            if [[ -z "${FIRECRAWL_API_KEY:-}" ]]; then
                echo "❌ CRITICAL: FIRECRAWL_API_KEY is not set."
                echo "   The server cannot start without a Firecrawl API key."
                exit 1
            fi

            # Display the actual command being executed for debugging
            if [[ "${DEBUG_MODE:-}" == "verbose" ]]; then
                echo "🔧 DEBUG - Final command: ${CMD_ARGS[*]}"
            fi

            if [ "$(id -u)" -eq 0 ]; then
                echo "👤 Running as user: node (PUID: $PUID, PGID: $PGID)"
                exec su-exec node "${CMD_ARGS[@]}"
            else
                if [ "$PORT" -lt 1024 ]; then
                    echo "❌ Error: Cannot bind to privileged port $PORT without root"
                    exit 1
                fi
                echo "👤 Running as current user"
                exec "${CMD_ARGS[@]}"
            fi
            ;;
    esac
}

# Run the script with error handling
if main "$@"; then
    exit 0
else
    echo "❌ Firecrawl MCP Server failed to start"
    exit 1
fi