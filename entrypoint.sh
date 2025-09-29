#!/bin/bash

# Cloud Run entrypoint script
set -e

echo "TheCookFlow starting in Cloud Run environment..."
echo "Port: $PORT"
echo "Environment: $NODE_ENV"

# Ensure proper permissions
chmod +x /app/start-production.sh

# Start the application with Cloud Run optimizations
exec /app/start-production.sh