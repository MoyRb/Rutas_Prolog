% =========================================================
% Sistema Experto de Rutas Turísticas en Prolog
% Archivo: prolog/rutas.pl
% ---------------------------------------------------------
% Este archivo contiene únicamente la BASE DE CONOCIMIENTO:
% - Lugares (ciudades/poblaciones)
% - Conexiones entre lugares
% - Servicios disponibles por lugar
%
% Nota: En esta primera parte NO se implementa búsqueda avanzada
% de rutas. Solo se definen hechos y reglas base, bien comentadas.
% =========================================================

% ---------------------------------------------------------
% 1) LUGARES
% ---------------------------------------------------------
% lugar/1
% Es un predicado de aridad 1 (un argumento).
% Representa los lugares disponibles dentro del sistema turístico.
% Ejemplo de consulta:
%   ?- lugar(morelia).
%   true.

lugar(morelia).
lugar(uruapan).
lugar(patzcuaro).
lugar(quiroga).
lugar(tzintzuntzan).
lugar(zamora).
lugar(jacona).
lugar(los_reyes).
lugar(apatzingan).
lugar(lazaro_cardenas).
lugar(tacambaro).
lugar(ario_de_rosales).
lugar(santa_clara_del_cobre).


% ---------------------------------------------------------
% 2) CONEXIONES
% ---------------------------------------------------------
% conexion/5
% Es un predicado de aridad 5 con la estructura:
%   conexion(Origen, Destino, Distancia, Costo, TipoCamino).
%
% Donde:
% - Origen y Destino: lugares conectados.
% - Distancia: distancia del trayecto en kilómetros.
% - Costo: costo estimado del trayecto en pesos.
% - TipoCamino: tipo de carretera (cuota o libre).
%
% Importante:
% Aquí NO duplicamos conexiones en ambos sentidos de forma manual.
% Por ejemplo, si existe conexion(morelia, uruapan, ...), no es
% necesario agregar también conexion(uruapan, morelia, ...).
% Esa bidireccionalidad se resolverá con camino/5.

conexion(morelia, patzcuaro, 60, 80, libre).
conexion(morelia, uruapan, 110, 150, cuota).
conexion(morelia, quiroga, 40, 0, libre).
conexion(morelia, tacambaro, 55, 70, libre).
conexion(morelia, ario_de_rosales, 85, 100, libre).

conexion(patzcuaro, tzintzuntzan, 18, 0, libre).
conexion(patzcuaro, quiroga, 25, 0, libre).
conexion(patzcuaro, santa_clara_del_cobre, 22, 30, libre).
conexion(patzcuaro, uruapan, 55, 75, libre).

conexion(quiroga, tzintzuntzan, 15, 0, libre).

conexion(uruapan, los_reyes, 85, 120, cuota).
conexion(uruapan, apatzingan, 110, 130, libre).
conexion(uruapan, lazaro_cardenas, 280, 350, cuota).
conexion(uruapan, zamora, 145, 180, libre).

conexion(zamora, jacona, 8, 0, libre).
conexion(zamora, los_reyes, 65, 90, libre).

conexion(tacambaro, ario_de_rosales, 35, 0, libre).
conexion(ario_de_rosales, apatzingan, 95, 120, libre).

conexion(apatzingan, lazaro_cardenas, 210, 260, libre).


% ---------------------------------------------------------
% 3) SERVICIOS
% ---------------------------------------------------------
% servicio/2
% Es un predicado de aridad 2 con la estructura:
%   servicio(Lugar, TipoServicio).
%
% Representa qué servicios hay en cada lugar.
% Tipos de servicio utilizados en este sistema:
% - gasolinera
% - paradero
% - turistico
% - restaurante
% - hotel
%
% Un mismo lugar puede tener MÁS DE un servicio, por eso se pueden
% declarar varios hechos servicio/2 para el mismo lugar.

servicio(morelia, gasolinera).
servicio(morelia, turistico).
servicio(morelia, restaurante).
servicio(morelia, hotel).

