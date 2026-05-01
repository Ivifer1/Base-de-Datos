# Sistema de Gestión para Museos de Arte

## Descripción del Proyecto
Este proyecto consiste en el diseño e implementación de un sistema de base de datos transaccional (**OLTP**) para la gestión integral de museos de arte. El sistema está diseñado bajo un enfoque generalista, permitiendo que cualquier institución museística administre su estructura organizacional, recursos humanos, colecciones de arte y procesos operativos.

El objetivo principal es modernizar la gestión de los museos, facilitando no solo el almacenamiento eficiente de datos, sino también la generación de valor didáctico y educativo para el público.

## Características Principales

El sistema automatiza dos áreas críticas de negocio:

### 1. Administración de Recursos Humanos (RRHH)
* **Registro de Empleados:** Gestión de información básica, formación profesional (títulos, especialidades) e idiomas.
* **Historial Laboral:** Seguimiento detallado de la antigüedad y los roles desempeñados dentro de la institución.
* **Asignaciones Especiales:** Control de turnos de vigilancia y gestión de programas de mantenimiento de obras de arte realizados por personal especializado (curadores y restauradores).

### Administración General del Museo
* **Gestión de Obras y Colecciones:** Catalogación detallada de pinturas y esculturas, incluyendo materiales, dimensiones, artistas y procedencia (adquisición o donación).
* **Estructura Física y Organizacional:** Representación jerárquica de edificios, plantas, salas de exposición y departamentos.
* **Cálculo de Rankings:** Implementación de algoritmos para determinar el ranking mundial y nacional del museo basado en el volumen de visitas anual y la tasa de rotación del personal.
* **Eventos y Exposiciones:** Planificación de exposiciones especiales y eventos educativos dirigidos a instituciones escolares.
* **Control de Ingresos:** Gestión de tickets de admisión y generación de reportes financieros semestrales y anuales.

## Requerimientos Técnicos
* **Motor de Base de Datos:** Relacional (MBDR).
* **Lógica de Negocio:** Implementada mediante programas almacenados (**funciones, procedimientos y triggers**) para asegurar la integridad de los datos y la automatización de reglas de negocio.
* **Seguridad:** Implementación de roles, cuentas y privilegios de sistema sobre los objetos de la base de datos.
* **Interfaz de Usuario:** Formularios especializados para el registro de artistas, eventos, estructuras físicas y programas de mantenimiento.
* **Módulo de Reportes:** Generación de fichas técnicas de museos, empleados, estructuras físicas y organigramas.

## Estructura de Datos (Entidades Clave)
* **Museos:** Información base, ubicación geográfica y reseña histórica.
* **Obras de Arte:** Fichas técnicas específicas para pinturas y esculturas.
* **Artistas:** Datos biográficos, estilos y técnicas utilizadas.
* **Personal:** Gestión diferenciada para curadores, restauradores, personal de seguridad y administrativos.
* **Visitantes:** Registro de afluencia y recaudación por concepto de entradas.
