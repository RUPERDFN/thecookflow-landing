#!/bin/bash

echo "🧪 PROBANDO TODAS LAS FUNCIONALIDADES DE THECOOKFLOW"
echo "=================================================="

BASE_URL="http://localhost:5000"
SUCCESS_COUNT=0
TOTAL_TESTS=0

# Función para mostrar resultados
test_result() {
    local test_name="$1"
    local status_code="$2"
    local expected="$3"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$status_code" = "$expected" ]; then
        echo "✅ $test_name - OK (status: $status_code)"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ $test_name - FAIL (status: $status_code, expected: $expected)"
    fi
}

# Función para probar endpoints
test_endpoint() {
    local method="$1"
    local endpoint="$2"
    local test_name="$3"
    local expected_status="$4"
    local data="$5"
    
    if [ "$method" = "GET" ]; then
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$endpoint")
    elif [ "$method" = "POST" ]; then
        status_code=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$BASE_URL$endpoint")
    fi
    
    test_result "$test_name" "$status_code" "$expected_status"
}

echo ""
echo "🏥 PROBANDO ENDPOINTS DE SALUD"
echo "================================"

# Test health endpoints
test_endpoint "GET" "/api/health" "Health Check" "200"
test_endpoint "GET" "/ready" "Readiness Check" "200"

echo ""
echo "🔐 PROBANDO ENDPOINTS DE AUTENTICACIÓN (sin token)"
echo "================================================="

# Test auth endpoints without token (should return 401)
test_endpoint "POST" "/api/generate-menu" "Generate Menu (sin auth)" "401" '{"preferences": {}}'
test_endpoint "POST" "/api/recognize-food" "Food Recognition (sin auth)" "401" '{"image": "test"}'
test_endpoint "GET" "/api/menu-plans" "Get Menu Plans (sin auth)" "401"

echo ""
echo "🧮 PROBANDO ANÁLISIS DE TOKENS"
echo "==============================="

# Test token analysis (public endpoint)
test_endpoint "GET" "/api/token-analysis?prompt=Genera%20un%20men%C3%BA%20vegetariano" "Token Analysis" "200"

echo ""
echo "📂 PROBANDO OBJECT STORAGE"
echo "=========================="

# Test object storage endpoints
test_endpoint "POST" "/api/upload" "Upload Endpoint (sin auth)" "401" '{"fileName": "test.jpg", "fileType": "image/jpeg", "content": "base64data"}'

echo ""
echo "🌐 PROBANDO PÁGINAS FRONTEND"
echo "============================"

# Test frontend pages
test_endpoint "GET" "/" "Landing Page" "200"
test_endpoint "GET" "/demo/questionnaire" "Questionnaire Demo" "200"
test_endpoint "GET" "/demo/generator" "Generator Demo" "200"
test_endpoint "GET" "/demo/skinchef" "SkinChef Demo" "200"

echo ""
echo "📁 PROBANDO ARCHIVOS ESTÁTICOS"
echo "==============================="

# Test static assets
test_endpoint "GET" "/logo.PNG" "Logo File" "200"
test_endpoint "GET" "/robots.txt" "Robots.txt" "200"
test_endpoint "GET" "/sitemap.xml" "Sitemap" "200"
test_endpoint "GET" "/og-image.svg" "Open Graph Image" "200"
test_endpoint "GET" "/twitter-card.svg" "Twitter Card Image" "200"

echo ""
echo "📊 RESUMEN DE PRUEBAS"
echo "===================="
echo "Total de pruebas: $TOTAL_TESTS"
echo "Exitosas: $SUCCESS_COUNT"
echo "Fallidas: $((TOTAL_TESTS - SUCCESS_COUNT))"
echo "Porcentaje de éxito: $(( (SUCCESS_COUNT * 100) / TOTAL_TESTS ))%"

if [ $SUCCESS_COUNT -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 ¡TODAS LAS PRUEBAS PASARON! TheCookFlow está funcionando correctamente."
else
    echo ""
    echo "⚠️  Algunas pruebas fallaron. Revisar los logs para más detalles."
fi

echo ""
echo "🔗 URLs de prueba manual:"
echo "========================"
echo "• Landing Page: http://localhost:5000/"
echo "• Questionnaire Demo: http://localhost:5000/demo/questionnaire"
echo "• Generator Demo: http://localhost:5000/demo/generator"
echo "• SkinChef Demo: http://localhost:5000/demo/skinchef"
echo "• Health Check: http://localhost:5000/api/health"
echo "• Token Analysis: http://localhost:5000/api/token-analysis?prompt=test"