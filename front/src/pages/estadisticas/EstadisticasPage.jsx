// src/pages/estadisticas/EstadisticasPage.jsx
import { useState, useEffect, useCallback, useRef } from "react";
import { sesionesApi, entrenamientosApi } from "../../api/api";

const BASE_URL = "http://localhost:5000/api";

// ── Paleta coherente con el resto de la app ──────────────────────────────────
const S = {
  select: {
    padding: "8px 12px",
    border: "1px solid #D1D5DB",
    borderRadius: 6,
    fontSize: 14,
    minWidth: 280,
    background: "#fff",
    cursor: "pointer",
  },
  tabla: { width: "100%", borderCollapse: "collapse", fontSize: 14 },
  th: {
    padding: "10px 12px",
    background: "#1A3C6E",
    color: "#fff",
    textAlign: "left",
    fontWeight: 600,
    fontSize: 13,
    whiteSpace: "nowrap",
  },
  thAccion: {
    padding: "10px 8px",
    background: "#1A3C6E",
    color: "#fff",
    textAlign: "center",
    fontWeight: 600,
    fontSize: 13,
    width: 36,
  },
  td: {
    padding: "8px 12px",
    borderBottom: "1px solid #E5E7EB",
    verticalAlign: "middle",
  },
  tdAccion: {
    padding: "8px",
    borderBottom: "1px solid #E5E7EB",
    verticalAlign: "middle",
    textAlign: "center",
  },
  input: {
    width: "100%",
    padding: "5px 8px",
    border: "1px solid #D1D5DB",
    borderRadius: 6,
    fontSize: 13,
    boxSizing: "border-box",
    background: "#fff",
  },
  errBox: {
    background: "#FEE2E2",
    color: "#991B1B",
    borderRadius: 6,
    padding: "8px 12px",
    fontSize: 13,
    marginBottom: 12,
  },
  okBox: {
    background: "#DCFCE7",
    color: "#15803D",
    borderRadius: 6,
    padding: "8px 12px",
    fontSize: 13,
    marginBottom: 12,
  },
  infoBox: {
    background: "#EFF6FF",
    color: "#1D4ED8",
    borderRadius: 6,
    padding: "8px 12px",
    fontSize: 13,
    marginBottom: 12,
    display: "flex",
    alignItems: "center",
    gap: 6,
  },
  nota: (n) => ({
    display: "inline-block",
    padding: "3px 10px",
    borderRadius: 12,
    fontSize: 12,
    fontWeight: 700,
    background: n >= 8 ? "#DCFCE7" : n >= 6 ? "#FEF9C3" : "#FEE2E2",
    color: n >= 8 ? "#15803D" : n >= 6 ? "#92400E" : "#991B1B",
  }),
  tipoBadge: (tipo) => ({
    display: "inline-block",
    padding: "3px 12px",
    borderRadius: 20,
    fontSize: 12,
    fontWeight: 700,
    marginLeft: 8,
    background:
      tipo === "Físico" ? "#FEF3C7"
      : tipo === "Técnico" ? "#DBEAFE"
      : tipo === "Táctico" ? "#F3E8FF"
      : tipo === "Mixto" ? "#DCFCE7"
      : "#F3F4F6",
    color:
      tipo === "Físico" ? "#92400E"
      : tipo === "Técnico" ? "#1D4ED8"
      : tipo === "Táctico" ? "#6B21A8"
      : tipo === "Mixto" ? "#15803D"
      : "#374151",
  }),
  tagSugerido: {
    display: "inline-block",
    padding: "2px 8px",
    borderRadius: 10,
    fontSize: 11,
    fontWeight: 600,
    background: "#DBEAFE",
    color: "#1D4ED8",
    marginLeft: 4,
  },
  tagPersonalizado: {
    display: "inline-block",
    padding: "2px 8px",
    borderRadius: 10,
    fontSize: 11,
    fontWeight: 600,
    background: "#F3E8FF",
    color: "#6B21A8",
    marginLeft: 4,
  },
};

