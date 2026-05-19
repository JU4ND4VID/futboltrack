// src/api/api.js
// ─────────────────────────────────────────────────────────────────
// Cliente HTTP centralizado para FutbolTrack.
// • Siempre usa credentials:'include' para la cookie de sesión Flask.
// • Lanza un Error con el mensaje del backend en caso de fallo.
// ─────────────────────────────────────────────────────────────────

const BASE_URL = "http://localhost:5000";

async function request(method, path, body = undefined) {
  const options = {
    method,
    credentials: "include",
    headers: { "Content-Type": "application/json" },
  };
  if (body !== undefined) {
    options.body = JSON.stringify(body);
  }

  const res = await fetch(BASE_URL + path, options);
  const data = await res.json();

  if (!res.ok) {
    throw new Error(data.mensaje || `Error ${res.status}`);
  }
  return data;
}

// ── Helpers de conveniencia ───────────────────────────────────────
export const api = {
  get: (path) => request("GET", path),
  post: (path, body) => request("POST", path, body),
  put: (path, body) => request("PUT", path, body),
  delete: (path) => request("DELETE", path),
};

// ── Auth ──────────────────────────────────────────────────────────
export const authApi = {
  login: (cedula, contrasena) =>
    api.post("/api/auth/login", { cedula, contrasena }),
  logout: () => api.post("/api/auth/logout"),
  me: () => api.get("/api/auth/me"),
};

// ── Entrenamientos ────────────────────────────────────────────────
export const entrenamientosApi = {
  listar: () => api.get("/api/entrenamientos/"),
  obtener: (id) => api.get(`/api/entrenamientos/${id}`),
  crear: (d) => api.post("/api/entrenamientos/", d),
  actualizarEstado: (id, estado) =>
    api.put(`/api/entrenamientos/${id}`, { estado }),
  eliminar: (id) => api.delete(`/api/entrenamientos/${id}`),
};

// ── Jugadores ─────────────────────────────────────────────────────
// ── Jugadores ─────────────────────────────────────────────────────
export const jugadoresApi = {
  listar: (params = "") => api.get(`/api/jugadores/${params}`),  // ← fetchApi → api.get
  obtener: (cedula) => api.get(`/api/jugadores/${cedula}`),
  crear: (d) => api.post("/api/jugadores/", d),
  actualizar: (cedula, d) => api.put(`/api/jugadores/${cedula}`, d),
  eliminar: (cedula) => api.delete(`/api/jugadores/${cedula}`),
};

// ── Asistencia ────────────────────────────────────────────────────
export const asistenciaApi = {
  listar: (idEntrenamiento) => api.get(`/api/asistencia/${idEntrenamiento}`),
  registrar: (idEntrenamiento, lista) =>
    api.post(`/api/asistencia/${idEntrenamiento}`, lista),
};


// ── Entrenadores ─────────────────────────────────────────────────
export const entrenadoresApi = {
  listar: () => api.get("/api/entrenadores/"),
  obtener: (cedula) => api.get(`/api/entrenadores/${cedula}`),
  crear: (d) => api.post("/api/entrenadores/", d),
  actualizar: (cedula, d) => api.put(`/api/entrenadores/${cedula}`, d),
  eliminar: (cedula) => api.delete(`/api/entrenadores/${cedula}`),
};

// ── Sesiones / MongoDB ────────────────────────────────────────────
export const sesionesApi = {
  obtenerCamposPlan: (id) => api.get(`/api/sesion/planes/campos-comunes${id ? `?id_entrenamiento=${id}` : ""}`),
  obtenerPlan: (id) => api.get(`/api/sesion/${id}`),
  crearPlan: (id, d) => api.post(`/api/sesion/${id}`, d),
  actualizarPlan: (id, d) => api.put(`/api/sesion/${id}`, d),
  eliminarPlan: (id) => api.delete(`/api/sesion/${id}`),

  obtenerCamposEstadisticas: (id) => api.get(`/api/sesion/estadisticas/campos-comunes${id ? `?id_entrenamiento=${id}` : ""}`),
  obtenerEstadisticas: (id) => api.get(`/api/sesion/estadisticas/${id}`),
  guardarEstadisticas: (id, lista) =>
    api.post(`/api/sesion/estadisticas/${id}`, lista),
  eliminarEstadisticas: (id) => api.delete(`/api/sesion/estadisticas/${id}`),
  estadisticasJugador: (cedula) =>
    api.get(`/api/sesion/estadisticas/jugador/${cedula}`),

  obtenerCamposObservaciones: (id) => api.get(`/api/sesion/observaciones/campos-comunes${id ? `?id_entrenamiento=${id}` : ""}`),
  obtenerObservaciones: (id) => api.get(`/api/sesion/observaciones/${id}`),
  guardarObservaciones: (id, d) =>
    api.post(`/api/sesion/observaciones/${id}`, d),
  eliminarObservaciones: (id) => api.delete(`/api/sesion/observaciones/${id}`),
};

// ── Catálogos ─────────────────────────────────────────────────────
export const catalogosApi = {
  lugares: () => api.get("/api/lugares"),
  categorias: () => api.get("/api/categorias"),
  crearCategoria: (d) => api.post("/api/categorias", d),
  actualizarCategoria: (id, d) => api.put(`/api/categorias/${id}`, d),
  eliminarCategoria: (id) => api.delete(`/api/categorias/${id}`),
};
