# TheCookFlow - Sistema de Suscripción Automatizado

## Flujo Implementado

### 1. REGISTRO DEL USUARIO
```javascript
// En server/storage.ts - upsertUser()
const trialEndsAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 días
subscriptionStatus: 'trial'
```

### 2. VERIFICACIÓN DE ACCESO
```javascript
// Middleware en server/routes.ts
app.post("/api/generate-menu", authenticateToken, verifyMenuGenerationLimits, ...)

// Límites automáticos:
- Trial: 2 menús/semana, 2 personas, Lun-Vie, 3 comidas
- Premium: Ilimitado, hasta 10 personas, 7 días, 5 comidas
```

### 3. INTEGRACIÓN CON STRIPE
```javascript
// Webhook automático en server/stripe.ts
case 'customer.subscription.created': // Usuario se suscribe
case 'invoice.payment_succeeded':     // Pago exitoso  
case 'customer.subscription.deleted': // Cancelación
```

### 4. CRON JOB AUTOMÁTICO
```javascript
// Cada hora expira trials vencidos
setInterval(async () => {
  await expireTrialUsers();
}, 60 * 60 * 1000);
```

## API Endpoints Implementados

- `POST /api/subscription/create` - Crear suscripción Stripe
- `POST /api/subscription/cancel` - Cancelar suscripción  
- `GET /api/subscription/status` - Estado actual del usuario
- `POST /api/stripe/webhook` - Webhook de Stripe (automático)

## Estados de Suscripción

1. **trial** - 7 días gratis con limitaciones
2. **active** - Suscripción premium activa (€1.99/mes)
3. **canceled** - Suscripción cancelada
4. **expired** - Trial expirado, sin acceso
5. **past_due** - Pago fallido

## Verificaciones Automáticas

✅ Al registrarse: Trial activado automáticamente
✅ Al generar menú: Verificación de límites
✅ Cambios en Stripe: Webhook actualiza estado
✅ Cada hora: Expira trials vencidos
✅ Frontend: Estado en tiempo real