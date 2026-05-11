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