// ── Columnas base por tipo de sesión ─────────────────────────────────────────
const COLUMNAS_BASE = {
  fisico: [
    { key: "distancia_km", label: "Distancia (km)", type: "number", step: "0.1", placeholder: "ej. 7.2" },
    { key: "sprints",      label: "Sprints",         type: "number", step: "1",   placeholder: "ej. 15"  },
    { key: "series",       label: "Series",          type: "number", step: "1",   placeholder: "ej. 4"   },
    { key: "repeticiones", label: "Repeticiones",    type: "number", step: "1",   placeholder: "ej. 12"  },
    { key: "descripcion_ejercicio", label: "Ejercicio", type: "text", placeholder: "ej. Sentadillas" },
    { key: "nota",         label: "Nota /10",        type: "number", step: "0.5", placeholder: "ej. 8", max: "10" },
  ],
  tecnico: [
    { key: "pases_completados",  label: "Pases completados",  type: "number", step: "1",   placeholder: "ej. 30" },
    { key: "ejercicios_tecnicos",label: "Ejercicios técnicos",type: "text",               placeholder: "ej. Conducción" },
    { key: "balones_usados",     label: "Balones",            type: "number", step: "1",   placeholder: "ej. 3" },
    { key: "conos_usados",       label: "Conos",              type: "number", step: "1",   placeholder: "ej. 10" },
    { key: "nota",               label: "Nota /10",           type: "number", step: "0.5", placeholder: "ej. 8", max: "10" },
  ],
  tactico: [
    { key: "posicion_tactica",      label: "Posición táctica",      type: "text",               placeholder: "ej. Extremo der." },
    { key: "cumplimiento_sistema",  label: "Cumplim. sistema /10",  type: "number", step: "0.5", placeholder: "ej. 7", max: "10" },
    { key: "descripcion_tactica",   label: "Obs. táctica",          type: "text",               placeholder: "ej. Buena presión" },
    { key: "nota",                  label: "Nota /10",              type: "number", step: "0.5", placeholder: "ej. 8", max: "10" },
  ],
  mixto: [
    { key: "distancia_km",        label: "Distancia (km)",       type: "number", step: "0.1", placeholder: "ej. 7.2" },
    { key: "sprints",             label: "Sprints",              type: "number", step: "1",   placeholder: "ej. 15" },
    { key: "series",              label: "Series",               type: "number", step: "1",   placeholder: "ej. 4" },
    { key: "repeticiones",        label: "Repeticiones",         type: "number", step: "1",   placeholder: "ej. 12" },
    { key: "pases_completados",   label: "Pases completados",    type: "number", step: "1",   placeholder: "ej. 30" },
    { key: "ejercicios_tecnicos", label: "Ejercicios técnicos",  type: "text",               placeholder: "ej. Pase" },
    { key: "nota",                label: "Nota /10",             type: "number", step: "0.5", placeholder: "ej. 8", max: "10" },
  ],
};

// Campos que nunca se muestran como columnas
const CAMPOS_IGNORAR = new Set([
  "cedula_jugador", "nombre", "_id", "identificacion_jugador",
  "id_entrenamiento", "id_entrenamiento_mysql",
]);

// ── Inferir columnas dinámicas ───────────────────────────────────────────────
function valorConContenido(value) {
  if (value === undefined || value === null || value === "") return false;
  if (typeof value === "number") return value !== 0;
  if (Array.isArray(value)) return value.length > 0;
  return true;
}

function inferirTipoDesdeDocs(key, docs) {
  for (const doc of docs) {
    const value = doc?.[key];
    if (!valorConContenido(value)) continue;
    return typeof value === "number" ? "number" : "text";
  }
  return "text";
}

function columnaDesdeCampoComun(campo) {
  const type = campo.type === "number" ? "number" : "text";
  return {
    key: campo.key,
    label: campo.label || campo.key.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
    type,
    step: type === "number" ? "0.1" : undefined,
    placeholder: type === "number" ? "ej. 0" : "texto libre",
    esSugerido: true,
    frecuencia: campo.frecuencia || 0,
  };
}

