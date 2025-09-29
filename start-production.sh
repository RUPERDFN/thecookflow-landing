#!/bin/bash

# Production startup script for Cloud Run
set -e

echo "Starting TheCookFlow in production mode..."

# Memory and performance optimizations for Cloud Run
export NODE_OPTIONS="--max-old-space-size=1024 --enable-source-maps"

# Ensure proper timezone
export TZ=UTC

# Start the application
exec node dist/index.js