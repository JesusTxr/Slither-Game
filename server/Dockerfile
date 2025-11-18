# Usa la imagen oficial de Dart
FROM dart:stable AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de dependencias
COPY pubspec.yaml ./

# Descarga las dependencias
RUN dart pub get

# Copia el código fuente
COPY . .

# Compila el servidor a código nativo para mejor rendimiento
RUN dart compile exe server.dart -o server

# Imagen final más pequeña
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/server

# Expone el puerto (Render usa la variable PORT)
EXPOSE 8080

# Comando para ejecutar el servidor
CMD ["/app/server"]

