# 📁 TheCookFlow Landing Page - Archivos Completos

## ✅ Archivos Incluidos en el ZIP

Has recibido **todos los archivos necesarios** para desplegar la landing page de TheCookFlow en tu VPS. Aquí tienes la estructura completa:

```
📦 thecookflow-landing.zip
├── 📄 index.html          # Página principal completa
├── 🎨 style.css           # Estilos tema pizarra con animaciones
├── ⚡ main.js             # JavaScript con funcionalidades
├── 🖼️ favicon.ico         # Placeholder para favicon
├── 📁 assets/
│   └── 📋 README.md       # Guía de assets necesarios
└── 📁 legal/
    ├── 🔒 privacidad.html # Política de privacidad completa
    └── 📋 terminos.html   # Términos de servicio completos
```

## 🚀 Instrucciones de Instalación

### 1️⃣ Extraer en tu VPS
```bash
# Subir el archivo ZIP a tu VPS
scp thecookflow-landing.zip usuario@tu-vps.com:/tmp/

# Conectar a tu VPS
ssh usuario@tu-vps.com

# Extraer en la ubicación correcta
sudo mkdir -p /var/www/thecookflow/landing
cd /var/www/thecookflow/landing
sudo unzip /tmp/thecookflow-landing.zip
sudo chown -R www-data:www-data /var/www/thecookflow/landing
sudo chmod -R 755 /var/www/thecookflow/landing
```

### 2️⃣ Assets Que Necesitas Añadir

La landing está **lista para funcionar**, pero necesitas estos assets para completarla:

#### 🖼️ **Imágenes Principales** (Requeridas)
- `assets/logo.png` - Logo de TheCookFlow (400px ancho)
- `assets/bg.jpg` - Imagen de fondo del hero (1920x1080)

#### 📱 **Store Badges** (Opcionales hasta tener apps)
- `assets/app-store-badge.png`
- `assets/google-play-badge.png`

#### 🎯 **Favicon** (Recomendado)
- Reemplaza `favicon.ico` con tu favicon real

### 3️⃣ Configurar Formspree

En `index.html` línea 356, cambia:
```html
<form class="email-form" action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```

Por tu endpoint real de Formspree:
```html
<form class="email-form" action="https://formspree.io/f/TU_FORM_ID_REAL" method="POST">
```

## 🎨 Características Incluidas

### ✨ **Diseño y UX**
- ✅ **Tema Pizarra Completo** - Fondo grunge, fuentes chalk, efectos visuales
- ✅ **Responsive Design** - Optimizado para móvil y desktop
- ✅ **Animaciones Suaves** - Contadores, fade-ins, partículas flotantes
- ✅ **SEO Optimizado** - Meta tags, Open Graph, Schema.org

### 🔧 **Funcionalidades**
- ✅ **Formulario Email** - Integración lista con Formspree
- ✅ **Contadores Animados** - Estadísticas dinámicas
- ✅ **Scroll Suave** - Navegación fluida entre secciones
- ✅ **Validación Email** - Validación en tiempo real

### 📖 **Páginas Legales**
- ✅ **Política de Privacidad** - Completa y RGPD-compliant
- ✅ **Términos de Servicio** - Específicos para TheCookFlow
- ✅ **Navegación** - Enlaces desde footer funcionando

### 🎯 **CTAs y Conversión**
- ✅ **Múltiples CTAs** - Estratégicamente ubicados
- ✅ **Testimonios** - Credibilidad social
- ✅ **Indicadores de Confianza** - Estadísticas y valoraciones
- ✅ **Beneficios Claros** - Problemas y soluciones definidas

## ⚙️ Configuración de Nginx

```nginx
server {
    listen 80;
    server_name thecookflow.com www.thecookflow.com;
    root /var/www/thecookflow/landing;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
```