# Prueba-Técnica-Desarrollador-Full-Stack-3LOX

Solución a la prueba técnica Full Stack: plataforma de evaluación psicométrica.  
Backend en .NET 8 con PostgreSQL; Frontend en Flutter/FlutterFlow.  
Evalúa habilidades técnicas, diseño de software y comprensión de negocio.  
Incluye gestión de usuarios, tests, respuestas y reportes con arquitectura limpia y autenticación JWT.

---

## ⚠️ Seguridad y claves

- Las claves y cadenas de conexión presentes en `appsettings.json` y `appsettings.Development.json` **son solo para fines de desarrollo y pruebas técnicas**.
- **No uses estas claves en producción.**
- Para producción, utiliza variables de entorno o gestores de secretos como [dotnet user-secrets](https://learn.microsoft.com/en-us/aspnet/core/security/app-secrets) o Azure Key Vault.

## Configuración local

1. Clona el repositorio.
2. Restaura los paquetes NuGet:
   ```sh
   dotnet restore
   ```
3. Configura tus propias claves si lo deseas:
   ```sh
   dotnet user-secrets set "Jwt:Key" "tu-clave-super-secreta"
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "tu-cadena-de-conexion"
   ```
4. Ejecuta las migraciones y la aplicación:
   ```sh
   dotnet ef database update
   dotnet run --project PsychometricsApp/WebAPI
   ```

## Notas

- El endpoint de usuarios (`/api/users`) está protegido y requiere autenticación JWT con rol `Admin`.
- Las contraseñas de usuario se almacenan de forma segura usando hashing.
- Para pruebas, puedes usar las claves incluidas, pero **no las uses en ambientes reales**.

---
