"""Backend Flask para consultar rutas turísticas en Prolog (rutas.pl)."""

from pathlib import Path
from typing import Any, Dict, List

from flask import Flask, jsonify, request, send_from_directory
from pyswip import Prolog

# Inicializar Flask indicando carpeta de templates y static en la raíz del proyecto.
BASE_DIR = Path(__file__).resolve().parents[1]
app = Flask(
    __name__,
    template_folder=str(BASE_DIR / "templates"),
    static_folder=str(BASE_DIR / "static"),
)

# Instancia global de Prolog y carga del archivo de conocimiento.
prolog = Prolog()
PROLOG_FILE = BASE_DIR / "prolog" / "rutas.pl"
prolog.consult(str(PROLOG_FILE))

# Filtros permitidos por el backend.
FILTROS_VALIDOS = {
    "todas",
    "mas_barata",
    "mas_cara",
    "mas_corta",
    "mas_larga",
    "presupuesto",
    "servicio",
    "gasolinera",
    "turistica",
    "tipo",
    "mixta",
    "lugar",
    "rango_costo",
    "n_turisticos",
    "multiples_condiciones",
}


def _normalizar_texto(valor: Any) -> str:
    """Normaliza cadenas para usarlas en consultas Prolog."""
    if valor is None:
        return ""
    return str(valor).strip().lower().replace(" ", "_")


def _obtener_rutas(origen: str, destino: str) -> List[Dict[str, Any]]:
    """Obtiene todas las rutas posibles desde Prolog usando ruta_con_costo/5."""
    consulta = f"ruta_con_costo({origen}, {destino}, Ruta, Costo, Distancia)"
    resultados = []
    for sol in prolog.query(consulta):
        ruta = [str(n) for n in sol["Ruta"]]
        resultados.append(
            {
                "ruta": ruta,
                "costo": int(sol["Costo"]),
                "distancia": int(sol["Distancia"]),
            }
        )
    return resultados


def _cumple_servicio(ruta: List[str], servicio: str) -> bool:
    """Valida si al menos un lugar de la ruta tiene el servicio solicitado."""
    for lugar in ruta:
        if list(prolog.query(f"servicio({lugar}, {servicio})")):
            return True
    return False


def _es_mixta(ruta: List[str]) -> bool:
    """Valida que la ruta use al menos un tramo cuota y uno libre."""
    tipos = set()
    for i in range(len(ruta) - 1):
        a, b = ruta[i], ruta[i + 1]
        for sol in prolog.query(f"camino({a}, {b}, _, _, Tipo)"):
            tipos.add(str(sol["Tipo"]))
            break
    return "cuota" in tipos and "libre" in tipos


def _contar_turisticos(ruta: List[str]) -> int:
    """Cuenta lugares turísticos presentes en una ruta."""
    return sum(1 for l in ruta if list(prolog.query(f"servicio({l}, turistico)")))