// Devuelve columnas base del tipo + campos usados previamente en la colección.
function inferirColumnas(tipo, estadisticasGuardadas, camposComunesGlobales = []) {
  const t = (tipo || "")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

  const base = COLUMNAS_BASE[t] || COLUMNAS_BASE["fisico"];
  const keysBase = new Set(base.map((c) => c.key));
  const extrasMap = new Map();

  for (const campo of camposComunesGlobales || []) {
    if (!campo?.key || CAMPOS_IGNORAR.has(campo.key) || keysBase.has(campo.key)) continue;
    extrasMap.set(campo.key, columnaDesdeCampoComun(campo));
  }

  const frecuenciaLocal = {};
  for (const doc of estadisticasGuardadas) {
    for (const key of Object.keys(doc)) {
      if (CAMPOS_IGNORAR.has(key) || keysBase.has(key)) continue;
      if (!valorConContenido(doc[key])) continue;
      frecuenciaLocal[key] = (frecuenciaLocal[key] || 0) + 1;
    }
  }

  for (const [key, freq] of Object.entries(frecuenciaLocal)) {
    const existente = extrasMap.get(key);
    const type = existente?.type || inferirTipoDesdeDocs(key, estadisticasGuardadas);
    extrasMap.set(key, {
      key,
      label: existente?.label || key.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()),
      type,
      step: type === "number" ? "0.1" : undefined,
      placeholder: type === "number" ? "ej. 0" : "texto libre",
      esSugerido: true,
      frecuencia: Math.max(freq, existente?.frecuencia || 0),
    });
  }

  const extras = Array.from(extrasMap.values())
    .sort((a, b) => (b.frecuencia || 0) - (a.frecuencia || 0) || a.label.localeCompare(b.label));

  return { columnas: [...base, ...extras], hayExtras: extras.length > 0 };
}

// Fila vacía para un jugador presente
function filaVacia(jugador, columnas) {
  const fila = {
    cedula_jugador: jugador.identificacion_jugador,
    nombre: `${jugador.nombre} ${jugador.apellido}`,
  };
  columnas.forEach((col) => { fila[col.key] = ""; });
  return fila;
}

