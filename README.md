# Mini Captura Offline-First en Flutter — Arquitectura Hexagonal Limpia

Este repositorio contiene una aplicación Flutter móvil diseñada para actuar como una herramienta de inspección de campo fuera de línea (Offline-First). El usuario puede registrar inspecciones (con nombre del lugar, categoría, foto capturada directamente desde la cámara del dispositivo y observaciones), guardarlas localmente y sincronizarlas de forma automática y transparente cuando hay conexión a internet.

El proyecto ha sido diseñado bajo los estrictos principios de la **Arquitectura Hexagonal (Puertos y Adaptadores)** para garantizar el desacoplamiento total de las reglas de negocio y facilitar las pruebas unitarias y de integración.

---

## 📐 Diseño de Arquitectura: Hexagonal (Ports & Adapters)

Para aislar por completo el núcleo de nuestra aplicación de las dependencias externas (como bases de datos locales, clientes de red HTTP y sensores de hardware), estructuramos la aplicación en capas concéntricas bien definidas:

```
lib/
├── domain/                         # Capa de Dominio (Núcleo Puro)
│   ├── models/
│   │   ├── inspection_model.dart   # Entidad inmutable (generada con Freezed)
│   │   ├── inspection_model.freezed.dart
│   │   └── inspection_model.g.dart
│   └── ports/                      # Contratos / Puertos (Interfaces)
│       ├── api_service_port.dart
│       ├── connectivity_service_port.dart
│       └── inspection_repository_port.dart
├── infrastructure/                 # Capa de Infraestructura (Librerías / SDKs)
│   └── adapters/                   # Adaptadores de Salida (Driven Adapters)
│       ├── connectivity_service_impl.dart
│       ├── hive_inspection_repository.dart
│       └── http_api_service.dart
├── logic/                          # Capa de Aplicación (Casos de Uso)
│   └── cubits/                     # Control de Estado y Formularios
│       ├── inspection_cubit.dart
│       ├── sync_cubit.dart
│       └── create_inspection_form_cubit.dart # Validador y orquestador del formulario
└── presentation/                   # Capa de Presentación (UI / Driving Adapters)
    ├── pages/                      # Pantallas principales
    │   ├── home_page.dart          # Panel principal / Dashboard minimalista
    │   ├── create_inspection_page.dart
    │   └── inspection_detail_page.dart
    ├── theme/
    │   └── app_theme.dart          # Sistema de diseño unificado (Slate & Indigo)
    └── widgets/                    # Widgets reutilizables y atómicos
        ├── app_snackbar.dart       # Gestor unificado de notificaciones flotantes
        ├── camera_view.dart        # Pantalla de cámara integrada
        ├── camera_stream_preview.dart # Visor de la transmisión en tiempo real de la cámara
        ├── camera_error_view.dart  # Pantalla de error de inicialización de cámara
        ├── connection_status_indicator.dart # Indicador de red en AppBar
        ├── inspection_card.dart    # Tarjeta de celda de la lista
        ├── photo_placeholder.dart  # Contenedor de selección/cambio de foto
        ├── sync_status_badge.dart  # Distintivo visual del estado de sincronización
        └── sync_warning_card.dart  # Tarjeta de alertas y reintentos manuales de sync
```

---

## 🛠️ Decisiones Técnicas Clave

### 1. Gestión de Estado: Cubit (`flutter_bloc`)
*   **Por qué Cubit**: Seleccionamos **Cubit** por encima de BLoC clásico para la gestión de estados. Reduce significativamente la cantidad de código repetitivo al no requerir la definición de clases de eventos (usa funciones directas). Conserva la misma robustez y separación de responsabilidades, facilitando pruebas unitarias estructuradas independientes de la UI.
*   **Formularios desacoplados**: Implementamos un Cubit exclusivo (`CreateInspectionFormCubit`) que aísla la validación de entrada de datos y previene que la capa visual asuma responsabilidades de negocio (como generar UUIDs o instanciar entidades).

### 2. Persistencia Local: Hive (`hive`)
*   **Por qué Hive**: Elegimos **Hive** por su velocidad y rendimiento excepcional al ser una base de datos NoSQL clave-valor escrita puramente en Dart.
*   **Ventajas**:
    *   **Sin dependencias nativas complejas**: A diferencia de SQLite o Drift, compila de forma directa en Dart puro, eliminando conflictos de Gradle en Android o CocoaPods en iOS.
    *   **Hexagonalidad intacta**: No acoplamos la entidad de dominio a Hive. El mapeo se realiza de forma manual en la capa de infraestructura, manteniendo el dominio 100% puro.

### 3. Cámara en Vivo (`camera`)
*   **Por qué camera**: Para cumplir con el requerimiento de usar la cámara integrada de la app sin delegar la captura a intents o aplicaciones externas del sistema operativo. La librería oficial `camera` nos permite instanciar el visor nativo en un widget (`CameraPreview`) y capturar la imagen de forma directa en tiempo de ejecución.

