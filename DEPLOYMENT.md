# Cloud Run Deployment Guide for TheCookFlow

## Pre-deployment Checklist

✅ **Cloud Run Compatibility Fixes Applied:**
- Health check endpoints `/health` and `/ready` added
- Graceful shutdown handling implemented
- Simplified server.listen method for Cloud Run compatibility
- Request timeout protection (55-minute limit)
- Trust proxy configuration for load balancer
- Memory optimization flags added
- Startup CPU boost configuration

## Deployment Files Created

### Core Files
- `Dockerfile` - Multi-stage Docker build optimized for Cloud Run
- `cloud-run.yaml` - Cloud Run service configuration with proper resource limits
- `.dockerignore` - Excludes development files from Docker build
- `entrypoint.sh` - Cloud Run startup script
- `start-production.sh` - Production startup with Node.js optimizations

### Health Check Endpoints
- **GET /health** - Returns server status, uptime, and environment
- **GET /ready** - Returns readiness status for load balancer

## Cloud Run Configuration Applied

### Server Optimizations
- **Trust Proxy**: Configured for load balancer integration
- **Timeout Protection**: 55-minute request timeout limit
- **Graceful Shutdown**: SIGTERM/SIGINT signal handling
- **Memory Management**: --max-old-space-size=1024 flag
- **Error Handling**: Uncaught exception and rejection handling

### Container Configuration
- **Resource Limits**: 2Gi memory, 2 CPU cores
- **Container Concurrency**: 1000 concurrent requests
- **Startup Probe**: 10 retries with 3-second intervals
- **Liveness Probe**: Health check every 30 seconds
- **Readiness Probe**: Continuous readiness validation
- **Execution Environment**: Gen2 for better performance

## Deployment Commands

### 1. Build the Application
```bash
npm run build
```

### 2. Build Docker Image
```bash
docker build -t gcr.io/PROJECT_ID/thecookflow .
```

### 3. Push to Container Registry
```bash
docker push gcr.io/PROJECT_ID/thecookflow
```

### 4. Deploy to Cloud Run
```bash
gcloud run deploy thecookflow \
  --image gcr.io/PROJECT_ID/thecookflow \
  --platform managed \
  --port 8080 \
  --memory 2Gi \
  --cpu 2 \
  --concurrency 1000 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated
```

## Environment Variables Required

Set these in Cloud Run:
- `NODE_ENV=production`
- `PORT=8080`
- `DATABASE_URL=your_neon_database_url`
- `OPENAI_API_KEY=your_openai_key`
- `GOOGLE_APPLICATION_CREDENTIALS=path_to_service_account_json`

## Troubleshooting

### Common Issues
1. **Health check failures** - Verify `/health` endpoint returns 200
2. **Startup timeout** - Check startup probe configuration
3. **Memory issues** - Increase memory limit in cloud-run.yaml
4. **Database connection** - Verify DATABASE_URL environment variable

### Verification Steps
1. Test health endpoints locally: `curl http://localhost:5000/health`
2. Check build process: `npm run build`
3. Verify Docker build: `docker build -t test-image .`
4. Test container locally: `docker run -p 8080:8080 test-image`

## Post-deployment Verification

After deployment, verify:
