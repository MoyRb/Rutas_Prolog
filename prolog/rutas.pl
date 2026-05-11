% =========================================================
% Sistema Experto de Rutas Turísticas en Prolog
% Archivo: prolog/rutas.pl
% =========================================================

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

camino(A, B, D, C, T) :- conexion(A, B, D, C, T).
camino(A, B, D, C, T) :- conexion(B, A, D, C, T).

ruta(Origen, Destino, Ruta) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, 0, 0).

ruta_con_costo(Origen, Destino, Ruta, CostoTotal, DistanciaTotal) :-
    ruta_aux(Origen, Destino, [Origen], Ruta, CostoTotal, DistanciaTotal).

ruta_aux(Destino, Destino, _Visitados, [Destino], 0, 0).
ruta_aux(Actual, Destino, Visitados, [Actual | RutaRestante], CostoTotal, DistanciaTotal) :-
    camino(Actual, Siguiente, DistanciaTramo, CostoTramo, _TipoCamino),
    \+ member(Siguiente, Visitados),
    ruta_aux(Siguiente, Destino, [Siguiente | Visitados], RutaRestante, CostoRestante, DistanciaRestante),
    CostoTotal is CostoTramo + CostoRestante,
    DistanciaTotal is DistanciaTramo + DistanciaRestante.

todas_las_rutas(Origen, Destino, Rutas) :-
    findall([Ruta, Costo, Distancia], ruta_con_costo(Origen, Destino, Ruta, Costo, Distancia), Rutas).

ruta_mas_barata(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(C-[R,D], ruta_con_costo(Origen, Destino, R, C, D), [Costo-[Ruta,Distancia]|_]).

ruta_mas_cara(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(C-[R,D], ruta_con_costo(Origen, Destino, R, C, D), Lista),
    last(Lista, Costo-[Ruta,Distancia]).

ruta_mas_corta(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(D-[R,C], ruta_con_costo(Origen, Destino, R, C, D), [Distancia-[Ruta,Costo]|_]).

ruta_mas_larga(Origen, Destino, Ruta, Costo, Distancia) :-
    setof(D-[R,C], ruta_con_costo(Origen, Destino, R, C, D), Lista),
    last(Lista, Distancia-[Ruta,Costo]).

ruta_con_gasolinera(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    member(Lugar, Ruta),
    servicio(Lugar, gasolinera).

ruta_turistica(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    member(Lugar, Ruta),
    servicio(Lugar, turistico).

ruta_por_tipo(Origen, Destino, Tipo, Ruta) :-
    ruta(Origen, Destino, Ruta),
    forall((append(_, [A,B|_], Ruta)), camino(A, B, _, _, Tipo)).

ruta_mixta(Origen, Destino, Ruta) :-
    ruta(Origen, Destino, Ruta),
    append(_, [A,B|_], Ruta), camino(A, B, _, _, libre),
    append(_, [C,D|_], Ruta), camino(C, D, _, _, cuota).

ruta_en_presupuesto(Origen, Destino, Presupuesto, Ruta) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, _),
    Costo =< Presupuesto.

ruta_en_rango_costo(Origen, Destino, CostoMin, CostoMax, Ruta, Costo, Distancia) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, Distancia),
    Costo >= CostoMin,
    Costo =< CostoMax.

contar_turisticos([], 0).
contar_turisticos([Lugar|Resto], N) :-
    servicio(Lugar, turistico),
    contar_turisticos(Resto, N1),
    N is N1 + 1.
contar_turisticos([Lugar|Resto], N) :-
    \+ servicio(Lugar, turistico),
    contar_turisticos(Resto, N).

ruta_con_al_menos_n_turisticos(Origen, Destino, Minimo, Ruta, N) :-
    ruta(Origen, Destino, Ruta),
    contar_turisticos(Ruta, N),
    N >= Minimo.

ruta_con_multiples_condiciones(Origen, Destino, Presupuesto, Tipo, Servicio, LugarObligatorio, MinTuristicos, Ruta, Costo) :-
    ruta_con_costo(Origen, Destino, Ruta, Costo, _),
    Costo =< Presupuesto,
    (var(LugarObligatorio) ; LugarObligatorio == ninguno ; member(LugarObligatorio, Ruta)),
    (var(Servicio) ; Servicio == ninguno ; (member(L, Ruta), servicio(L, Servicio))),
    (var(Tipo) ; Tipo == cualquiera ; forall((append(_, [A,B|_], Ruta)), camino(A, B, _, _, Tipo))),
    contar_turisticos(Ruta, NTur),
    NTur >= MinTuristicos.