### 4. Compresión de Imagen (Algoritmo integrado en Flutter)
*   Para evitar subir archivos pesados (>5MB) en conexiones móviles inestables sin agregar dependencias nativas complejas, utilizamos el motor gráfico nativo de Flutter (`ui.instantiateImageCodec`). Redimensionamos la foto a un ancho máximo de 1080px (manteniendo el aspecto) y la volvemos a codificar en PNG comprimido, reduciendo el peso a ~200KB sin pérdida apreciable de nitidez.

### 5. Inmutabilidad de Datos con Freezed
*   **Por qué Freezed**: Adoptamos `freezed` para definir el modelo `InspectionModel`. Esto nos garantiza la inmutabilidad de los datos de las inspecciones y nos autogenera los métodos `copyWith`, serialización JSON (`toJson` / `fromJson`) y operadores de igualdad `==` y `hashCode` automáticos, previniendo fallos por mutación de estado accidental.

### 6. Detección de Conectividad (`connectivity_plus`)
*   **Por qué connectivity_plus**: Para implementar la cola offline-first, es crucial detectar el estado de conexión del dispositivo. Este paquete nos permite suscribirnos a los cambios de red en tiempo real. Cuando la conexión se restablece, el `SyncCubit` se notifica inmediatamente para desencadenar de forma transparente la sincronización de las inspecciones locales pendientes de subir.

---

## 🚀 Cómo Correr Localmente

### Prerrequisitos
- Tener instalado el SDK de Flutter (versión estable actual, >= 3.12.0).
- Un emulador (Android/iOS) iniciado o un dispositivo físico conectado con depuración USB activa.

### Pasos
1. **Clonar el repositorio**:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd xtruston
   ```
2. **Obtener dependencias y generar código**:
   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **Ejecutar pruebas unitarias e instrumentadas**:
   ```bash
   flutter test
   ```
4. **Ejecutar la aplicación**:
   - En tu emulador Android seleccionado:
     ```bash
     flutter run
     ```

---

## ⚙️ Arquitectura de Sincronización y Manejo de Conflictos

La aplicación opera bajo la siguiente lógica de sincronización:
1. **Guardado Inicial**: Toda inspección creada se guarda localmente en Hive en estado `pending`.
2. **Sincronización Directa**: Si se detecta que el dispositivo está en línea, se intenta enviar de inmediato la inspección al backend mock (`https://httpbin.org/post`). Si el envío es exitoso (HTTP 200/201), el estado cambia a `synced`.
3. **Cola de Reintento**: Si el dispositivo está sin conexión, se conserva el estado `pending`. Al restablecerse la conexión, el `SyncCubit` lee todas las inspecciones locales en estado `pending` y las procesa en orden secuencial.
4. **Manejo de Conflictos (Simulado - 50% de error)**: 
   - El adaptador `HttpApiService` tiene una lógica de depuración que simula errores aleatorios del 50%.
   - Si el envío falla por un error de red o de servidor (500), el registro continúa marcado como `pending` para volver a intentarse en el siguiente ciclo.
   - Si el servidor responde con un conflicto de negocio permanente (HTTP 409 Conflict), el estado se cambia a `conflict`. El usuario verá una alerta visual (con píldora roja) y podrá editar la observación de la inspección y forzar una re-sincronización manual en caliente mediante el botón "Sincronizar ahora".

---

## ⚠️ Limitaciones Detectadas

1. **Persistencia de Archivos Físicos**: Las fotos tomadas se almacenan en el directorio local de la aplicación. Si el usuario borra los datos de la app antes de sincronizar, las fotos físicas se perderán y la sincronización fallará.
2. **Tamaño de la Cola de Subida**: Actualmente, la sincronización reintenta subir todas las fotos secuencialmente. En escenarios con docenas de fotos pendientes muy grandes, esto podría saturar el ancho de banda; se recomienda implementar un límite de procesamiento por lotes en producción.
3. **Detección Falsa Positiva de Red**: `ConnectivityServiceImpl` indica si hay conexión física al router o red móvil, pero no necesariamente si hay acceso real a internet (portal cautivo o red sin salida). Esto se mitiga con validación y reintentos automáticos a nivel de petición HTTP.

---

## 🤖 Uso de Inteligencia Artificial (IA) y Validación

Este proyecto fue desarrollado en colaboración con un Asistente de IA (Antigravity por Google DeepMind).
*   **Partes en las que se utilizó**:
    - Diseño y estructuración de la Arquitectura Hexagonal Limpia (Ports & Adapters) separando las capas de dominio, lógica de aplicación, infraestructura y presentación.
    - Configuración inicial de los modelos inmutables y generadores de código.
    - Soporte en la lógica de la cola de sincronización offline-first, el manejo de reintentos automáticos y simulación de conflictos.
    - Apoyo en la optimización general de la interfaz gráfica y la modularización de componentes visuales independientes.
*   **Métodos de Validación**:
    - Ejecución de análisis estático (`flutter analyze`) para asegurar que no existan advertencias ni errores en el código Dart.
    - Desarrollo y ejecución de pruebas unitarias exhaustivas (`flutter test`) cubriendo la lógica de la cola de sincronización, almacenamiento en base de datos local y comportamiento de red.
