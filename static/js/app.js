// Interfaz del Sistema Experto de Rutas Turísticas.
// Maneja carga de lugares, consulta de rutas y renderizado de resultados + grafo.

document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('route-form');
  const resultsEl = document.getElementById('results');
  const loadingEl = document.getElementById('loading');
  const messageEl = document.getElementById('message');

  const selects = {
    origen: document.getElementById('origen'),
    destino: document.getElementById('destino'),
    lugarObligatorio: document.getElementById('lugar_obligatorio'),
    servicio: document.getElementById('servicio')
  };

  let network = null;

  const showMessage = (text, type = 'info') => {
    messageEl.textContent = text;
    messageEl.className = `message ${type}`;
    messageEl.classList.remove('hidden');
  };

  const hideMessage = () => {
    messageEl.classList.add('hidden');
    messageEl.textContent = '';
  };

  const setLoading = (isLoading) => {
    loadingEl.classList.toggle('hidden', !isLoading);
  };

  const llenarSelect = (id, valores) => {
    const select = document.getElementById(id);
    if (!select) return;

    select.innerHTML = '';

    valores.forEach((valor) => {
      const option = document.createElement('option');
      option.value = valor;
      option.textContent = valor === '' ? 'Ninguno' : valor.replaceAll('_', ' ');
      select.appendChild(option);
    });
  };

  const cargarLugares = async () => {
    try {
      const response = await fetch('/api/lugares');
      const data = await response.json();
      console.log('Lugares recibidos:', data);

      if (!response.ok) throw new Error(data.error || 'No se pudieron cargar los lugares.');

      if (!data.success) {
        const error = data.error || 'Respuesta inválida al cargar lugares.';
        console.error('Error al cargar lugares:', error);
        showMessage(`Error al cargar lugares: ${error}`, 'error');
        return;
      }

      const lugares = data.resultados || [];
      llenarSelect('origen', lugares);
      llenarSelect('destino', lugares);
      llenarSelect('lugar_obligatorio', ['', ...lugares]);
    } catch (error) {
      showMessage(`Error al cargar lugares: ${error.message}`, 'error');
    }
  };

  const cargarServicios = async () => {
    try {
      const response = await fetch('/api/servicios');
      const data = await response.json();
      console.log('Servicios recibidos:', data);

      if (!response.ok) throw new Error(data.error || 'No se pudieron cargar los servicios.');

      if (!data.success) {
        const error = data.error || 'Respuesta inválida al cargar servicios.';
        console.error('Error al cargar servicios:', error);
        showMessage(`Error al cargar servicios: ${error}`, 'error');
        return;
      }

      const servicios = data.resultados || [];
      llenarSelect('servicio', ['', ...servicios]);
    } catch (error) {
      showMessage(`Error al cargar servicios: ${error.message}`, 'error');
    }
  };

  const toRoutePath = (ruta) => {
    const rawPath = ruta.ruta || ruta.path || ruta.camino || [];
    if (Array.isArray(rawPath)) return rawPath;
    if (typeof rawPath === 'string') return rawPath.split(/\s*->\s*|\s*→\s*|\s*,\s*/).filter(Boolean);
    return [];
  };

  const renderGraph = (path) => {
    const container = document.getElementById('graph');
    const nodes = path.map((city, i) => ({ id: i, label: city }));
    const edges = path.slice(0, -1).map((_, i) => ({ from: i, to: i + 1, arrows: 'to' }));

    const data = { nodes, edges };
    const options = {
      physics: { enabled: true, stabilization: { iterations: 80 } },
      nodes: {
        shape: 'dot', size: 18,
        color: { background: '#0b1428', border: '#57ff8c', highlight: { background: '#132a3d', border: '#b05cff' } },
        font: { color: '#e6ebff', size: 16 }
      },
      edges: { color: { color: '#3f87ff', highlight: '#57ff8c' }, smooth: { type: 'curvedCW', roundness: 0.15 } },
      interaction: { hover: true }
    };

    if (network) network.destroy();
    network = new vis.Network(container, data, options);
  };

  const renderResults = (routes, filtro) => {
    resultsEl.innerHTML = '';

    if (!routes.length) {
      showMessage('No se encontraron rutas con los criterios especificados.', 'info');
      return;
    }

    hideMessage();

    routes.forEach((route, index) => {
      const path = toRoutePath(route);
      const card = document.createElement('article');
      card.className = 'route-card';
      card.innerHTML = `
        <div class="route-path">${path.join(' → ') || 'Ruta no disponible'}</div>
        <div class="route-meta">
          <span>Costo total: ${route.costo_total ?? route.costo ?? 'N/D'}</span>
          <span>Distancia total: ${route.distancia_total ?? route.distancia ?? 'N/D'}</span>
          <span>Filtro: ${route.filtro ?? filtro}</span>
        </div>
      `;

      card.addEventListener('click', () => {
        document.querySelectorAll('.route-card').forEach((el) => el.classList.remove('active'));
        card.classList.add('active');
        if (path.length) renderGraph(path);
      });

      resultsEl.appendChild(card);

      if (index === 0 && path.length) {
        card.classList.add('active');
        renderGraph(path);
      }
    });
  };

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    setLoading(true);
    hideMessage();

    const payload = {
      origen: form.origen.value,
      destino: form.destino.value,
      filtro: form.filtro.value,
      presupuesto: form.presupuesto.value ? Number(form.presupuesto.value) : null,
      tipo_camino: form.tipo_camino.value || null,
      servicio: form.servicio.value || null,
      lugar_obligatorio: form.lugar_obligatorio.value || null,
      costo_min: form.costo_min.value ? Number(form.costo_min.value) : null,
      costo_max: form.costo_max.value ? Number(form.costo_max.value) : null,
      min_turisticos: form.min_turisticos.value ? Number(form.min_turisticos.value) : null
    };

    try {
      const response = await fetch('/api/rutas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await response.json().catch(() => ({}));
      if (!response.ok) {
        const detail = data.error || data.message || `Error HTTP ${response.status}`;
        throw new Error(detail);
      }

      const routes = Array.isArray(data) ? data : data.resultados || data.rutas || [];
      renderResults(routes, payload.filtro);
    } catch (error) {
      resultsEl.innerHTML = '';
      showMessage(`Error al buscar rutas: ${error.message}`, 'error');
    } finally {
      setLoading(false);
    }
  });

  cargarLugares();
  cargarServicios();
});
