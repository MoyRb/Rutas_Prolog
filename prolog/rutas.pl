% =========================================================
% Sistema Experto de Rutas Turísticas en Prolog
% Archivo: prolog/rutas.pl
% =========================================================
/*
   Este archivo implementa un Sistema Experto de Rutas Turísticas.
   En este contexto, Prolog funciona como motor lógico: aquí representamos
   conocimiento (hechos sobre lugares, conexiones y servicios) y luego
   aplicamos reglas para inferir rutas posibles y filtrarlas según criterios.
*/

% -------------------------
% BASE DE CONOCIMIENTO: LUGARES
% -------------------------
% lugar(Nombre) representa un nodo del mapa.
% Cada lugar corresponde a una ciudad o punto de interés turístico.
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

% -------------------------
% BASE DE CONOCIMIENTO: CONEXIONES
% -------------------------
% conexion(Origen, Destino, Distancia, Costo, TipoCamino) representa
% un tramo directo entre dos lugares.
% - Distancia se mide en kilómetros.
% - Costo se expresa en pesos.
% - TipoCamino clasifica el tramo (por ejemplo: cuota o libre).
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

% -------------------------
% BASE DE CONOCIMIENTO: SERVICIOS
% -------------------------
% servicio(Lugar, TipoServicio) indica qué servicios hay en cada lugar.
% Un mismo lugar puede tener varios servicios distintos.
% Ejemplos de TipoServicio usados aquí: gasolinera, turistico, hotel,
% restaurante y paradero.
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

% camino/5 permite tratar cada conexión como bidireccional.
% Gracias a esta regla no es necesario duplicar hechos conexion/5
% en ambos sentidos (A->B y B->A), porque camino/5 los interpreta.
camino(A, B, D, C, T) :- conexion(A, B, D, C, T).
camino(A, B, D, C, T) :- conexion(B, A, D, C, T).

% ruta/3 busca una ruta posible entre un origen y un destino.
% El resultado se devuelve como una lista ordenada de lugares.
ruta(Origen, Destino, Ruta) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, 0, 0).

% ruta_con_costo/5, además de encontrar una ruta, calcula
% su costo total y su distancia total acumulada.
ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, CostoTotal, DistanciaTotal).

/*
   Predicado auxiliar de búsqueda de rutas (ruta_aux/6):
   - Actual: lugar en el que está la exploración en este paso.
   - Destino: lugar final que se desea alcanzar.
   - Visitados: lista de lugares ya recorridos para evitar ciclos.
   - Ruta: lista resultante desde Actual hasta Destino.
   - CostoTotal: suma de costos de todos los tramos elegidos.
   - DistanciaTotal: suma de distancias de todos los tramos elegidos.

   Cómo evita repetir lugares:
   - Antes de avanzar a Siguiente, se verifica que no pertenezca a Visitados
     con "\+ member(Siguiente, Visitados)".

   Cómo funciona la recursividad:
   - Caso base: cuando Actual y Destino son el mismo lugar, la ruta es
     [Destino] y no falta costo ni distancia por agregar (0,0).
   - Paso recursivo: se toma un tramo Actual->Siguiente, se resuelve
     recursivamente el resto de la ruta desde Siguiente hasta Destino,
     y finalmente se acumulan costo y distancia de este tramo.
*/
ruta_aux(Destino, Destino, _Visitados, [Destino], 0, 0).
ruta_aux(Actual, Destino, Visitados, [Actual | RutaRestante], CostoTotal, DistanciaTotal) :-
    camino(Actual, Siguiente, DistanciaTramo, CostoTramo, _TipoCamino),
    \+ member(Siguiente, Visitados),
    ruta_aux(Siguiente, Destino, [Siguiente | Visitados], RutaRestante, CostoRestante, DistanciaRestante),
    CostoTotal is CostoTramo + CostoRestante,
    DistanciaTotal is DistanciaTramo + DistanciaRestante.

% todas_las_rutas/3 usa findall/3 para reunir todas las rutas posibles
% entre Origen y Destino. Cada solución se guarda como
% [Ruta, Costo, Distancia] (estructura informativa de la ruta encontrada).
todas_las_rutas(Origen, Destino, Rutas) :-
    findall([Ruta, Costo, Distancia], ruta_con_costo(Origen, Destino, Ruta, Costo, Distancia), Rutas).

