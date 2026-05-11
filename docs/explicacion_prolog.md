# Explicación del sistema experto en Prolog

## 1. Objetivo del sistema

Este sistema experto modela **rutas turísticas** entre ciudades y puntos de interés de Michoacán usando Prolog. Su propósito es responder consultas inteligentes como:

- ¿Qué rutas existen entre dos lugares?
- ¿Cuál ruta es más barata o más corta?
- ¿Qué ruta cumple ciertos servicios o restricciones?

En pocas palabras, el proyecto combina una base de conocimiento (hechos) con reglas de inferencia para encontrar y clasificar rutas de manera automática.

---

## 2. Entidades principales

### `lugar/1`
Representa cada ciudad o punto de interés del mapa.

Ejemplo:

```prolog
lugar(morelia).
lugar(uruapan).
```

### `conexion/5`
Representa un tramo directo entre dos lugares:

```prolog
conexion(Origen, Destino, DistanciaKm, CostoPeaje, TipoCamino).
```

Ejemplo:

```prolog
conexion(morelia, uruapan, 110, 150, cuota).
```

Esto significa: de Morelia a Uruapan hay 110 km, costo 150 y es carretera de cuota.

### `servicio/2`
Indica qué servicios hay en un lugar.

```prolog
servicio(Lugar, TipoServicio).
```

Ejemplo:

```prolog
servicio(patzcuaro, turistico).
servicio(zamora, gasolinera).
```

### `camino/5`
Es una regla que interpreta las conexiones como bidireccionales (puedes ir de A a B o de B a A):

```prolog
camino(A, B, D, C, T) :- conexion(A, B, D, C, T).
camino(A, B, D, C, T) :- conexion(B, A, D, C, T).
```

Así, aunque en la base exista `conexion(morelia, uruapan, ...)`, también se puede recorrer en sentido inverso.

---

## 3. Base de conocimiento

En Prolog, los **hechos** son afirmaciones verdaderas almacenadas en la base de conocimiento. No tienen condiciones; simplemente describen el dominio.

En este proyecto, los hechos principales son:

- Lugares (`lugar/1`)
- Conexiones (`conexion/5`)
- Servicios (`servicio/2`)

Ejemplos reales del proyecto:

```prolog
lugar(lazaro_cardenas).
conexion(uruapan, lazaro_cardenas, 280, 350, cuota).
servicio(lazaro_cardenas, turistico).
```

Con esos hechos, las reglas pueden inferir rutas complejas de varios tramos.

---

## 4. Reglas de búsqueda de rutas

Las reglas centrales para buscar rutas son `ruta/3`, `ruta_con_costo/5` y el auxiliar recursivo `ruta_aux/6`.

### `ruta/3`

```prolog
ruta(Origen, Destino, Ruta).
```

Devuelve una secuencia de lugares que conecta origen con destino.

### `ruta_con_costo/5`

```prolog
ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal).
```

Además de la ruta, regresa el costo acumulado y la distancia acumulada.

### `ruta_aux/6` (auxiliar recursivo)

Esta regla realiza la exploración paso a paso.

#### a) Recursividad
`ruta_aux` se llama a sí misma para avanzar por cada tramo hasta llegar al destino.

#### b) Lista de visitados
Lleva una lista de nodos visitados para recordar por dónde ya pasó.

#### c) Control de ciclos
Antes de visitar el siguiente lugar, verifica que no esté ya en `Visitados`. Esto evita caer en bucles infinitos.

#### d) Acumulación de costo
En cada salto suma el costo del tramo actual al costo de la subruta.

#### e) Acumulación de distancia
De la misma forma, suma la distancia del tramo actual a la distancia restante.

Gracias a estas cinco ideas, el sistema encuentra rutas válidas y calcula sus métricas.

---

## 5. Clasificación de rutas

Una vez obtenidas rutas candidatas, el sistema puede clasificarlas:

- `todas_las_rutas/3`: devuelve todas las rutas posibles entre dos lugares.
- `ruta_mas_barata/5`: selecciona la de menor costo total.
- `ruta_mas_cara/5`: selecciona la de mayor costo total.
- `ruta_mas_corta/5`: selecciona la de menor distancia total.
- `ruta_mas_larga/5`: selecciona la de mayor distancia total.

Internamente, estas reglas suelen generar rutas con costo y distancia y luego aplicar comparación/ordenamiento para escoger la mejor según el criterio.