servicio(uruapan, gasolinera).
servicio(uruapan, restaurante).
servicio(uruapan, hotel).
servicio(uruapan, turistico).

servicio(patzcuaro, turistico).
servicio(patzcuaro, restaurante).
servicio(patzcuaro, hotel).
servicio(patzcuaro, paradero).

servicio(quiroga, turistico).
servicio(quiroga, restaurante).
servicio(quiroga, paradero).

servicio(tzintzuntzan, turistico).
servicio(tzintzuntzan, paradero).

servicio(zamora, gasolinera).
servicio(zamora, restaurante).
servicio(zamora, hotel).

servicio(jacona, gasolinera).
servicio(jacona, paradero).

servicio(los_reyes, gasolinera).
servicio(los_reyes, restaurante).

servicio(apatzingan, gasolinera).
servicio(apatzingan, hotel).
servicio(apatzingan, restaurante).

servicio(lazaro_cardenas, gasolinera).
servicio(lazaro_cardenas, hotel).
servicio(lazaro_cardenas, turistico).

servicio(tacambaro, paradero).
servicio(tacambaro, gasolinera).

servicio(ario_de_rosales, paradero).
servicio(ario_de_rosales, gasolinera).

servicio(santa_clara_del_cobre, turistico).
servicio(santa_clara_del_cobre, restaurante).


% ---------------------------------------------------------
% 4) REGLA PARA HACER CONEXIONES BIDIRECCIONALES
% ---------------------------------------------------------
% camino/5
% Es una regla auxiliar que permite consultar caminos en ambos sentidos
% usando una sola definición de conexion/5 por trayecto.
%
% ¿Por qué usar camino/5?
% - Evita duplicar datos en la base de conocimiento.
% - Reduce errores de mantenimiento (si cambia una distancia/costo,
%   se actualiza en un solo hecho).
% - Permite consultar de A a B y también de B a A con la misma facilidad.
%
% Ejemplo:
% Si existe conexion(morelia, uruapan, 110, 150, cuota), entonces:
%   ?- camino(morelia, uruapan, D, C, T).
% y también:
%   ?- camino(uruapan, morelia, D, C, T).
% devolverán el mismo trayecto.

camino(A, B, D, C, T) :- conexion(A, B, D, C, T).
camino(A, B, D, C, T) :- conexion(B, A, D, C, T).


% ---------------------------------------------------------
% 5) BÚSQUEDA DE RUTAS (SIN REPETIR LUGARES)
% ---------------------------------------------------------
% En esta sección se implementa la lógica de búsqueda de rutas:
% - ruta/3: obtiene una ruta posible entre Origen y Destino.
% - ruta_con_costo/5: obtiene ruta, costo total y distancia total.
%
% Requisitos cubiertos:
% - Recursividad: la búsqueda avanza de nodo en nodo con ruta_aux/6.
% - Listas: se maneja la ruta como lista y los visitados como lista.
% - Acumuladores: se acumulan costo y distancia de forma incremental.
% - Control de ciclos: no se permiten nodos ya visitados.

% ruta/3
% ruta(Origen, Destino, Ruta).
%
% Encuentra una ruta posible entre Origen y Destino.
% Ruta es una lista ordenada desde Origen hasta Destino.
%
% Ejemplo de salida:
%   Ruta = [uruapan, patzcuaro, morelia]
%
% Nota:
% Internamente usamos ruta_aux/6 para reutilizar la misma lógica
% recursiva que también calcula costo y distancia.
ruta(Origen, Destino, Ruta) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, 0, 0).


% ruta_con_costo/5
% ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal).
%
% Encuentra una ruta posible entre Origen y Destino y además calcula:
% - CostoTotal: suma de costos de todos los tramos de la ruta.
% - DistanciaTotal: suma de distancias de todos los tramos.
ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, CostoTotal, DistanciaTotal).


% ruta_aux/6
% ruta_aux(Actual, Destino, Visitados, Ruta, CostoTotal, DistanciaTotal).
%
% Predicado auxiliar recursivo para construir rutas sin ciclos.
%
% Parámetros:
% - Actual: lugar donde estamos actualmente en la exploración.
% - Destino: lugar objetivo al que queremos llegar.
% - Visitados: lista de lugares ya recorridos en la rama actual.
%              Sirve para evitar ciclos (no repetir lugares).
% - Ruta: ruta final encontrada, desde Actual hasta Destino.
% - CostoTotal: costo acumulado de la Ruta resultante.
% - DistanciaTotal: distancia acumulada de la Ruta resultante.
%
% Caso base:
% Si Actual ya es Destino, la ruta es una lista con ese único lugar,
% y tanto costo como distancia son 0 (no hay más tramos por recorrer).
ruta_aux(Destino, Destino, _Visitados, [Destino], 0, 0).

% Caso recursivo:
% 1) Elegimos un siguiente nodo (Siguiente) conectado a Actual usando
%    camino/5 (bidireccional, basado en conexion/5).
% 2) Verificamos que Siguiente no haya sido visitado para evitar ciclos.
% 3) Continuamos la búsqueda recursiva desde Siguiente hasta Destino.
% 4) Construimos la Ruta anteponiendo Actual a la subruta encontrada.
% 5) Acumulamos costo y distancia sumando el tramo Actual->Siguiente.
ruta_aux(Actual, Destino, Visitados, [Actual | RutaRestante], CostoTotal, DistanciaTotal) :-
    camino(Actual, Siguiente, DistanciaTramo, CostoTramo, _TipoCamino),
    \+ member(Siguiente, Visitados),
    ruta_aux(
        Siguiente,
        Destino,
        [Siguiente | Visitados],
        RutaRestante,
        CostoRestante,
        DistanciaRestante
    ),
    CostoTotal is CostoTramo + CostoRestante,
    DistanciaTotal is DistanciaTramo + DistanciaRestante.


% ---------------------------------------------------------
% 6) EJEMPLOS DE CONSULTAS
% ---------------------------------------------------------
% ?- ruta(uruapan, morelia, Ruta).
% ?- ruta_con_costo(uruapan, morelia, Ruta, Costo, Distancia).


% ---------------------------------------------------------
% 7) CLASIFICACIÓN DE RUTAS
% ---------------------------------------------------------
% En esta sección reunimos y clasificamos todas las rutas posibles entre
% dos lugares, usando el predicado findall/3.

% todas_las_rutas/3
% todas_las_rutas(Origen, Destino, Rutas).
%
% Devuelve en Rutas una lista con TODAS las rutas posibles entre Origen
% y Destino. Cada elemento tiene la forma:
%   ruta_info(Ruta, CostoTotal, DistanciaTotal)
%
% ¿Qué hace findall/3?
% - Sintaxis: findall(Plantilla, Objetivo, Lista).
% - Ejecuta Objetivo todas las veces que pueda.
% - En cada solución, guarda en Lista una copia de Plantilla.
% - Si no hay soluciones, devuelve Lista = [] (lista vacía).
todas_las_rutas(Origen, Destino, Rutas) :-
    findall(
        ruta_info(Ruta, CostoTotal, DistanciaTotal),
        ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal),
        Rutas
    ).


