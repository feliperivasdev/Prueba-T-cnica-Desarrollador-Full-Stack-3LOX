# Prueba-Técnica-Desarrollador-Full-Stack-3LOX

Solución a la prueba técnica Full Stack: plataforma de evaluación psicométrica.  
Backend en .NET 8 con PostgreSQL; Frontend en Flutter/FlutterFlow.  
Evalúa habilidades técnicas, diseño de software y comprensión de negocio.  
Incluye gestión de usuarios, tests, respuestas y reportes con arquitectura limpia y autenticación JWT.

---

## Instrucciones para correr el proyecto localmente

### Backend (.NET 8)

1. Ve a la carpeta `/Backend`:
   ```sh
   cd Backend
   ```
2. Restaura los paquetes NuGet:
   ```sh
   dotnet restore
   ```
3. Configura tus propias claves si lo deseas (opcional):
   ```sh
   dotnet user-secrets set "Jwt:Key" "tu-clave-super-secreta"
   dotnet user-secrets set "ConnectionStrings:DefaultConnection" "tu-cadena-de-conexion"
   ```
4. Ejecuta las migraciones y la aplicación:
   ```sh
   dotnet ef database update
   dotnet run --project PsychometricApp.WebApi
   ```
5. El backend estará disponible en: `http://localhost:5194`

### Frontend (Flutter)

1. Ve a la carpeta `/Frontend/front_psychometric`:
   ```sh
   cd Frontend/front_psychometric
   ```
2. Instala las dependencias:
   ```sh
   flutter pub get
   ```
3. Corre la aplicación:
   ```sh
   flutter run -d chrome
   ```
4. El frontend estará disponible en: `http://localhost:8080` (o el puerto que indique Flutter)

---

## Usuarios de prueba

Puedes iniciar sesión con cualquiera de los siguientes usuarios. **La contraseña para todos es:** `MiClaveSegura123`

| Rol         | Correo                        |
|-------------|-------------------------------|
| admin       | davidgustin@3lox.com          |
| corporate   | juanperez@3lox.com            |
| assessment  | usuarioprueba@3lox.com        |
| assessment  | isabellarivas@3lox.com        |
| assessment  | testuser@3lox.com             |

---

## Notas

- El endpoint de usuarios (`/api/users`) está protegido y requiere autenticación JWT con rol `admin` o `corporate`.
- Las contraseñas de usuario se almacenan de forma segura usando hashing.
- Para pruebas, puedes usar las claves incluidas, pero **no las uses en ambientes reales**.
- Si tienes problemas con las migraciones, revisa la cadena de conexión y los permisos de tu base de datos PostgreSQL.

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
