# thecookflow-landing - Patch de despliegue (Coolify + Nginx)

Este paquete incluye los archivos necesarios para desplegar la landing como una SPA (Vite/React) servida por Nginx, con healthcheck compatible con Coolify.

## Archivos incluidos
- `Dockerfile` → multi-stage: build con Vite y runtime Nginx.
- `nginx.conf` → configuración para SPA (fallback a `/index.html`).
- `.dockerignore` → evita enviar basura al contenedor.
- `Dockerfile.static` → alternativa para landing HTML/CSS puro (sin build).
- `nginx.conf.multipage` → alternativa Nginx para multipágina estática.

## Uso (SPA con Vite/React)
1. Asegúrate de tener en `package.json`:
   ```json
   { "scripts": { "build": "vite build" } }
   ```
2. Copia `Dockerfile`, `nginx.conf` y `.dockerignore` a la **raíz** del repo.
3. Commit & push:
   ```bash
   git add Dockerfile nginx.conf .dockerignore
   git commit -m "chore: nginx SPA + healthcheck"
   git push
   ```
4. En Coolify (app *landing*):
   - Build Pack: **Dockerfile**
   - Dockerfile path: `Dockerfile`
   - Ports Exposes: **80**
   - Ports Mappings: *(vacío)*
   - Custom Docker Options: *(vacío)*
   - Pre/Post deployment: *(vacíos)*
   - Domains: `https://thecookflow.com` (elige canónica con/ sin www)
   - **Deploy**

## Uso (HTML/CSS puro, sin Vite)
1. Copia `Dockerfile.static` como `Dockerfile` y `nginx.conf.multipage` como `nginx.conf` en la **raíz**.
2. Commit & push como arriba.
3. Misma configuración en Coolify.

## Verificación SSL
```bash
curl -I https://thecookflow.com
echo | openssl s_client -servername thecookflow.com -connect thecookflow.com:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
```

Si aún ves **TRAEFIK DEFAULT CERT**, en Coolify → Domains: **Regenerate Domain** y redeploy.
