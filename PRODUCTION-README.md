# TheCookFlow - Configuración de Producción

## Servidor de Producción Optimizado

### Características Implementadas

✅ **Redirecciones Automáticas**
- HTTP → HTTPS (301)
- www → apex domain (thecookflow.com)
- Sin puerto :443 en URLs

✅ **Seguridad**
- Headers de seguridad con Helmet
- Content Security Policy (configurable)
- X-Content-Type-Options: nosniff
- Permissions-Policy para geolocation, microphone, camera
- Frame protection (sameorigin)

✅ **Performance**
- Compresión gzip automática
- Caché optimizado:
  - Assets estáticos: 1 año + immutable
  - HTML: sin caché (max-age=0)

✅ **SEO**
- robots.txt automático
- sitemap.xml incluido
- Meta tags canonicales
- Banner de Replit desactivado en producción

### Archivos Principales

- `server.js` - Servidor Express optimizado para producción
- `client/public/robots.txt` - Configuración SEO
- `client/public/sitemap.xml` - Mapa del sitio
- `client/index.html` - HTML optimizado (sin banner Replit)

### Comandos de Producción

```bash
# Desarrollo
npm run dev

# Construcción
npm run build

# Producción (servidor optimizado)
node server.js
```

### Dependencias Añadidas

- `compression` ^1.7.4 - Compresión gzip
- `helmet` ^7.1.0 - Headers de seguridad

### Pruebas de Funcionamiento

Puedes probar las redirecciones con:

```bash
curl -I http://thecookflow.com
curl -I https://www.thecookflow.com
```

Esperado:
- HTTP → 301 a HTTPS
- www → 301 a apex
- HTTPS thecookflow.com → 200

### Próximos Pasos (Opcional)

1. **CSP Estricta**: Activar Content Security Policy completa
2. **Dominio Personalizado**: Configurar en Replit Deployments
3. **Monitoreo**: Añadir logging de errores
4. **CDN**: Considerar CloudFlare para assets estáticos

### Configuración Actual

- Dominio principal: `thecookflow.com` (apex)
- HTTPS: Forzado automáticamente
- Compresión: Habilitada
- Caché: Optimizado para performance
- SEO: Configurado básico