---

## 6. Filtros

El proyecto incluye filtros para consultas más específicas:

- `ruta_con_gasolinera/3`: encuentra rutas que pasan por al menos un lugar con servicio de gasolinera.
- `ruta_turistica/3`: encuentra rutas con al menos un punto turístico.
- `ruta_por_tipo/4`: filtra rutas por tipo de camino (por ejemplo `libre` o `cuota`).
- `ruta_mixta/3`: busca rutas que combinan más de un tipo de camino.
- `ruta_pasa_por/4`: exige que la ruta pase por un lugar intermedio dado.
- `ruta_con_servicio/4`: generaliza el filtro por tipo de servicio (hotel, restaurante, etc.).

Estos filtros se apoyan en la ruta base y luego verifican propiedades sobre los nodos o tramos de la ruta.

---

## 7. Restricciones

Además de filtros, hay reglas con condiciones cuantitativas:

- `ruta_en_presupuesto/4`: solo acepta rutas cuyo costo total no exceda un máximo.
- `ruta_en_rango_costo/5`: acepta rutas con costo dentro de un intervalo `[Min, Max]`.
- `ruta_con_al_menos_n_turisticos/5`: exige una cantidad mínima de lugares turísticos en la ruta.
- `ruta_con_multiples_condiciones/...`: combina varias restricciones en una sola consulta (por ejemplo presupuesto + servicios + tipo de camino).

Estas reglas permiten consultas “de planificación real”, no solo conectividad.

---

## 8. Ejemplos de consultas

Aquí tienes consultas Prolog reales que puedes ejecutar en el proyecto:

```prolog
?- ruta(uruapan, morelia, Ruta).
?- ruta_con_costo(uruapan, morelia, Ruta, Costo, Distancia).
?- ruta_mas_barata(uruapan, lazaro_cardenas, Ruta, Costo, Distancia).
?- ruta_mas_cara(morelia, uruapan, Ruta, Costo, Distancia).
?- ruta_mas_corta(morelia, lazaro_cardenas, Ruta, Costo, Distancia).
?- ruta_mas_larga(morelia, lazaro_cardenas, Ruta, Costo, Distancia).
?- todas_las_rutas(morelia, uruapan, Rutas).
?- ruta_con_gasolinera(uruapan, morelia, Ruta).
?- ruta_turistica(morelia, uruapan, Ruta).
?- ruta_por_tipo(morelia, uruapan, libre, Ruta).
?- ruta_mixta(morelia, lazaro_cardenas, Ruta).
?- ruta_pasa_por(morelia, lazaro_cardenas, uruapan, Ruta).
?- ruta_con_servicio(morelia, uruapan, hotel, Ruta).
?- ruta_en_presupuesto(morelia, lazaro_cardenas, 400, Ruta).
?- ruta_en_rango_costo(morelia, lazaro_cardenas, 200, 500, Ruta).
?- ruta_con_al_menos_n_turisticos(morelia, lazaro_cardenas, 2, Ruta, N).
?- ruta_con_multiples_condiciones(morelia, lazaro_cardenas, 500, turistico, Ruta).
```

> Nota: algunas consultas pueden devolver varias soluciones por backtracking; usa `;` para ver más rutas.

---

## 9. Cómo se conecta con Python

La integración funciona así:

1. La interfaz web envía origen, destino y filtros al backend Flask.
2. Flask transforma esos datos en una consulta Prolog (cadena de texto).
3. Mediante `pyswip`, Python ejecuta la consulta contra `rutas.pl`.
4. Prolog responde con variables instanciadas (ruta, costo, distancia, etc.).
5. Flask convierte esos resultados en **JSON** y los regresa al frontend.

Este flujo permite aprovechar la inferencia lógica de Prolog dentro de una aplicación web moderna.

---

## 10. Conclusión

Este proyecto demuestra de forma práctica:

- **Representación del conocimiento**: modelar lugares, conexiones y servicios con hechos.
- **Inferencia lógica**: deducir rutas y métricas usando reglas recursivas.
- **Consultas inteligentes**: aplicar filtros, clasificación y restricciones complejas.
- **Integración moderna**: combinar Prolog con Python/Flask y una interfaz amigable.

En conjunto, es un ejemplo claro de cómo un sistema experto puede resolver problemas de decisión sobre rutas turísticas de manera declarativa y extensible.