% ruta_mas_barata/5 selecciona la ruta con menor costo total.
ruta_mas_barata(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(C-[R,D], ruta_con_costo(Origen, Destino, R, C, D), [Costo-[Ruta,Distancia]|_]).

% ruta_mas_cara/5 selecciona la ruta con mayor costo total.
ruta_mas_cara(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(C-[R,D], ruta_con_costo(Origen, Destino, R, C, D), Lista),
    last(Lista, Costo-[Ruta,Distancia]).

% ruta_mas_corta/5 selecciona la ruta con menor distancia total.
ruta_mas_corta(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(D-[R,C], ruta_con_costo(Origen, Destino, R, C, D), [Distancia-[Ruta,Costo]|_]).

% ruta_mas_larga/5 selecciona la ruta con mayor distancia total.
ruta_mas_larga(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(D-[R,C], ruta_con_costo(Origen, Destino, R, C, D), Lista),
    last(Lista, Distancia-[Ruta,Costo]).

% ruta_con_gasolinera/3 es una especialización de la idea
% "ruta_con_servicio": aquí el servicio obligatorio es gasolinera.
ruta_con_gasolinera(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    member(Lugar, Ruta),
    servicio(Lugar, gasolinera).

% ruta_turistica/3 filtra rutas que tengan al menos un punto turístico.
ruta_turistica(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    member(Lugar, Ruta),
    servicio(Lugar, turistico).

% ruta_por_tipo/4 filtra rutas cuyos tramos sean todos del tipo indicado
% (por ejemplo, solo cuota o solo libre).
ruta_por_tipo(Origen, Destino, Tipo, Ruta) :-
    ruta(Origen, Destino, Ruta),
    forall((append(_, [A,B|_], Ruta)), camino(A, B, _, _, Tipo)).

% ruta_mixta/3 busca rutas que combinen al menos un tramo libre y
% al menos un tramo de cuota.
ruta_mixta(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    append(_, [A,B|_], Ruta), camino(A, B, _, _, libre),
    append(_, [C,D|_], Ruta), camino(C, D, _, _, cuota).

% ruta_en_presupuesto/4 filtra rutas cuyo costo total
% no supera el presupuesto máximo establecido.
ruta_en_presupuesto(Origen, Destino, Presupuesto, Ruta) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, _),
    Costo =< Presupuesto.

% ruta_en_rango_costo/7 filtra rutas con costo total dentro
% de un intervalo [CostoMin, CostoMax].
ruta_en_rango_costo(Origen, Destino, CostoMin, CostoMax, Ruta, Costo, Distancia) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, Distancia),
    Costo >= CostoMin,
    Costo =< CostoMax.

% contar_turisticos/2 cuenta cuántos lugares turísticos hay en una ruta.
% Este conteo se usa para imponer mínimos de puntos turísticos.
contar_turisticos([], 0).
contar_turisticos([Lugar|Resto], N) :-
    servicio(Lugar, turistico),
    contar_turisticos(Resto, N1),
    N is N1 + 1.
contar_turisticos([Lugar|Resto], N) :-
    \+ servicio(Lugar, turistico),
    contar_turisticos(Resto, N).

% ruta_con_al_menos_n_turisticos/5 busca rutas que incluyan
% al menos N lugares con servicio turístico.
ruta_con_al_menos_n_turisticos(Origen, Destino, Minimo, Ruta, N) :-
    ruta(Origen, Destino, Ruta),
    contar_turisticos(Ruta, N),
    N >= Minimo.

/*
   ruta_con_multiples_condiciones/10 combina varias restricciones:
   - presupuesto máximo,
   - tipo de camino,
   - servicio requerido,
   - lugar obligatorio,
   y además un mínimo de puntos turísticos.
*/
ruta_con_multiples_condiciones(Origen, Destino, Presupuesto, Tipo, Servicio, LugarObligatorio, MinTuristicos, Ruta, Costo) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, _),
    Costo =< Presupuesto,
    (var(LugarObligatorio) ; LugarObligatorio == ninguno ; member(LugarObligatorio, Ruta)),
    (var(Servicio) ; Servicio == ninguno ; (member(L, Ruta), servicio(L, Servicio))),
    (var(Tipo) ; Tipo == cualquiera ; forall((append(_, [A,B|_], Ruta)), camino(A, B, _, _, Tipo))),
    contar_turisticos(Ruta, NTur),
    NTur >= MinTuristicos.

% =========================
% EJEMPLOS DE CONSULTAS
% =========================
% ?- ruta(uruapan, morelia, Ruta).
% ?- ruta_con_costo(uruapan, morelia, Ruta, Costo, Distancia).
% ?- todas_las_rutas(uruapan, morelia, Rutas).
% ?- ruta_mas_barata(uruapan, lazaro_cardenas, Ruta, Costo, Distancia).
% ?- ruta_mas_cara(uruapan, lazaro_cardenas, Ruta, Costo, Distancia).
% ?- ruta_mas_corta(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_mas_larga(uruapan, morelia, Ruta, Costo, Distancia).
% ?- ruta_con_gasolinera(uruapan, morelia, Ruta).
% ?- ruta_turistica(morelia, uruapan, Ruta).
% ?- ruta_por_tipo(uruapan, morelia, cuota, Ruta).
% ?- ruta_mixta(uruapan, lazaro_cardenas, Ruta).
% ?- ruta_en_presupuesto(uruapan, morelia, 300, Ruta).
% ?- ruta_en_rango_costo(uruapan, lazaro_cardenas, 100, 500, Ruta, Costo, Distancia).
% ?- ruta_con_al_menos_n_turisticos(uruapan, morelia, 2, Ruta, CantidadTuristicos).
% ?- ruta_con_multiples_condiciones(uruapan, morelia, 500, cuota, gasolinera, patzcuaro, 1, Ruta, Costo).
