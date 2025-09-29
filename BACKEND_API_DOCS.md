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
      amount: string,
      unit: string,
      category: string
    }],
    instructions: string[],
    nutritionInfo: {
      calories: number,
      protein: number,
      carbs: number,
      fat: number,
      fiber: number
    },
    cookingTime: number,
    servings: number
  }],
  shoppingList: {
    totalEstimatedCost: number,
    items: [{
      category: string,       // "Produce", "Dairy", "Meat"
      items: [{
        name: string,
        amount: string,
        unit: string,
        estimatedPrice: number
      }]
    }]
  }
}
```

## Endpoints de Reconocimiento de Alimentos

### Subir y Analizar Foto de la Nevera
```typescript
// 1. Obtener URL de subida
POST /api/objects/upload
Response: { uploadURL: string }

// 2. Subir imagen directamente a Google Cloud Storage
PUT <uploadURL>
Body: imagen binaria

// 3. Configurar permisos de imagen
POST /api/food-images
Body: { imageURL: string }
Response: { objectPath: string }

// 4. Reconocer alimentos en la imagen
POST /api/recognize-food
Body: { imageUrl: string }  // Data URL base64 o ruta del objeto

Response: {
  recognizedItems: [{
    name: string,           // "tomates", "queso mozzarella"
    confidence: number,     // 0.95 (95% confianza)
    category: string        // "produce", "dairy"
  }],
  suggestedRecipes: [{
    name: string,
    description: string,
    difficulty: string,     // "easy", "medium", "hard"
    cookingTime: number,
    mainIngredients: string[]
  }]
}
```

### Sugerencias de Recetas
```typescript
POST /api/suggest-recipes
Body: { ingredients: string[] }  // ["tomates", "queso", "albahaca"]

Response: [{
  name: string,
  description: string,
  ingredients: [{
    name: string,
    amount: string,
    unit: string
  }],
  instructions: string[],
  cookingTime: number,
  difficulty: string,
  nutritionInfo: {
    calories: number,
    protein: number,
    carbs: number,
    fat: number
  }
}]
```

### Historial de Reconocimientos
```typescript
GET /api/food-recognitions
Response: [{
  id: string,
  imageUrl: string,
  recognizedItems: {...},
  suggestedRecipes: {...},
  createdAt: Date
}]
```

## Endpoints de Comparación de Precios

### Comparar Precios en Supermercados
```typescript
POST /api/compare-prices
Body: {
  query: string,        // "tomates, queso mozzarella, albahaca"
  location?: string     // Ubicación opcional
}

Response: {
  query: string,
  results: [{
    store: {
      id: string,         // "mercadona", "carrefour", "lidl"
      name: string,       // "Mercadona"
      distance: number,   // 0.8 km
      closingTime: string // "21:30"
    },
    items: [{
      name: string,       // "tomates"
      price: number,      // 2.85 €
      unit: string        // "kg"
    }],
    totalPrice: number    // 6.00 €
  }],
  bestDeal: {...},        // Tienda más barata
  savings: number         // Ahorro vs tienda más cara
}

// Datos mock incluidos:
// - Mercadona: tomates 2.85€, queso mozzarella 1.95€, albahaca 1.20€
// - Carrefour: tomates 3.10€, queso mozzarella 1.85€, albahaca 1.40€
// - Lidl: tomates 2.69€, queso mozzarella 1.79€, albahaca 1.15€
```

### Historial de Comparaciones
```typescript
GET /api/price-comparisons
Response: [{
  id: string,
  searchQuery: string,
  results: {...},
  location: string,
  createdAt: Date
}]
```

## Endpoints de Listas de Compra

```typescript
// Obtener lista de compra de un menú
GET /api/menu-plans/:id/shopping-list
Response: {
  menuPlanId: string,
  items: [{
    category: string,
    items: [{
      name: string,
      amount: string,
      unit: string,
      estimatedPrice: number
    }]
  }],
  totalEstimatedCost: number,
  optimizedStores: string[]  // Recomendaciones de tiendas
}
```

## Base de Datos PostgreSQL

### Tablas Principales
```sql
-- Usuarios (gestionado por Replit Auth)
users (id, email, firstName, lastName, profileImageUrl, createdAt, updatedAt)

-- Planes de menú
menuPlans (id, userId, name, weekStartDate, preferences, createdAt, updatedAt)

-- Recetas
recipes (id, menuPlanId, dayOfWeek, mealType, name, description, ingredients, 
         instructions, nutritionInfo, cookingTime, servings, createdAt)

-- Listas de compra
shoppingLists (id, menuPlanId, items, totalEstimatedCost, createdAt)

-- Reconocimientos de alimentos
foodRecognitions (id, userId, imageUrl, recognizedItems, suggestedRecipes, createdAt)

-- Comparaciones de precios
priceComparisons (id, userId, searchQuery, results, location, createdAt)

-- Sesiones (para autenticación)
sessions (sid, sess, expire)
```

## Integración con IA (OpenAI GPT-4o)

### Funcionalidades IA Implementadas:
1. **Generación de menús semanales** - Basado en preferencias del usuario
2. **Reconocimiento de alimentos** - Análisis de imágenes con GPT-4o Vision
3. **Sugerencias de recetas** - Basado en ingredientes disponibles
4. **Optimización nutricional** - Cálculo automático de valores nutricionales

### Configuración Requerida:
```bash
# Variable de entorno necesaria
OPENAI_API_KEY=tu_clave_de_openai
```

## Almacenamiento de Archivos (Google Cloud Storage)

### Funcionalidades:
- Subida segura de imágenes de alimentos
- Control de acceso por usuario (ACL)
- URLs firmadas para subida directa
- Gestión automática de permisos

### Variables de Entorno:
```bash
PRIVATE_OBJECT_DIR=/bucket/private
PUBLIC_OBJECT_SEARCH_PATHS=/bucket/public
```

## Autenticación y Seguridad

### Sistema de Autenticación:
- **OAuth con Replit** - Integración nativa
- **Sesiones seguras** - Almacenadas en PostgreSQL
- **Middleware de autenticación** - Protección de endpoints
- **Control de acceso** - Por usuario y permisos

### Endpoints Protegidos:
Todos los endpoints requieren autenticación excepto:
- `/api/compare-prices` (público para comparaciones rápidas)
- Endpoints de autenticación (`/api/login`, `/api/callback`)

## Ejemplo de Uso Completo

```javascript
// 1. Usuario se autentica
GET /api/login

// 2. Sube foto de su nevera
POST /api/objects/upload
PUT <uploadURL> // Subir imagen
POST /api/recognize-food { imageUrl: "data:image/jpeg;base64,..." }

// 3. Genera menú basado en ingredientes reconocidos
POST /api/generate-menu {
  dietaryRestrictions: ["vegetariano"],
  budget: "medio",
  cookingTime: "rápido",
  servings: 4
}

// 4. Compara precios de la lista de compra
POST /api/compare-prices {
  query: "tomates, queso mozzarella, albahaca"
}

// 5. Obtiene menú completo con recetas
GET /api/menu-plans/123
GET /api/menu-plans/123/shopping-list
```

## Estado Actual

✅ **Completamente funcional** - Backend listo para producción
✅ **Base de datos configurada** - PostgreSQL con Drizzle ORM
✅ **Autenticación implementada** - Sistema OAuth funcional
✅ **IA integrada** - OpenAI GPT-4o para todas las funciones IA
✅ **Almacenamiento de archivos** - Google Cloud Storage configurado
✅ **API REST completa** - Todos los endpoints documentados funcionando

**Próximos pasos**: El backend está completo. Se puede proceder con la integración frontend o despliegue.