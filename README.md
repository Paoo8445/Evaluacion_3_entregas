# Evaluacion_3_entregas
Sistema de gestión de entregas con Flutter, FastAPI y MySQL


# Sistema de Gestión de Entregas Móviles - Paquexpress S.A. de C.V.

## Descripción del Proyecto
Esta solución fue desarrollada para agentes de campo para mejorar la **trazabilidad** y la **seguridad** en el proceso de entrega. El sistema utiliza una arquitectura completamente desacoplada para garantizar la integridad de la entrega mediante la captura de evidencia fotográfica (cámara) y geolocalización (GPS).

## Stack Tecnológico
El proyecto se basa en un diseño modular Cliente-Servidor:

| Componente | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Backend/API** | **FastAPI (Python)** | Provee los endpoints de Login, Listado de Paquetes y el registro transaccional de entregas, con encriptación SHA-256. |
| **Frontend/App** | **Flutter (Dart)** | Aplicación móvil que integra los sensores de Cámara, GPS y Mapa (`flutter_map`) para consumo del API. |
| **Base de Datos** | **MySQL** | Almacenamiento de agentes, paquetes y registros de entrega (Modelo E-R incluido). |

## Credenciales de Prueba
Utiliza estas credenciales para probar el flujo completo del sistema:

| Campo | Valor | Observación de Seguridad |
| :--- | :--- | :--- |
| **Email** | `paola@gmail.com` | |
| **Contraseña** | `123456` | |
| **Hash SHA256** | `8d969eef6ecad3c29a3a629280e686be4f32c3f81e00e882a89345c71d3731a2` | Hash almacenado en la tabla `agentes`. |

---

## Guía de Instalación y Uso

### 1. Configuración de la Base de Datos (MySQL)

1.  Crear la base de datos `eva3`.
2.  Ejecutar el archivo **`script_mysql.sql`** incluido en este repositorio. Este script crea las tablas y carga los datos de prueba iniciales.

### 2. Despliegue del Backend (FastAPI)

1.  **Instalar dependencias:** `pip install fastapi uvicorn pymysql python-multipart`
2.  **Crear directorio de archivos:** Es **obligatorio** crear la carpeta **`uploads`** en la raíz del backend (donde está `main.py`). La API la usará para guardar las fotos de evidencia.
3.  **Iniciar el servidor:** `uvicorn main:app --reload --host 0.0.0.0 --port 8000`

### 3. Ejecución de la Aplicación Móvil (Flutter)

1.  **Ajuste de URL:** Si usa un emulador de Android, cambie `http://localhost:8000` a **`http://10.0.2.2:8000`** en los archivos `login.dart`, `paquetes.dart` y `entrega.dart`.
2.  **Instalar dependencias:** `flutter pub get`
3.  **Ejecutar la App:** `flutter run` en la carpeta raíz del proyecto Flutter.

---