// ── Modal para agregar campo personalizado ────────────────────────────────────
function ModalNuevoCampo({ onAgregar, onCerrar }) {
  const [key, setKey]     = useState("");
  const [label, setLabel] = useState("");
  const [type, setType]   = useState("number");
  const [error, setError] = useState("");
  const inputRef = useRef(null);

  useEffect(() => { inputRef.current?.focus(); }, []);

  function handleKey(e) {
    // Normalizar: minúsculas, sin espacios → guiones bajos
    const v = e.target.value.toLowerCase().replace(/\s+/g, "_").replace(/[^a-z0-9_]/g, "");
    setKey(v);
    if (!label || label === key.replace(/_/g, " ")) {
      setLabel(v.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase()));
    }
  }

  function handleSubmit() {
    if (!key.trim()) { setError("El nombre del campo es obligatorio."); return; }
    if (!label.trim()) { setError("La etiqueta es obligatoria."); return; }
    onAgregar({
      key: key.trim(),
      label: label.trim(),
      type,
      step: type === "number" ? "0.1" : undefined,
      placeholder: type === "number" ? "ej. 0" : "texto libre",
      esPersonalizado: true,
    });
  }

  return (
    <div style={{
      position: "fixed", inset: 0, background: "rgba(0,0,0,0.4)",
      display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000,
    }}>
      <div style={{
        background: "#fff", borderRadius: 12, padding: 28, width: 380,
        boxShadow: "0 20px 60px rgba(0,0,0,0.2)",
      }}>
        <h3 style={{ margin: "0 0 20px", fontSize: 16, color: "#111827" }}>
          Agregar campo personalizado
        </h3>

        {error && <div style={S.errBox}>{error}</div>}

        <div style={{ marginBottom: 14 }}>
          <label style={{ fontSize: 13, fontWeight: 600, color: "#374151", display: "block", marginBottom: 4 }}>
            Nombre del campo
          </label>
          <input
            ref={inputRef}
            style={S.input}
            placeholder="ej. Controles de balon perfectos"
            value={key}
            onChange={handleKey}
          />
          <span style={{ fontSize: 11, color: "#9CA3AF" }}>
            Solo letras minúsculas y guiones bajos
          </span>
        </div>

        <div style={{ marginBottom: 14 }}>
          <label style={{ fontSize: 13, fontWeight: 600, color: "#374151", display: "block", marginBottom: 4 }}>
            Etiqueta visible
          </label>
          <input
            style={S.input}
            placeholder="ej. Frec. cardíaca"
            value={label}
            onChange={(e) => setLabel(e.target.value)}
          />
        </div>

        <div style={{ marginBottom: 20 }}>
          <label style={{ fontSize: 13, fontWeight: 600, color: "#374151", display: "block", marginBottom: 4 }}>
            Tipo de dato
          </label>
          <div style={{ display: "flex", gap: 8 }}>
            {["number", "text"].map((t) => (
              <button
                key={t}
                onClick={() => setType(t)}
                style={{
                  flex: 1, padding: "7px 0", borderRadius: 6, fontSize: 13,
                  border: type === t ? "2px solid #1A3C6E" : "1px solid #D1D5DB",
                  background: type === t ? "#EFF6FF" : "#fff",
                  color: type === t ? "#1A3C6E" : "#6B7280",
                  fontWeight: type === t ? 700 : 400,
                  cursor: "pointer",
                }}
              >
                {t === "number" ? "🔢 Número" : "🔤 Texto"}
              </button>
            ))}
          </div>
        </div>

        <div style={{ display: "flex", gap: 8, justifyContent: "flex-end" }}>
          <button className="btn btn--secondary" onClick={onCerrar}>Cancelar</button>
          <button className="btn btn--primary" onClick={handleSubmit}>Agregar columna</button>
        </div>
      </div>
    </div>
  );
}


// ── Tarjeta de resumen computado ─────────────────────────────────────────────
function ResumenCard({ resumen }) {
  if (!resumen) return null;

  const tipo = (resumen.tipo_sesion || "")
    .toLowerCase()
    .replace(/[áéíóú]/g, c => ({ á:"a",é:"e",í:"i",ó:"o",ú:"u" }[c] || c));

  // Tarjetas universales
  const items = [
    { label: "Jugadores", value: resumen.total_jugadores ?? "—", icon: "👥" },
    { label: "Promedio nota",
      value: resumen.promedio_nota ? `${resumen.promedio_nota}/10` : "—", icon: "📊",
      color: resumen.promedio_nota >= 8 ? "#15803D" : resumen.promedio_nota >= 6 ? "#92400E" : "#991B1B",
      bg:    resumen.promedio_nota >= 8 ? "#DCFCE7" : resumen.promedio_nota >= 6 ? "#FEF9C3" : "#FEE2E2" },
  ];

  // Métricas según tipo
  if (["fisico", "mixto"].includes(tipo)) {
    items.push(
      { label: "Distancia total",
        value: resumen.distancia_total_km ? `${resumen.distancia_total_km} km` : "—", icon: "🏃" },
      { label: "Sprints totales", value: resumen.sprints_total || "—", icon: "⚡" },
    );
  }
  if (["tecnico", "mixto"].includes(tipo)) {
    items.push(
      { label: "Pases (promedio)", value: resumen.promedio_pases ?? "—", icon: "🎯" },
    );
  }
  if (tipo === "tactico") {
    items.push(
      { label: "Cumplim. sistema (prom.)",
        value: resumen.promedio_cumplimiento ? `${resumen.promedio_cumplimiento}/10` : "—", icon: "🧠" },
    );
  }

  // Jugador destacado siempre al final
  items.push({ label: "Jugador destacado", value: resumen.nombre_destacado || "—", icon: "⭐", wide: true });
  return (
    <div style={{
      display: "flex", flexWrap: "wrap", gap: 10, marginBottom: 20,
      padding: "14px 16px", background: "#F8FAFF",
      border: "1px solid #C7D7F5", borderRadius: 10,
    }}>
      <div style={{ width: "100%", marginBottom: 4, fontSize: 12, fontWeight: 700,
        color: "#1A3C6E", textTransform: "uppercase", letterSpacing: "0.05em" }}>
        Resumen de la sesión
      </div>
      {items.map((item) => (
        <div key={item.label} style={{
          flex: item.wide ? "1 1 100%" : "1 1 140px",
          background: item.bg ?? "#fff",
          border: "1px solid #E5E7EB", borderRadius: 8,
          padding: "10px 14px", display: "flex", flexDirection: "column", gap: 2,
        }}>
          <span style={{ fontSize: 11, color: "#6B7280", fontWeight: 600 }}>
            {item.icon} {item.label}
          </span>
          <span style={{ fontSize: 18, fontWeight: 700, color: item.color ?? "#111827" }}>
            {item.value}
          </span>
        </div>
      ))}
    </div>
  );
}

