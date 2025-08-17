#!/bin/bash

# Script de despliegue para Colectivo - Flutter Web
echo "🚀 Iniciando despliegue de Colectivo..."

# Verificar que Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado. Por favor instale Flutter primero."
    exit 1
fi

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker no está instalado. Por favor instale Docker primero."
    exit 1
fi

echo "✅ Verificaciones iniciales completadas"

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar archivos de código
echo "🔨 Generando archivos de código..."
flutter packages pub run build_runner build

# Analizar código
echo "🔍 Analizando código..."
flutter analyze

# Ejecutar tests
echo "🧪 Ejecutando tests..."
flutter test

# Compilar para web
echo "🏗️ Compilando aplicación para web..."
flutter build web --release

# Construir imagen Docker
echo "🐳 Construyendo imagen Docker..."
docker build -t colectivo-web:latest .

# Verificar que la imagen se creó correctamente
if [ $? -eq 0 ]; then
    echo "✅ Imagen Docker creada exitosamente"
    echo "📋 Para ejecutar la aplicación:"
    echo "   docker run -d -p 8080:8080 --name colectivo-web colectivo-web:latest"
    echo "   O usar: docker-compose up -d"
    echo ""
    echo "🌐 La aplicación estará disponible en: http://localhost:8080"
    echo ""
    echo "👥 Usuarios de prueba:"
    echo "   Admin: admin / admin123"
    echo "   Registrador: registrador1 / reg123"
else
    echo "❌ Error al construir la imagen Docker"
    exit 1
fi

echo "🎉 Despliegue completado exitosamente!"
