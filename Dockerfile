# Dockerfile para Flutter Web - Colectivo (Versión Robusta)
# Utiliza una imagen base de Flutter probada y popular.
FROM bluefireteam/flutter:stable as build

# Argumento para la URL del API, con un valor por defecto seguro.
ARG API_BASE_URL=http://localhost:5000/api

# Establecer el directorio de trabajo.
WORKDIR /app

# Copiar los archivos de definición de dependencias primero para aprovechar el caché de Docker.
COPY pubspec.* ./

# Copiar el resto del código fuente.
COPY . .

# Ejecutar una secuencia de comandos robusta para asegurar un entorno limpio y compilación detallada.
# 1. Marcar el repositorio como seguro para Git.
# 2. Limpiar artefactos de compilación anteriores.
# 3. Obtener dependencias.
# 4. Ejecutar 'flutter doctor' para diagnóstico.
# 5. Construir la aplicación web con salida detallada.
RUN |
  git config --global --add safe.directory /app && \
  flutter clean && \
  flutter pub get && \
  flutter doctor -v && \
  flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL} -v

# --- Etapa de Producción ---
# Utiliza una imagen de servidor web ligera para servir el contenido.
FROM nginx:stable-alpine

# Copiar los archivos de la aplicación web construidos desde la etapa de 'build'.
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto 80 (puerto por defecto de Nginx).
EXPOSE 80

# El comando por defecto de la imagen de Nginx ya inicia el servidor,
# por lo que no se necesita un CMD explícito.
