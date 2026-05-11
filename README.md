# Sistema Experto de Rutas Turísticas en Prolog

## 1) Descripción breve

Este proyecto implementa un **sistema experto** para recomendar y analizar rutas entre ciudades, combinando lógica declarativa en Prolog con una interfaz web amigable construida en Flask. Permite consultar rutas por diferentes criterios (costo, distancia, tipo de camino, turismo, presupuesto y combinaciones de condiciones) para apoyar la toma de decisiones de viaje.

---

## 2) Tecnologías usadas

- **Prolog**
- **SWI-Prolog**
- **Python**
- **Flask**
- **PySwip**
- **HTML**
- **CSS**
- **JavaScript**

---

## 3) Estructura del proyecto

```text
Rutas_Prolog/
├── backend/
│   └── app.py                  # Servidor Flask y conexión con Prolog
├── prolog/
│   └── rutas.pl                # Base de conocimiento y reglas del sistema experto
├── templates/
│   └── index.html              # Vista principal
├── static/
│   ├── css/
│   │   └── styles.css          # Estilos de la interfaz
│   └── js/
│       └── app.js              # Lógica de interacción en frontend
├── docs/
│   └── explicacion_prolog.md   # Documentación complementaria de reglas
├── requirements.txt            # Dependencias de Python
└── README.md                   # Documentación principal del proyecto
```

---

## 4) Requisitos previos

Antes de ejecutar el proyecto, asegúrate de tener instalado:

- **Python 3**
- **SWI-Prolog**

Después, instala las dependencias de Python:

```bash
pip install -r requirements.txt
```

---

## 5) Cómo ejecutar

Desde la raíz del proyecto, ejecuta:

```bash
python backend/app.py
```

Luego abre en tu navegador:

```text
http://127.0.0.1:5000
```

---

## 6) Ejemplos de consultas directas en Prolog

Si deseas probar la base de conocimiento sin la interfaz web:

1. Abre SWI-Prolog:

   ```bash
   swipl
   ```

2. Carga el archivo de rutas:

   ```prolog
   consult('prolog/rutas.pl').
   ```

3. Ejecuta consultas de prueba (ejemplos genéricos):

   ```prolog
   % Consultar una ruta entre dos ciudades
   ruta(origen, destino, Ruta).

   % Consultar rutas con costo total
   costo_total(Ruta, Costo).

   % Consultar rutas con distancia total
   distancia_total(Ruta, Distancia).
   ```

> Nota: Reemplaza `origen`, `destino` y demás parámetros por nombres válidos según la base de conocimiento definida en `prolog/rutas.pl`.

---

## 7) Funcionalidades

El sistema permite realizar consultas como:

- búsqueda de rutas
- costo total
- distancia total
- rutas más baratas
- rutas más caras
- rutas más cortas
- rutas más largas
- rutas con gasolinera
- rutas turísticas
- rutas por tipo de camino
- rutas mixtas
- rutas en presupuesto
- rutas con múltiples condiciones

---

## 8) Capturas sugeridas para la entrega

Para documentar tu tarea, se recomienda incluir capturas de:

1. **pantalla principal**
2. **búsqueda de ruta**
3. **filtro por presupuesto**
4. **filtro turístico**
5. **visualización gráfica**

---

## 9) Aporte del sistema experto

Este sistema experto aporta valor al automatizar el análisis de rutas con reglas lógicas claras y trazables. En lugar de evaluar manualmente múltiples alternativas, el usuario obtiene recomendaciones según criterios concretos (económicos, geográficos y turísticos), lo que mejora la eficiencia de decisión y demuestra cómo la inteligencia basada en reglas puede aplicarse en problemas reales de planificación.

---

## 10) Recomendaciones finales

- Mantén actualizada la base de conocimiento (`prolog/rutas.pl`) para mejorar la calidad de las recomendaciones.
- Verifica que SWI-Prolog esté correctamente instalado y accesible desde terminal.
- Si presentas el proyecto, combina pruebas desde la web y consultas directas en Prolog para evidenciar el funcionamiento completo.

---

## 11) Consultas recomendadas para la demostración

Estas consultas están pensadas para mostrar diferentes capacidades del sistema frente al profesor:

```prolog
% 1) Ruta básica
?- ruta(morelia, uruapan, Ruta).

% 2) Ruta con costo y distancia
?- ruta_con_costo(morelia, lazaro_cardenas, Ruta, Costo, Distancia).

% 3) Comparación por optimización
?- ruta_mas_barata(morelia, lazaro_cardenas, Ruta, Costo, Distancia).
?- ruta_mas_corta(morelia, lazaro_cardenas, Ruta, Costo, Distancia).

% 4) Filtros por características
?- ruta_con_gasolinera(morelia, lazaro_cardenas, Ruta).
?- ruta_turistica(morelia, lazaro_cardenas, Ruta).
?- ruta_por_tipo(morelia, uruapan, libre, Ruta).
?- ruta_mixta(morelia, lazaro_cardenas, Ruta).

% 5) Restricciones de negocio
?- ruta_en_presupuesto(morelia, lazaro_cardenas, 500, Ruta).
?- ruta_en_rango_costo(morelia, lazaro_cardenas, 200, 700, Ruta, Costo, Distancia).
?- ruta_con_al_menos_n_turisticos(morelia, lazaro_cardenas, 2, Ruta, N).

% 6) Consulta avanzada combinada
?- ruta_con_multiples_condiciones(morelia, lazaro_cardenas, 900, libre, turistico, uruapan, 2, Ruta, Costo).
```

Sugerencia para la presentación: ejecuta cada bloque y explica cómo cambia el resultado cuando agregas más restricciones.
