# Dockerfile para Flutter Web - Colectivo
FROM ghcr.io/cirruslabs/flutter:stable as build

# Build-time API base URL (optional)
ARG API_BASE_URL=http://45.130.104.156:5000/api

# Copiar archivos del proyecto
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

COPY . .

# Diagnosticar el entorno de Flutter
RUN flutter doctor -v

# Construir la aplicación web con salida detallada
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL -v

# Imagen para servir la aplicación
FROM node:18-alpine

# Instalar http-server globalmente
RUN npm install -g http-server

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos construidos
COPY --from=build /app/build/web /app

# Exponer puerto
EXPOSE 8080

# Comando para ejecutar el servidor
CMD ["http-server", "-p", "8080", "-c-1"]
