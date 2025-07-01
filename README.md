# **Kotlin:**
Este proyecto implementa un servicio de ubicación en segundo plano, utilizando `MethodChannel` y `EventChannel` para conectar el código nativo con Flutter.

## Componentes

### LocationForegroundService

•  Servicio en primer plano que obtiene ubicaciones cada 2.5 segundos con alta precisión usando `FusedLocationProviderClient`.

•  Muestra una notificación persistente con las coordenadas

* Inicia en `onCreate, detiene actualizaciones en ``onDestroy. Verifica el permiso ``ACCESS_FINE_LOCATION`.

### MainActivity

•  ***EventChannel***: Envía coordenadas a Flutter cada 2.5 segundos.

•  ***MethodChannel***: Permite a Flutter iniciar/detener el servicio con métodos `startService` y `stopService`.

•  Envía la última ubicación conocida o notifica errores si faltan permisos o datos.

## **Propósito del MethodChannel**

El `MethodChannel` actúa como puente para que Flutter invoque funciones nativas de Android, controlando el servicio en segundo plano desde el código Dart.

# gtu_driver_app:

## Conexión con el Backend – Carpeta `services`

En esta arquitectura Flutter, la carpeta `services` agrupa los distintos servicios responsables de interactuar con el backend, tales como autenticación, gestión de turnos y operaciones relacionadas con rutas.

### Estructura

Cada servicio encapsula métodos que permiten enviar y recibir datos desde el backend. Algunos ejemplos incluyen:

- `LoginService`: gestiona el envío de credenciales (usuario y contraseña) para autenticar al usuario.  
- `HomePageService`: permite iniciar y finalizar turnos.  
- `AuthService`: administra la autenticación y el manejo seguro de tokens.  
- `WebSocketService`: establece una conexión en tiempo real con el backend para transmitir la ubicación del dispositivo.  
- `RoutesService`: maneja todas las peticiones relacionadas con rutas.

### Patrón de uso

- Los métodos definidos en estos servicios devuelven objetos modelo que actualizan el estado de la aplicación en función de los datos obtenidos del backend.  
- En el caso de la autenticación, se utilizan tokens que se almacenan de forma segura y se reutilizan para autorizar futuras solicitudes.

---

## Flujo de la Aplicación

La navegación y las pantallas principales de la aplicación se estructuran en torno a tres etapas clave:

### a. Inicio de sesión

- El usuario accede a una pantalla de login e ingresa sus credenciales.  
- La aplicación llama a un método del `AuthService`, que realiza una petición al backend para validar la información.  
- Si la autenticación es exitosa, se recibe un token o un objeto usuario, que se almacena localmente.  
- El usuario es entonces redirigido a la pantalla principal (`HomePage`).

### b. Inicio de turno

- Una vez autenticado, el usuario puede iniciar un turno, consultar su perfil o visualizar rutas.  
- Al presionar el botón “Iniciar Turno”, la aplicación establece una conexión con el backend mediante el `WebSocketService`.  
- Este servicio registra el inicio del turno y comienza a enviar la ubicación actual del dispositivo.  
- El backend responde con los datos del turno activo, incluyendo latitud y longitud, que la app utiliza para mostrar la ubicación del conductor en tiempo real.

### c. Finalización de turno

- Cuando el usuario decide terminar su jornada, selecciona la opción “Finalizar Turno”.  
- Esto ejecuta un método del servicio de turnos que notifica al backend que el turno debe cerrarse.  
- Una vez confirmada la finalización, la aplicación puede mostrar un resumen del turno y, si el usuario lo desea, permitir iniciar uno nuevo.