% ruta_mas_barata/5
% Selecciona la ruta con menor costo total.
ruta_mas_barata(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    todas_las_rutas(Origen, Destino, Rutas),
    findall(
        Costo-ruta_info(R, Costo, Distancia),
        member(ruta_info(R, Costo, Distancia), Rutas),
        ParesCostoRuta
    ),
    keysort(ParesCostoRuta, [CostoTotal-ruta_info(Ruta, CostoTotal, DistanciaTotal) | _]).


% ruta_mas_cara/5
% Selecciona la ruta con mayor costo total.
ruta_mas_cara(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    todas_las_rutas(Origen, Destino, Rutas),
    findall(
        Costo-ruta_info(R, Costo, Distancia),
        member(ruta_info(R, Costo, Distancia), Rutas),
        ParesCostoRuta
    ),
    keysort(ParesCostoRuta, Ordenadas),
    last(Ordenadas, CostoTotal-ruta_info(Ruta, CostoTotal, DistanciaTotal)).


% ruta_mas_corta/5
% Selecciona la ruta con menor distancia total.
ruta_mas_corta(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    todas_las_rutas(Origen, Destino, Rutas),
    findall(
        Distancia-ruta_info(R, Costo, Distancia),
        member(ruta_info(R, Costo, Distancia), Rutas),
        ParesDistanciaRuta
    ),
    keysort(ParesDistanciaRuta, [DistanciaTotal-ruta_info(Ruta, CostoTotal, DistanciaTotal) | _]).


% ruta_mas_larga/5
% Selecciona la ruta con mayor distancia total.
ruta_mas_larga(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    todas_las_rutas(Origen, Destino, Rutas),
    findall(
        Distancia-ruta_info(R, Costo, Distancia),
        member(ruta_info(R, Costo, Distancia), Rutas),
        ParesDistanciaRuta
    ),
    keysort(ParesDistanciaRuta, Ordenadas),
    last(Ordenadas, DistanciaTotal-ruta_info(Ruta, CostoTotal, DistanciaTotal)).


% ---------------------------------------------------------
% 8) EJEMPLOS DE CONSULTAS (CLASIFICACIÓN)
% ---------------------------------------------------------
% ?- todas_las_rutas(uruapan, morelia, Rutas).
% ?- ruta_mas_barata(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_mas_cara(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_mas_corta(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_mas_larga(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_con_costo(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_con_costo(uruapan, lazaro_cardenas, Ruta, Costo, Distancia).

% ---------------------------------------------------------
% 7) FILTROS AVANZADOS DE RUTAS
% ---------------------------------------------------------
% En esta sección se agregan predicados para filtrar rutas según:
% - Lugar intermedio obligatorio.
% - Servicios presentes en la ruta.
% - Tipo de camino (cuota/libre).
% - Combinación de tipos de camino (ruta mixta).

% ruta_pasa_por/4
% ruta_pasa_por(Origen, Destino, LugarIntermedio, Ruta).
%
% Encuentra rutas entre Origen y Destino que incluyan LugarIntermedio.
% Se apoya en ruta/3 y verifica membresía en la lista resultante.
ruta_pasa_por(Origen, Destino, LugarIntermedio, Ruta) :-
    ruta(Origen, Destino, Ruta),
    member(LugarIntermedio, Ruta).


% ruta_con_servicio/4
% ruta_con_servicio(Origen, Destino, TipoServicio, Ruta).
%
% Encuentra rutas entre Origen y Destino donde al menos un lugar de la
% ruta tenga el servicio indicado (gasolinera, turistico, hotel, etc.).
ruta_con_servicio(Origen, Destino, TipoServicio, Ruta) :-
    ruta(Origen, Destino, Ruta),
    ruta_tiene_servicio(Ruta, TipoServicio).

% ruta_tiene_servicio/2
% ruta_tiene_servicio(Ruta, TipoServicio).
%
% Predicado auxiliar recursivo para verificar si existe al menos un lugar
% dentro de Ruta que tenga TipoServicio.
% - Caso base implícito: la lista vacía falla (no hay servicio).
% - Caso éxito inmediato: la cabeza tiene el servicio.
% - Caso recursivo: buscar en el resto de la ruta.
ruta_tiene_servicio([Lugar | _], TipoServicio) :-
    servicio(Lugar, TipoServicio).
ruta_tiene_servicio([_ | Resto], TipoServicio) :-
    ruta_tiene_servicio(Resto, TipoServicio).


% ruta_con_gasolinera/3
% ruta_con_gasolinera(Origen, Destino, Ruta).
%
% Especialización de ruta_con_servicio/4 para servicio gasolinera.
ruta_con_gasolinera(Origen, Destino, Ruta) :-
    ruta_con_servicio(Origen, Destino, gasolinera, Ruta).


% ruta_turistica/3
% ruta_turistica(Origen, Destino, Ruta).
%
% Encuentra rutas que incluyan al menos un lugar turístico.
ruta_turistica(Origen, Destino, Ruta) :-
    ruta_con_servicio(Origen, Destino, turistico, Ruta).


% tipos_de_ruta/2
% tipos_de_ruta(Ruta, Tipos).
%
% Dada una ruta (lista de lugares), obtiene la lista de tipos de camino
% usados entre cada par consecutivo de lugares.
%
% Ejemplo:
% ?- tipos_de_ruta([uruapan, patzcuaro, morelia], Tipos).
% Tipos = [libre, libre].
%
% Casos base:
% - Ruta vacía o con un solo nodo -> no hay tramos, por lo tanto [].
tipos_de_ruta([], []).
tipos_de_ruta([_], []).

% Caso recursivo:
% 1) Tomar dos lugares consecutivos A y B.
% 2) Obtener el tipo del tramo con camino/5.
% 3) Continuar recursivamente desde B.
tipos_de_ruta([A, B | Resto], [Tipo | TiposResto]) :-
    camino(A, B, _Distancia, _Costo, Tipo),
    tipos_de_ruta([B | Resto], TiposResto).


% ruta_por_tipo/4
% ruta_por_tipo(Origen, Destino, TipoCamino, Ruta).
%
% Encuentra rutas entre Origen y Destino donde TODOS los tramos sean del
% tipo indicado (cuota o libre).
ruta_por_tipo(Origen, Destino, TipoCamino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    tipos_de_ruta(Ruta, Tipos),
    todos_del_tipo(Tipos, TipoCamino).

% todos_del_tipo/2
% todos_del_tipo(Tipos, Tipo).
%
% Predicado auxiliar recursivo:
% verifica que todos los elementos de la lista Tipos sean Tipo.
% - La lista vacía cumple por definición.
todos_del_tipo([], _Tipo).
todos_del_tipo([Tipo | Resto], Tipo) :-
    todos_del_tipo(Resto, Tipo).


% ruta_mixta/3
% ruta_mixta(Origen, Destino, Ruta).
%
% Encuentra rutas que combinen al menos un tramo de cuota y al menos uno
% de libre.
ruta_mixta(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    tipos_de_ruta(Ruta, Tipos),
    member(cuota, Tipos),
    member(libre, Tipos).


% ---------------------------------------------------------
% 8) EJEMPLOS DE CONSULTAS (FILTROS AVANZADOS)
% ---------------------------------------------------------
% ?- ruta_pasa_por(uruapan, morelia, patzcuaro, Ruta).
% ?- ruta_con_servicio(uruapan, morelia, hotel, Ruta).
% ?- ruta_con_gasolinera(tacambaro, lazaro_cardenas, Ruta).
% ?- ruta_turistica(zamora, morelia, Ruta).
% ?- tipos_de_ruta([uruapan, patzcuaro, morelia], Tipos).
% ?- ruta_por_tipo(morelia, quiroga, libre, Ruta).
% ?- ruta_mixta(morelia, lazaro_cardenas, Ruta).

% ---------------------------------------------------------
% 9) RESTRICCIONES POR PRESUPUESTO Y CONSULTAS AVANZADAS
% ---------------------------------------------------------
% En esta sección agregamos predicados para filtrar rutas por:
% - Presupuesto máximo.
% - Rango de costo permitido.
% - Conteo de servicios dentro de una ruta.
% - Cantidad mínima de lugares turísticos.
% - Combinación de múltiples condiciones en una sola consulta.

% ruta_en_presupuesto/4
% ruta_en_presupuesto(Origen, Destino, PresupuestoMaximo, Ruta).
%
% Encuentra rutas entre Origen y Destino cuyo costo total sea
% menor o igual al presupuesto indicado.
ruta_en_presupuesto(Origen, Destino, PresupuestoMaximo, Ruta) :-
    ruta_con_costo(Origen, Destino, Ruta, CostoTotal, _DistanciaTotal),
    CostoTotal =< PresupuestoMaximo.


% ruta_en_rango_costo/7
% ruta_en_rango_costo(Origen, Destino, CostoMinimo, CostoMaximo,
%                     Ruta, CostoTotal, DistanciaTotal).
%
% Encuentra rutas entre Origen y Destino cuyo costo total esté dentro
% del rango [CostoMinimo, CostoMaximo] (incluyendo ambos extremos).
ruta_en_rango_costo(
    Origen,
    Destino,
    CostoMinimo,
    CostoMaximo,
    Ruta,
    CostoTotal,
    DistanciaTotal
) :-
    ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal),
    CostoTotal >= CostoMinimo,
    CostoTotal =< CostoMaximo.


% contar_servicio_en_ruta/3
% contar_servicio_en_ruta(Ruta, TipoServicio, Cantidad).
%
% Cuenta cuántos lugares dentro de Ruta tienen TipoServicio.
% Nota:
% - Se cuenta por lugar presente en la lista Ruta.
% - Como las rutas de este sistema no repiten lugares, cada lugar se
%   considera a lo sumo una vez por ruta.
contar_servicio_en_ruta([], _TipoServicio, 0).
contar_servicio_en_ruta([Lugar | Resto], TipoServicio, Cantidad) :-
    contar_servicio_en_ruta(Resto, TipoServicio, CantidadResto),
    (   servicio(Lugar, TipoServicio)
    ->  Cantidad is CantidadResto + 1
    ;   Cantidad is CantidadResto
    ).


% ruta_con_al_menos_n_turisticos/5
% ruta_con_al_menos_n_turisticos(Origen, Destino, N,
%                                Ruta, CantidadTuristicos).
%
% Encuentra rutas entre Origen y Destino que tengan al menos N lugares
% con servicio turistico. También devuelve la cantidad encontrada.
ruta_con_al_menos_n_turisticos(Origen, Destino, N, Ruta, CantidadTuristicos) :-
    ruta(Origen, Destino, Ruta),
    contar_servicio_en_ruta(Ruta, turistico, CantidadTuristicos),
    CantidadTuristicos >= N.


% ruta_con_multiples_condiciones/9
% ruta_con_multiples_condiciones(
%     Origen,
%     Destino,
%     PresupuestoMaximo,
%     TipoCamino,
%     ServicioRequerido,
%     LugarObligatorio,
%     Ruta,
%     CostoTotal,
%     DistanciaTotal
% ).
%
% Encuentra rutas que cumplan simultáneamente:
% - Costo total <= PresupuestoMaximo.
% - Todos los tramos del tipo TipoCamino.
% - Incluye al menos un lugar con ServicioRequerido.
% - Pasa por LugarObligatorio.
%
% Este predicado reutiliza filtros ya creados para mantener el código
% modular y fácil de mantener.
ruta_con_multiples_condiciones(
    Origen,
    Destino,
    PresupuestoMaximo,
    TipoCamino,
    ServicioRequerido,
    LugarObligatorio,
    Ruta,
    CostoTotal,
    DistanciaTotal
) :-
    ruta_en_presupuesto(Origen, Destino, PresupuestoMaximo, Ruta),
    ruta_por_tipo(Origen, Destino, TipoCamino, Ruta),
    ruta_pasa_por(Origen, Destino, LugarObligatorio, Ruta),
    ruta_tiene_servicio(Ruta, ServicioRequerido),
    ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal).


% ---------------------------------------------------------
% 10) EJEMPLOS DE CONSULTAS (PRESUPUESTO Y AVANZADAS)
% ---------------------------------------------------------
% ?- ruta_en_presupuesto(uruapan, morelia, 90, Ruta).
% ?- ruta_en_rango_costo(uruapan, morelia, 70, 200, Ruta, Costo, Distancia).
% ?- contar_servicio_en_ruta([uruapan, patzcuaro, morelia], turistico, Cantidad).
% ?- ruta_con_al_menos_n_turisticos(uruapan, morelia, 2, Ruta, CantidadTuristicos).
% ?- ruta_con_multiples_condiciones(
%        morelia,
%        tzintzuntzan,
%        120,
%        libre,
%        turistico,
%        patzcuaro,
%        Ruta,
%        Costo,
%        Distancia
%    ).
