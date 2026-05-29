# Mini Captura Offline-First en Flutter — Arquitectura Hexagonal Limpia

Este repositorio contiene una aplicación Flutter móvil diseñada para actuar como una herramienta de inspección de campo fuera de línea (Offline-First). El usuario puede registrar inspecciones (con nombre del lugar, categoría, foto capturada directamente desde la cámara del dispositivo y observaciones), guardarlas localmente y sincronizarlas de forma automática y transparente cuando hay conexión a internet.

El proyecto ha sido diseñado bajo los estrictos principios de la **Arquitectura Hexagonal (Puertos y Adaptadores)** para garantizar el desacoplamiento total de las reglas de negocio y facilitar las pruebas unitarias y de integración.

---

## 📐 Diseño de Arquitectura: Hexagonal (Ports & Adapters)

Para aislar por completo el núcleo de nuestra aplicación de las dependencias externas (como bases de datos locales, clientes de red HTTP y sensores de hardware), estructuramos la aplicación en tres capas concéntricas bien definidas:

```
lib/
├── domain/                         # Capa de Dominio (Núcleo Puro)
│   ├── models/
│   │   └── inspection_model.dart   # Entidad pura del dominio
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
│   └── cubits/                     # Control de Estado (Inbound Ports / Controllers)
│       ├── inspection_cubit.dart
│       └── sync_cubit.dart
└── presentation/                   # Capa de Presentación (UI / Driving Adapters)
    ├── pages/                      # HomePage, CreateInspectionPage, InspectionDetailPage
    └── widgets/                    # CameraView, etc.
```

### 1. El Dominio (Domain)
*   **Inspección (`InspectionModel`)**: La entidad de negocio que representa un reporte de campo.
*   **Puertos (Ports)**: Interfaces de Dart puras que declaran cómo se comunicará el núcleo con el mundo exterior.
    *   `InspectionRepositoryPort`: Define el contrato para guardar y obtener reportes locales.
    *   `ApiServicePort`: Define el contrato para subir los reportes al servidor.
    *   `ConnectivityServicePort`: Define el contrato para monitorear el estado del internet.

### 2. La Infraestructura (Adapters)
Los adaptadores implementan las interfaces del dominio utilizando librerías específicas:
*   `HiveInspectionRepository`: Implementa la base de datos local usando **Hive**.
*   `HttpApiService`: Se comunica con el API mock de **httpbin.org** usando la librería `http`. Implementa la lógica de reintento ante errores de red (500) y la detección de conflictos (409).
*   `ConnectivityServiceImpl`: Implementa el sensor de red usando **`connectivity_plus`**.

### 3. La Lógica de Aplicación (Cubits)
Los Cubits (`InspectionCubit` y `SyncCubit`) representan nuestros casos de uso. Gracias al principio de **Inversión de Dependencias (DIP)**:
*   Los Cubits **no importan ni conocen** a Hive, a httpbin ni a connectivity_plus.
*   Solo interactúan a través de los **Puertos abstractos** del dominio.
*   Esto nos permite realizar pruebas unitarias hiper-limpias implementando dobles de prueba manuales (`FakeBox`, `MockApiService` y `MockConnectivityService`) en segundos, sin requerir pesados generadores de código (`build_runner` / Mockito).

---

## 🛠️ Decisiones Técnicas Clave

### 1. Gestión de Estado: Cubit (`flutter_bloc`)
*   **Por qué Cubit**: Para este reto técnico seleccionamos **Cubit** por encima de BLoC clásico. Cubit reduce significativamente la cantidad de código repetitivo al no requerir la definición de clases de eventos (usa funciones/métodos directos). Mantiene la misma robustez en la separación de interfaz y lógica de negocio, y nos permite realizar pruebas unitarias estructuradas independientes del contexto visual utilizando `bloc_test`.

