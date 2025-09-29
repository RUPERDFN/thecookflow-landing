# TheCookFlow - Backend API Documentation

## Arquitectura del Backend

TheCookFlow utiliza un backend completo en **TypeScript + Express.js + PostgreSQL** que proporciona todas las funcionalidades requeridas:

- ✅ **Autenticación de usuarios** (Replit OAuth)
- ✅ **Gestión de menús y recetas** (Base de datos PostgreSQL)
- ✅ **Subida de imágenes y reconocimiento de alimentos** (Google Cloud Storage + OpenAI Vision)
- ✅ **Comparación de precios de supermercados** (Datos mock de Mercadona, Carrefour, Lidl)
- ✅ **Generación de menús con IA** (OpenAI GPT-4o)

## Estructura de Archivos

```
server/
├── index.ts           # Servidor principal Express
├── routes.ts          # Todos los endpoints de la API
├── storage.ts         # Interfaz de almacenamiento (PostgreSQL)
├── openai.ts          # Integración con OpenAI para IA
├── replitAuth.ts      # Sistema de autenticación
├── objectStorage.ts   # Gestión de archivos (Google Cloud)
├── objectAcl.ts       # Control de acceso a archivos
└── db.ts             # Configuración de base de datos

shared/
└── schema.ts         # Esquemas de datos Drizzle ORM

Base de datos: PostgreSQL via Neon Database
```

## Endpoints de Autenticación

### Login y Logout
```typescript
GET  /api/login     // Iniciar sesión con Replit OAuth
GET  /api/logout    // Cerrar sesión
GET  /api/callback  // Callback OAuth (automático)
```

### Usuario Autenticado
```typescript
GET /api/auth/user
// Respuesta: { id, email, firstName, lastName, profileImageUrl }
```

## Endpoints de Menús y Recetas

### Gestión de Planes de Menú
```typescript
// Crear plan de menú
POST /api/menu-plans
Body: {
  name: string,
  weekStartDate: Date,
  preferences: {
    dietaryRestrictions: string[],
    budget: string,
    cookingTime: string,
    servings: number
  }
}

// Obtener planes del usuario
GET /api/menu-plans
Response: MenuPlan[]

// Obtener plan específico con recetas
GET /api/menu-plans/:id
Response: { ...menuPlan, recipes: Recipe[] }

// Eliminar plan
DELETE /api/menu-plans/:id
```

### Generación Automática de Menús con IA
```typescript
POST /api/generate-menu
Body: {
  dietaryRestrictions: string[],  // ["vegetariano", "sin gluten"]
  budget: string,                 // "económico", "medio", "premium"
  cookingTime: string,           // "rápido", "medio", "elaborado"
  servings: number,              // 2, 4, 6...
  cuisine?: string[],            // ["mediterránea", "asiática"]
  allergies?: string[]           // ["frutos secos", "lácteos"]
}

Response: {
  menuPlan: {
    id: string,
    name: string,
    weekStartDate: Date
  },
  recipes: [{
    dayOfWeek: number,        // 0-6 (Lunes=0)
    mealType: string,         // "breakfast", "lunch", "dinner"
    name: string,
    description: string,
    ingredients: [{
      name: string,
```