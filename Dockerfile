# --- Build (Vite/React SPA) ---
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- Runtime (Nginx) ---
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
# Copiamos únicamente el resultado del build
COPY --from=build /app/dist/ ./
# Config SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Healthcheck para Coolify/Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s   CMD wget -qO- http://localhost/ >/dev/null || exit 1