### 2. Persistencia Local: Hive (`hive`)
*   **Por qué Hive**: Optamos por **Hive** por su rendimiento excepcional (es una base de datos NoSQL clave-valor ultrarrápida escrita puramente en Dart) y su facilidad de integración. 
*   **Ventajas**:
    *   **Sin dependencias nativas complejas**: A diferencia de Drift o sqflite, Hive compila directamente en Dart puro y no genera conflictos en plataformas de desarrollo.
    *   **Uso como Adaptador**: Permite instanciar la base de datos como un adaptador concreto (`HiveInspectionRepository`) que se inyecta en el puerto del repositorio de forma transparente.

### 3. Cámara en Vivo (`camera`)
*   **Por qué camera**: Para cumplir con el requerimiento de usar la cámara real del dispositivo (y no un picker de galería o invocar la app de cámara del sistema operativo mediante un intent externo). La librería oficial `camera` de Flutter nos permite instanciar un `CameraController`, desplegar un widget de vista previa (`CameraPreview`) y capturar la imagen en tiempo de ejecución, guardándola de forma privada en el almacenamiento temporal de la aplicación.

### 4. Compresión de Imagen (Algoritmo integrado en Flutter)
*   Las imágenes de cámaras móviles modernas pueden pesar más de 5MB. Subir esto a un backend mock en conexiones móviles lentas es inviable. Para comprimir la imagen sin añadir librerías nativas adicionales, utilizamos el motor gráfico nativo de Flutter (`ui.instantiateImageCodec`). El flujo decodifica la imagen capturada, la redimensiona a un ancho máximo de 1080px (manteniendo el aspecto) y la vuelve a codificar en PNG con calidad reducida, logrando archivos de apenas ~200KB sin pérdida apreciable de nitidez para una inspección.

---

## 🚀 Cómo Correr Localmente

### Prerrequisitos
- Tener instalado el SDK de Flutter (versión estable actual, >= 3.12.0).
- Un emulador (Android/iOS) iniciado o un dispositivo físico conectado con depuración USB activa.

### Pasos
1. **Clonar el repositorio**:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd test_flutter
   ```
2. **Obtener dependencias**:
   ```bash
   flutter pub get
   ```
3. **Ejecutar pruebas unitarias**:
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
   - Si el envío falla por un error temporal de red o de servidor (500), el registro continúa marcado como `pending` para volver a intentarse en el siguiente ciclo.
   - Si el servidor responde con un conflicto de negocio permanente (HTTP 409 Conflict), el estado se actualiza localmente a `conflict`. El usuario verá una alerta visual en la pantalla principal y en el detalle, y podrá editar la observación de la inspección y forzar una re-sincronización manual en caliente.

---

## ⚠️ Limitaciones Detectadas

1. **Persistencia de Archivos Físicos**: Las fotos tomadas se almacenan en el directorio local de la aplicación. Si el usuario borra los datos de la app antes de sincronizar, las fotos físicas se perderán y la sincronización fallará.
2. **Tamaño de la Cola de Subida**: Actualmente, la sincronización reintenta subir todas las fotos secuencialmente. En escenarios con docenas de fotos pendientes muy grandes, esto podría saturar el ancho de banda; se recomienda implementar un límite de procesamiento por lotes en producción.
3. **Detección Falsa Positiva de Red**: `ConnectivityServiceImpl` indica si hay conexión física al router o red móvil, pero no necesariamente si hay acceso real a internet (portal cautivo o red sin salida). Esto se mitiga con validación y reintentos automáticos a nivel de petición HTTP.

---

## 🤖 Uso de Inteligencia Artificial (IA) y Validación

Este proyecto fue desarrollado en colaboración con un Asistente de IA (Antigravity por Google DeepMind).
*   **Partes en las que se utilizó**:
    - Estructuración y migración hacia el patrón de Arquitectura Hexagonal Limpia (separación en carpetas `domain`, `infrastructure`, `logic`, `presentation`).
    - Creación de los Puertos (Interfaces) y Adaptadores concretos que los implementan.
    - Configuración y diseño de los mocks manuales del test suite de la cola de sincronización.
*   **Métodos de Validación**:
    - Se corrió el set de pruebas unitarias (`flutter test`) simulando streams de conectividad.
    - Se realizaron validaciones y revisiones de compilación de Gradle (`build.gradle.kts`) en Android para asegurar la compatibilidad con SDKs antiguos y modernos (fijando compileSdk en 36).
