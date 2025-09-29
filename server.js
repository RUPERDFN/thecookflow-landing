// server.js
import express from "express";
import compression from "compression";
import helmet from "helmet";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// Replit/Google Frontend pasa X-Forwarded-* → necesario para detectar HTTPS
app.set("trust proxy", true);

// 1) Forzar HTTPS (sin poner :443) y quitar el :443 en Location
app.use((req, res, next) => {
  const proto = req.get("x-forwarded-proto");
  if (proto && proto !== "https") {
    return res.redirect(301, `https://${req.hostname}${req.originalUrl}`);
  }
  next();
});

// 2) Canonical: www → apex (si tu dominio principal es apex)
app.use((req, res, next) => {
  if (req.hostname && req.hostname.startsWith("www.")) {
    const host = req.hostname.slice(4);
    return res.redirect(301, `https://${host}${req.originalUrl}`);
  }
  next();
});

// 3) Seguridad básica (CSP desactivada por ahora; la ajustamos luego)
app.use(
  helmet({
    contentSecurityPolicy: false, // activa más tarde con tu lista de orígenes
    frameguard: { action: "sameorigin" },
    referrerPolicy: { policy: "strict-origin-when-cross-origin" },
    crossOriginResourcePolicy: { policy: "cross-origin" },
  })
);

// Headers extra
app.use((req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader(
    "Permissions-Policy",
    "geolocation=(), microphone=(), camera=()"
  );
  next();
});

// 4) Compresión
app.use(compression());

// 5) Caché: HTML no cachear; assets con hash 1 año + immutable
app.use((req, res, next) => {
  if (/\.(?:js|css|png|jpg|jpeg|gif|svg|webp|ico|woff2?)$/i.test(req.url)) {
    res.setHeader("Cache-Control", "public, max-age=31536000, immutable");
  } else if (req.url === "/" || req.url.endsWith(".html")) {
    res.setHeader("Cache-Control", "public, max-age=0");
  }
  next();
});

// 6) Estáticos (ajusta la ruta del build si usas Vite/React)
const publicDir = path.join(__dirname, "dist"); // cambia si tu build es otro
app.use(express.static(publicDir));

// 7) robots.txt y sitemap.xml (sirve desde /public o /dist si los tienes ahí)
app.get("/robots.txt", (req, res) => {
  res.type("text/plain").send(
    `User-agent: *
Allow: /
Sitemap: https://thecookflow.com/sitemap.xml
`
  );
});

// 8) SPA fallback: sirve index.html para rutas no encontradas
app.get("*", (req, res) => {
  res.sendFile(path.join(publicDir, "index.html"));
});

// 9) Arranque
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`TheCookFlow listo en puerto ${PORT}`);
});