def _filtrar_rutas(rutas: List[Dict[str, Any]], data: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Aplica el filtro solicitado por el cliente sobre la lista de rutas."""
    filtro = data["filtro"]

    if filtro == "todas":
        return rutas
    if filtro == "mas_barata":
        return [min(rutas, key=lambda r: r["costo"])]
    if filtro == "mas_cara":
        return [max(rutas, key=lambda r: r["costo"])]
    if filtro == "mas_corta":
        return [min(rutas, key=lambda r: r["distancia"])]
    if filtro == "mas_larga":
        return [max(rutas, key=lambda r: r["distancia"])]
    if filtro == "presupuesto":
        presupuesto = int(data.get("presupuesto", 0))
        return [r for r in rutas if r["costo"] <= presupuesto]
    if filtro in {"servicio", "gasolinera", "turistica"}:
        servicio = _normalizar_texto(data.get("servicio"))
        if filtro == "gasolinera":
            servicio = "gasolinera"
        if filtro == "turistica":
            servicio = "turistico"
        return [r for r in rutas if _cumple_servicio(r["ruta"], servicio)]
    if filtro == "tipo":
        tipo = _normalizar_texto(data.get("tipo_camino"))
        return [
            r
            for r in rutas
            if all(
                list(
                    prolog.query(
                        f"camino({r['ruta'][i]}, {r['ruta'][i+1]}, _, _, {tipo})"
                    )
                )
                for i in range(len(r["ruta"]) - 1)
            )
        ]
    if filtro == "mixta":
        return [r for r in rutas if _es_mixta(r["ruta"])]
    if filtro == "lugar":
        requerido = _normalizar_texto(data.get("lugar_obligatorio"))
        return [r for r in rutas if requerido in r["ruta"]]
    if filtro == "rango_costo":
        cmin = int(data.get("costo_min", 0))
        cmax = int(data.get("costo_max", 10**9))
        return [r for r in rutas if cmin <= r["costo"] <= cmax]
    if filtro == "n_turisticos":
        minimo = int(data.get("min_turisticos", 1))
        return [r for r in rutas if _contar_turisticos(r["ruta"]) >= minimo]
    if filtro == "multiples_condiciones":
        presupuesto = int(data.get("presupuesto", 10**9))
        tipo = _normalizar_texto(data.get("tipo_camino"))
        servicio = _normalizar_texto(data.get("servicio"))
        lugar = _normalizar_texto(data.get("lugar_obligatorio"))
        minimo_turisticos = int(data.get("min_turisticos", 0))
        return [
            r
            for r in rutas
            if r["costo"] <= presupuesto
            and (not lugar or lugar in r["ruta"])
            and (not servicio or _cumple_servicio(r["ruta"], servicio))
            and (not tipo or all(list(prolog.query(f"camino({r['ruta'][i]}, {r['ruta'][i+1]}, _, _, {tipo})")) for i in range(len(r["ruta"]) - 1)))
            and _contar_turisticos(r["ruta"]) >= minimo_turisticos
        ]
    return []


@app.get("/")
def home() -> Any:
    """Sirve el index.html desde templates."""
    return send_from_directory(app.template_folder, "index.html")


@app.get("/api/lugares")
def lugares() -> Any:
    """Regresa lugares disponibles en la base de conocimiento."""
    datos = sorted({str(sol["X"]) for sol in prolog.query("lugar(X)")})
    return jsonify({"success": True, "resultados": datos})


@app.get("/api/servicios")
def servicios() -> Any:
    """Regresa tipos de servicios disponibles en la base de conocimiento."""
    datos = sorted({str(sol["S"]) for sol in prolog.query("servicio(_, S)")})
    return jsonify({"success": True, "resultados": datos})


@app.post("/api/rutas")
def rutas() -> Any:
    """Calcula rutas entre origen y destino aplicando filtros solicitados."""
    data = request.get_json(silent=True) or {}
    origen = _normalizar_texto(data.get("origen"))
    destino = _normalizar_texto(data.get("destino"))
    filtro = _normalizar_texto(data.get("filtro"))

    if not origen:
        return jsonify({"success": False, "error": "origen vacío"}), 400
    if not destino:
        return jsonify({"success": False, "error": "destino vacío"}), 400
    if filtro not in FILTROS_VALIDOS:
        return jsonify({"success": False, "error": "filtro no válido"}), 400

    rutas_base = _obtener_rutas(origen, destino)
    if not rutas_base:
        return jsonify({"success": False, "error": "no existen rutas"}), 404

    rutas_filtradas = _filtrar_rutas(rutas_base, {**data, "filtro": filtro})
    if not rutas_filtradas:
        return jsonify({"success": False, "error": "no existen rutas"}), 404

    return jsonify({"success": True, "resultados": rutas_filtradas})


if __name__ == "__main__":
    # Modo debug para desarrollo local.
    app.run(host="0.0.0.0", port=5000, debug=True)