// ── Componente principal ──────────────────────────────────────────────────────
function EstadisticasPage() {
  const [entrenamientos, setEntrenamientos]   = useState([]);
  const [idSeleccionado, setIdSeleccionado]   = useState("");
  const [estadisticas, setEstadisticas]       = useState([]);
  const [resumen, setResumen]                 = useState(null);
  const [editando, setEditando]               = useState(false);
  const [filas, setFilas]                     = useState([]);
  const [columnas, setColumnas]               = useState([]);
  const [cargando, setCargando]               = useState(false);
  const [guardando, setGuardando]             = useState(false);
  const [eliminando, setEliminando]           = useState(false);
  const [error, setError]                     = useState("");
  const [exito, setExito]                     = useState("");
  const [modalCampo, setModalCampo]           = useState(false);
  const [hayExtrasInferidos, setHayExtras]    = useState(false);
  const [camposComunes, setCamposComunes]     = useState([]);

  const user = JSON.parse(localStorage.getItem("ft_user") || "{}");
  const esAdmin = user.tipo_usuario === "admin";

  const cargarCamposComunes = useCallback(async (id = '') => {
    try {
      const data = await sesionesApi.obtenerCamposEstadisticas(id);
      const comunes = data.campos || [];
      setCamposComunes(comunes);
      return comunes;
    } catch (_) {
      setCamposComunes([]);
      return [];
    }
  }, []);


  useEffect(() => {
    entrenamientosApi.listar()
      .then(setEntrenamientos)
      .catch((err) => setError(err.message));
  }, []);

  const entSeleccionado = entrenamientos.find(
    (e) => String(e.id_entrenamiento) === idSeleccionado
  );
  const tipoActual = entSeleccionado?.tipo || "";

  // ── Cargar estadísticas + inferir columnas ──────────────────────────────────
  const cargar = useCallback(async (id, tipo, comunesOverride = null) => {
    if (!id) return;
    const comunes = comunesOverride || camposComunes;
    setCargando(true);
    setError(""); setExito(""); setEditando(false);

    try {
      // 1. Asistentes presentes
      const resAsist = await fetch(`${BASE_URL}/asistencia/${id}`, { credentials: "include" });
      const asistentes = await resAsist.json();
      const presentes  = Array.isArray(asistentes)
        ? asistentes.filter((a) => a.estado_asistencia === "presente")
        : [];

      // 2. Estadísticas guardadas en Mongo
      let statsGuardadas = [];
      let resumenGuardado = null;
      try {
        const resp = await sesionesApi.obtenerEstadisticas(id);
        // El backend devuelve { jugadores: [...], resumen: {...} }
        // o [] si no hay nada (compatibilidad con versión anterior)
        if (Array.isArray(resp)) {
          statsGuardadas = resp;
        } else {
          statsGuardadas  = resp.jugadores ?? [];
          resumenGuardado = resp.resumen   ?? null;
        }
      } catch (_) { statsGuardadas = []; }

      setEstadisticas(statsGuardadas);
      setResumen(resumenGuardado);

      // 3. Inferir columnas desde los docs guardados
      const { columnas: cols, hayExtras } = inferirColumnas(tipo || tipoActual, statsGuardadas, comunes);
      setColumnas(cols);
      setHayExtras(hayExtras);

      // 4. Construir filas
      if (statsGuardadas.length > 0) {
        setFilas(statsGuardadas.map((d) => {
          const fila = { cedula_jugador: d.cedula_jugador, nombre: d.nombre ?? d.cedula_jugador };
          cols.forEach((col) => { fila[col.key] = d[col.key] ?? ""; });
          return fila;
        }));
      } else if (presentes.length > 0) {
        setFilas(presentes.map((j) => filaVacia(j, cols)));
      } else {
        setFilas([]);
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }, [tipoActual, camposComunes]);

  async function handleSeleccion(e) {
    const id  = e.target.value;
    setIdSeleccionado(id);
    const ent = entrenamientos.find((x) => String(x.id_entrenamiento) === id);
    const comunes = await cargarCamposComunes(id);
    cargar(id, ent?.tipo || "", comunes);
  }

  function setFila(i, campo, val) {
    setFilas((prev) => prev.map((f, idx) => idx === i ? { ...f, [campo]: val } : f));
  }

  // ── Agregar campo personalizado ─────────────────────────────────────────────
  function agregarCampo(nuevaCol) {
    // Evitar duplicados
    if (columnas.some((c) => c.key === nuevaCol.key)) {
      setError(`Ya existe una columna con el nombre "${nuevaCol.key}".`);
      setModalCampo(false);
      return;
    }
    // Insertar antes de "nota" si existe, si no al final
    const notaIdx = columnas.findIndex((c) => c.key === "nota");
    const nuevasCols = [...columnas];
    if (notaIdx >= 0) {
      nuevasCols.splice(notaIdx, 0, nuevaCol);
    } else {
      nuevasCols.push(nuevaCol);
    }
    setColumnas(nuevasCols);
    // Agregar el campo vacío a cada fila
    setFilas((prev) => prev.map((f) => ({ ...f, [nuevaCol.key]: "" })));
    setModalCampo(false);
  }

  // ── Eliminar columna personalizada ──────────────────────────────────────────
  function eliminarColumna(key) {
    if (!window.confirm(`¿Quitar la columna "${key}" de la vista de edición?`)) return;
    setColumnas((prev) => prev.filter((c) => c.key !== key));
    setFilas((prev) => prev.map((f) => { const n = { ...f }; delete n[key]; return n; }));
  }

  // ── Guardar ─────────────────────────────────────────────────────────────────
  async function guardar() {
    if (!idSeleccionado) return;
    setGuardando(true); setError(""); setExito("");
    try {
      const payload = filas.map((f) => {
        const item = { cedula_jugador: f.cedula_jugador, nombre: f.nombre };
        columnas.forEach((col) => {
          item[col.key] = col.type === "number"
            ? (parseFloat(f[col.key]) || 0)
            : (f[col.key] || "");
        });
        return item;
      });
      await sesionesApi.guardarEstadisticas(Number(idSeleccionado), payload);
      setExito("Estadísticas guardadas correctamente.");
      setEditando(false);
      const comunes = await cargarCamposComunes(idSeleccionado);
      await cargar(idSeleccionado, tipoActual, comunes);
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  // ── Eliminar sesión ─────────────────────────────────────────────────────────
  async function eliminar() {
    if (!window.confirm("¿Eliminar todas las estadísticas de esta sesión?")) return;
    setEliminando(true); setError("");
    try {
      await sesionesApi.eliminarEstadisticas(Number(idSeleccionado));
      setExito("Estadísticas eliminadas correctamente.");
      setEstadisticas([]); setResumen(null); setFilas([]); setEditando(false);
    } catch (err) {
      setError(err.message);
    } finally {
      setEliminando(false);
    }
  }

  // ── Render ──────────────────────────────────────────────────────────────────
  return (
    <div>
      {modalCampo && (
        <ModalNuevoCampo
          onAgregar={agregarCampo}
          onCerrar={() => setModalCampo(false)}
        />
      )}

      <div className="page-header">
        <div>
          <h2 className="page-title">Estadísticas</h2>
          <p className="page-subtitle">Métricas por jugador de la sesión</p>
        </div>
      </div>

      {/* Selector de sesión */}
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
        <label style={{ fontWeight: 600, fontSize: 14, color: "#374151" }}>Sesión:</label>
        <select style={S.select} value={idSeleccionado} onChange={handleSeleccion}>
          <option value="">— Selecciona una sesión —</option>
          {entrenamientos.map((e) => (
            <option key={e.id_entrenamiento} value={e.id_entrenamiento}>
              #{e.id_entrenamiento} · {e.fecha} · {e.tipo} · {e.categoria_nombre}
            </option>
          ))}
        </select>
      </div>

      {error && <div style={S.errBox}>⚠ {error}</div>}
      {exito && <div style={S.okBox}>✓ {exito}</div>}

      {entSeleccionado && (
        <div style={{
          background: "#F0F4FF", borderRadius: 8, padding: "12px 16px",
          marginBottom: 16, fontSize: 14, color: "#1A3C6E",
        }}>
          <strong>{entSeleccionado.tipo}</strong>
          <span style={S.tipoBadge(entSeleccionado.tipo)}>{entSeleccionado.tipo}</span>
          {" — "}{entSeleccionado.fecha} — {entSeleccionado.lugar_nombre}
        </div>
      )}

      {cargando ? (
        <p style={{ color: "#6B7280" }}>Cargando estadísticas…</p>
      ) : idSeleccionado ? (
        <>
          <ResumenCard resumen={resumen} />

          {/* Cabecera con conteo y acciones */}
          <div style={{
            display: "flex", justifyContent: "space-between",
            alignItems: "center", marginBottom: 12, flexWrap: "wrap", gap: 8,
          }}>
            <p style={{ fontSize: 14, color: "#6B7280", margin: 0 }}>
              {estadisticas.length > 0
                ? `${estadisticas.length} jugador(es) con estadísticas registradas`
                : filas.length > 0
                  ? `${filas.length} jugador(es) presente(s) — sin estadísticas guardadas aún`
                  : "Sin asistentes registrados para esta sesión."}
            </p>
            {!editando && filas.length > 0 && !esAdmin && (
              <div style={{ display: "flex", gap: 8 }}>
                <button className="btn btn--primary btn--sm" onClick={() => setEditando(true)}>
                  {estadisticas.length > 0 ? "Editar estadísticas" : "+ Ingresar estadísticas"}
                </button>
                {estadisticas.length > 0 && (
                  <button className="btn btn--danger btn--sm" onClick={eliminar} disabled={eliminando}>
                    {eliminando ? "Eliminando…" : "Eliminar estadísticas"}
                  </button>
                )}
              </div>
            )}
          </div>

          {/* ── Vista solo lectura ── */}
          {!editando && estadisticas.length > 0 && (
            <div style={{ overflowX: "auto", borderRadius: 10, border: "1px solid #E5E7EB" }}>
              <table style={S.tabla}>
                <thead>
                  <tr>
                    <th style={S.th}>Cédula</th>
                    <th style={S.th}>Nombre</th>
                    {columnas.map((col) => (
                      <th key={col.key} style={S.th}>
                        {col.label}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {estadisticas.map((e, i) => (
                    <tr key={i} style={{ background: i % 2 === 0 ? "#fff" : "#F9FAFB" }}>
                      <td style={{ ...S.td, color: "#6B7280", fontSize: 13 }}>{e.cedula_jugador}</td>
                      <td style={{ ...S.td, fontWeight: 600 }}>{e.nombre || "—"}</td>
                      {columnas.map((col) => (
                        <td key={col.key} style={S.td}>
                          {e[col.key] !== undefined && e[col.key] !== null && e[col.key] !== "" ? (
                            col.key === "nota" || col.key === "cumplimiento_sistema" ? (
                              <span style={S.nota(Number(e[col.key]))}>{e[col.key]}/10</span>
                            ) : (
                              e[col.key]
                            )
                          ) : (
                            <span style={{ color: "#D1D5DB" }}>—</span>
                          )}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {/* ── Vista edición ── */}
          {editando && (
            <>
              <div style={{ overflowX: "auto", borderRadius: 10, border: "1px solid #E5E7EB" }}>
                <table style={S.tabla}>
                  <thead>
                    <tr>
                      <th style={S.th}>Cédula</th>
                      <th style={S.th}>Nombre</th>
                      {columnas.map((col) => (
                        <th key={col.key} style={{ ...S.th, position: "relative" }}>
                          <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
                            <span>{col.label}</span>
                            {/* Botón eliminar columna — solo para personalizadas o sugeridas */}
                            {(col.esSugerido || col.esPersonalizado) && (
                              <button
                                onClick={() => eliminarColumna(col.key)}
                                title="Quitar esta columna de la vista"
                                style={{
                                  background: "rgba(255,255,255,0.15)", border: "none",
                                  borderRadius: 4, color: "#fff", cursor: "pointer",
                                  fontSize: 11, padding: "1px 5px", lineHeight: 1,
                                }}
                              >
                                ✕
                              </button>
                            )}
                          </div>
                        </th>
                      ))}
                      {/* Columna del botón + Campo */}
                      <th style={{ ...S.th, width: 48, textAlign: "center" }}>
                        <button
                          onClick={() => setModalCampo(true)}
                          title="Agregar campo personalizado"
                          style={{
                            background: "rgba(255,255,255,0.2)", border: "1px solid rgba(255,255,255,0.4)",
                            borderRadius: 6, color: "#fff", cursor: "pointer",
                            fontSize: 16, width: 28, height: 28, lineHeight: 1,
                            display: "inline-flex", alignItems: "center", justifyContent: "center",
                          }}
                        >
                          +
                        </button>
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {filas.map((f, i) => (
                      <tr key={i} style={{ background: i % 2 === 0 ? "#fff" : "#F9FAFB" }}>
                        <td style={{ ...S.td, color: "#6B7280", fontSize: 13 }}>{f.cedula_jugador}</td>
                        <td style={{ ...S.td, fontWeight: 600 }}>{f.nombre}</td>
                        {columnas.map((col) => (
                          <td key={col.key} style={S.td}>
                            <input
                              style={S.input}
                              type={col.type}
                              step={col.step}
                              max={col.max}
                              min="0"
                              placeholder={col.placeholder}
                              value={f[col.key] ?? ""}
                              onChange={(e) => setFila(i, col.key, e.target.value)}
                            />
                          </td>
                        ))}
                        {/* Celda vacía bajo el botón + */}
                        <td style={S.tdAccion} />
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Acciones guardar/cancelar */}
              <div style={{ display: "flex", justifyContent: "flex-end", gap: 8, marginTop: 12 }}>
                <button
                  className="btn btn--secondary"
                  onClick={() => { setEditando(false); cargar(idSeleccionado, tipoActual); }}
                  disabled={guardando}
                >
                  Cancelar
                </button>
                <button className="btn btn--primary" onClick={guardar} disabled={guardando}>
                  {guardando ? "Guardando…" : "Guardar"}
                </button>
              </div>
            </>
          )}
        </>
      ) : null}
    </div>
  );
}

export default EstadisticasPage;