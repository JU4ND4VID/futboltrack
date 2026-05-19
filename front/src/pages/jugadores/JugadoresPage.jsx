// src/pages/jugadores/JugadoresPage.jsx
import { useState, useEffect, useCallback } from "react";
import { jugadoresApi, catalogosApi } from "../../api/api";

const S = {
  tabla: { width: "100%", borderCollapse: "collapse", fontSize: 14 },
  th: { padding: "10px 12px", background: "#1A3C6E", color: "#fff",
        textAlign: "left", fontWeight: 600, fontSize: 13 },
  td: { padding: "9px 12px", borderBottom: "1px solid #E5E7EB",
        verticalAlign: "middle" },
  badge: (pct) => ({
    display: "inline-block", padding: "2px 8px", borderRadius: 12,
    fontSize: 12, fontWeight: 600,
    background: pct >= 75 ? "#DCFCE7" : pct >= 50 ? "#FEF9C3" : "#FEE2E2",
    color:      pct >= 75 ? "#15803D" : pct >= 50 ? "#92400E" : "#991B1B",
  }),
  overlay: { position: "fixed", inset: 0, background: "rgba(0,0,0,.45)",
             display: "flex", alignItems: "center", justifyContent: "center",
             zIndex: 1000 },
  modal: { background: "#fff", borderRadius: 12, padding: "28px 32px",
           width: "100%", maxWidth: 580, maxHeight: "90vh", overflowY: "auto",
           boxShadow: "0 20px 60px rgba(0,0,0,.25)" },
  input: { width: "100%", padding: "8px 10px", border: "1px solid #D1D5DB",
           borderRadius: 6, fontSize: 14, boxSizing: "border-box" },
  label: { display: "block", fontSize: 13, fontWeight: 600,
           color: "#374151", marginBottom: 4 },
  fila:  { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14,
           marginBottom: 14 },
  errBox: { background: "#FEE2E2", color: "#991B1B", borderRadius: 6,
            padding: "8px 12px", fontSize: 13, marginBottom: 12 },
};

const VACÍO = {
  identificacion_jugador: "", nombre_jugador: "", apellido_jugador: "",
  fecha_nacimiento: "", posicion: "",
  cedula_acudiente: "", nombre_acudiente: "", apellido_acudiente: "",
  telefono_acudiente: "", parentesco: "",
};

const POSICIONES  = ["Portero", "Defensa", "Mediocampista", "Delantero"];
const PARENTESCOS = ["Padre","Madre","Hermano","Hermana","Tío","Tía",
                     "Abuelo","Abuela","Tutor legal"];

function Campo({ label, children }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={S.label}>{label}</label>
      {children}
    </div>
  );
}

function JugadoresPage() {
  const [jugadores, setJugadores]   = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [cargando, setCargando]     = useState(true);
  const [error, setError]           = useState("");
  const [modal, setModal]           = useState(null);
  const [form, setForm]             = useState(VACÍO);
  const [guardando, setGuardando]   = useState(false);
  const [formError, setFormError]   = useState("");
  const [busqueda, setBusqueda]     = useState("");

  // ── Permisos ──────────────────────────────────────────────────
  const user    = JSON.parse(localStorage.getItem("ft_user") || "{}");
  const esAdmin = user.tipo_usuario === "admin";

  // ── Cargar ────────────────────────────────────────────────────
  const cargar = useCallback(async () => {
    setCargando(true);
    setError("");
    try {
      const params = (!esAdmin && user.id_categoria)
        ? `?id_categoria=${user.id_categoria}` : "";
      const [j, c] = await Promise.all([
        jugadoresApi.listar(params),
        catalogosApi.categorias(),
      ]);
      setJugadores(j);
      setCategorias(c);
    } catch (err) {
      setError(err.message);
    } finally {
      setCargando(false);
    }
  }, [esAdmin, user.id_categoria]);

  useEffect(() => { cargar(); }, [cargar]);

  // ── Filtro búsqueda ───────────────────────────────────────────
  const filtrados = jugadores.filter((j) => {
    const q = busqueda.toLowerCase();
    return (
      j.nombre?.toLowerCase().includes(q) ||
      j.apellido?.toLowerCase().includes(q) ||
      j.identificacion_jugador?.includes(q) ||
      j.categoria?.toLowerCase().includes(q)
    );
  });

  // ── Modal ─────────────────────────────────────────────────────
  function abrirCrear() { setForm(VACÍO); setFormError(""); setModal("crear"); }

  function abrirEditar(j) {
    setForm({
      identificacion_jugador: j.identificacion_jugador,
      nombre_jugador:   j.nombre,
      apellido_jugador: j.apellido,
      fecha_nacimiento: j.fecha_nacimiento,
      posicion:         j.posicion,
      id_categoria:     String(j.id_categoria),
      cedula_acudiente:    j.cedula_acudiente    ?? "",
      nombre_acudiente:    j.nombre_acudiente    ?? "",
      apellido_acudiente:  j.apellido_acudiente  ?? "",
      telefono_acudiente:  j.telefono_acudiente  ?? "",
      parentesco:          j.parentesco          ?? "",
    });
    setFormError("");
    setModal("editar");
  }

  function cerrar() { setModal(null); }
  function setF(key, val) { setForm((f) => ({ ...f, [key]: val })); }

  // ── Guardar ───────────────────────────────────────────────────
  async function guardar() {
    setGuardando(true);
    setFormError("");

    if (modal === "crear") {
      const soloNumeros = /^\d+$/;
      const soloLetras  = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/;

      if (!soloNumeros.test(form.identificacion_jugador)) {
        setFormError("La identificación solo puede contener números.");
        setGuardando(false); return;
      }
      if (form.identificacion_jugador.length !== 10) {
        setFormError("La identificación debe tener exactamente 10 dígitos (Tarjeta de Identidad).");
        setGuardando(false); return;
      }
      if (!soloLetras.test(form.nombre_jugador) || form.nombre_jugador.trim().length < 2) {
        setFormError("El nombre solo puede contener letras y debe tener al menos 2 caracteres.");
        setGuardando(false); return;
      }
      if (!soloLetras.test(form.apellido_jugador) || form.apellido_jugador.trim().length < 2) {
        setFormError("El apellido solo puede contener letras y debe tener al menos 2 caracteres.");
        setGuardando(false); return;
      }
      if (!form.fecha_nacimiento) {
        setFormError("La fecha de nacimiento es obligatoria.");
        setGuardando(false); return;
      }
      if (!form.posicion) {
        setFormError("Selecciona una posición para el jugador.");
        setGuardando(false); return;
      }
      if (!soloNumeros.test(form.cedula_acudiente)) {
        setFormError("La cédula del acudiente solo puede contener números.");
        setGuardando(false); return;
      }
      if (form.cedula_acudiente.length < 6 || form.cedula_acudiente.length > 10) {
        setFormError("La cédula del acudiente debe tener entre 6 y 10 dígitos.");
        setGuardando(false); return;
      }
      if (!soloLetras.test(form.nombre_acudiente) || form.nombre_acudiente.trim().length < 2) {
        setFormError("El nombre del acudiente solo puede contener letras y debe tener al menos 2 caracteres.");
        setGuardando(false); return;
      }
      if (!soloLetras.test(form.apellido_acudiente) || form.apellido_acudiente.trim().length < 2) {
        setFormError("El apellido del acudiente solo puede contener letras y debe tener al menos 2 caracteres.");
        setGuardando(false); return;
      }
      if (!soloNumeros.test(form.telefono_acudiente)) {
        setFormError("El teléfono del acudiente solo puede contener números.");
        setGuardando(false); return;
      }
      if (form.telefono_acudiente.length !== 10) {
        setFormError("El teléfono del acudiente debe tener exactamente 10 dígitos.");
        setGuardando(false); return;
      }
      if (!form.parentesco) {
        setFormError("Selecciona el parentesco del acudiente.");
        setGuardando(false); return;
      }
    }

    try {
      if (modal === "crear") {
        await jugadoresApi.crear({ ...form });
      } else {
        await jugadoresApi.actualizar(form.identificacion_jugador, {
          nombre:             form.nombre_jugador,
          apellido:           form.apellido_jugador,
          fecha_nacimiento:   form.fecha_nacimiento,
          posicion:           form.posicion,
          id_categoria:       Number(form.id_categoria),
          nombre_acudiente:   form.nombre_acudiente,
          apellido_acudiente: form.apellido_acudiente,
          telefono_acudiente: form.telefono_acudiente,
          parentesco:         form.parentesco,
        });
      }
      cerrar();
      await cargar();
    } catch (err) {
      setFormError(err.message);
    } finally {
      setGuardando(false);
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────
  async function eliminar(cedula) {
    if (!window.confirm("¿Eliminar este jugador?")) return;
    try {
      await jugadoresApi.eliminar(cedula);
      await cargar();
    } catch (err) {
      alert(err.message);
    }
  }

  // ── Render ────────────────────────────────────────────────────
  return (
    <div>
      <div className="page-header">
        <div>
          <h2 className="page-title">Jugadores</h2>
          <p className="page-subtitle">Registro y gestión de jugadores</p>
        </div>
        {esAdmin && (
          <button className="btn btn--primary" onClick={abrirCrear}>
            + Nuevo jugador
          </button>
        )}
      </div>

      {/* Banner categoría — solo entrenador */}
      {!esAdmin && user.categoria_nombre && (
        <div style={{ background: "#EFF6FF", border: "1px solid #BFDBFE",
                      borderRadius: 8, padding: "8px 14px", marginBottom: 16,
                      fontSize: 13, color: "#1D4ED8", fontWeight: 600 }}>
          Mostrando jugadores de: {user.categoria_nombre}
        </div>
      )}

      {/* Buscador */}
      <div style={{ marginBottom: 16 }}>
        <input style={{ ...S.input, maxWidth: 320 }}
          placeholder="Buscar por nombre o cédula"
          value={busqueda}
          onChange={(e) => setBusqueda(e.target.value)} />
      </div>

      {error && <div style={S.errBox}>⚠ {error}</div>}

      {cargando ? (
        <p style={{ color: "#6B7280" }}>Cargando jugadores…</p>
      ) : (
        <div style={{ overflowX: "auto", borderRadius: 10, border: "1px solid #E5E7EB" }}>
          <table style={S.tabla}>
            <thead>
              <tr>
                {[
                  "Cédula", "Nombre", "Posición", "Categoría",
                  "Asistencia", "Acudiente",
                  ...(esAdmin ? ["Acciones"] : []),
                ].map((h) => <th key={h} style={S.th}>{h}</th>)}
              </tr>
            </thead>
            <tbody>
              {filtrados.length === 0 ? (
                <tr>
                  <td colSpan={esAdmin ? 7 : 6}
                    style={{ ...S.td, textAlign: "center", color: "#9CA3AF" }}>
                    Sin jugadores registrados
                  </td>
                </tr>
              ) : filtrados.map((j) => (
                <tr key={j.identificacion_jugador}>
                  <td style={S.td}>{j.identificacion_jugador}</td>
                  <td style={S.td}>{j.nombre} {j.apellido}</td>
                  <td style={S.td}>{j.posicion}</td>
                  <td style={S.td}>{j.categoria}</td>
                  <td style={S.td}>
                    <span style={S.badge(j.pct_asistencia)}>
                      {j.pct_asistencia != null ? `${j.pct_asistencia}%` : "—"}
                    </span>
                  </td>
                  <td style={S.td}>
                    {j.nombre_acudiente
                      ? `${j.nombre_acudiente} ${j.apellido_acudiente} (${j.parentesco})`
                      : "—"}
                  </td>
                  {/* Columna Acciones — solo admin */}
                  {esAdmin && (
                    <td style={S.td}>
                      <button className="btn btn--secondary btn--sm"
                        style={{ marginRight: 6 }} onClick={() => abrirEditar(j)}>
                        Editar
                      </button>
                      <button className="btn btn--danger btn--sm"
                        onClick={() => eliminar(j.identificacion_jugador)}>
                        Eliminar
                      </button>
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal — solo admin */}
      {modal && esAdmin && (
        <div style={S.overlay}
          onClick={(e) => e.target === e.currentTarget && cerrar()}>
          <div style={S.modal}>
            <h3 style={{ marginBottom: 20, color: "#1A3C6E" }}>
              {modal === "crear" ? "Nuevo jugador" : "Editar jugador"}
            </h3>

            {formError && <div style={S.errBox}>{formError}</div>}

            <p style={{ fontWeight: 700, color: "#374151", marginBottom: 10 }}>
              Datos del jugador
            </p>
            <div style={S.fila}>
              <Campo label="Cédula">
                <input style={S.input} value={form.identificacion_jugador}
                  readOnly={modal === "editar"}
                  onChange={(e) => setF("identificacion_jugador", e.target.value)} />
              </Campo>
              <Campo label="Fecha de nacimiento">
                <input style={S.input} type="date" value={form.fecha_nacimiento}
                  onChange={(e) => setF("fecha_nacimiento", e.target.value)} />
              </Campo>
            </div>
            <div style={S.fila}>
              <Campo label="Nombre">
                <input style={S.input} value={form.nombre_jugador}
                  onChange={(e) => setF("nombre_jugador", e.target.value)} />
              </Campo>
              <Campo label="Apellido">
                <input style={S.input} value={form.apellido_jugador}
                  onChange={(e) => setF("apellido_jugador", e.target.value)} />
              </Campo>
            </div>
            <div style={S.fila}>
              <Campo label="Posición">
                <select style={S.input} value={form.posicion}
                  onChange={(e) => setF("posicion", e.target.value)}>
                  <option value="">Selecciona…</option>
                  {POSICIONES.map((p) => <option key={p} value={p}>{p}</option>)}
                </select>
              </Campo>
              {modal === "editar" && (
                <Campo label="Categoría">
                  <select style={S.input} value={form.id_categoria}
                    onChange={(e) => setF("id_categoria", e.target.value)}>
                    <option value="">Selecciona…</option>
                    {categorias.map((c) => (
                      <option key={c.id_categoria} value={c.id_categoria}>
                        {c.nombre} ({c.rango_edad_min}–{c.rango_edad_max} años)
                      </option>
                    ))}
                  </select>
                </Campo>
              )}
            </div>

            <p style={{ fontWeight: 700, color: "#374151", margin: "16px 0 10px" }}>
              Datos del acudiente
            </p>
            <div style={S.fila}>
              <Campo label="Cédula acudiente">
                <input style={S.input} value={form.cedula_acudiente}
                  readOnly={modal === "editar"}
                  onChange={(e) => setF("cedula_acudiente", e.target.value)} />
              </Campo>
              <Campo label="Parentesco">
                <select style={S.input} value={form.parentesco}
                  onChange={(e) => setF("parentesco", e.target.value)}>
                  <option value="">Selecciona…</option>
                  {PARENTESCOS.map((p) => <option key={p} value={p}>{p}</option>)}
                </select>
              </Campo>
            </div>
            <div style={S.fila}>
              <Campo label="Nombre acudiente">
                <input style={S.input} value={form.nombre_acudiente}
                  onChange={(e) => setF("nombre_acudiente", e.target.value)} />
              </Campo>
              <Campo label="Apellido acudiente">
                <input style={S.input} value={form.apellido_acudiente}
                  onChange={(e) => setF("apellido_acudiente", e.target.value)} />
              </Campo>
            </div>
            <Campo label="Teléfono acudiente">
              <input style={S.input} value={form.telefono_acudiente}
                onChange={(e) => setF("telefono_acudiente", e.target.value)} />
            </Campo>

            <div style={{ display: "flex", justifyContent: "flex-end",
                          gap: 10, marginTop: 20 }}>
              <button className="btn btn--secondary" onClick={cerrar}
                disabled={guardando}>Cancelar</button>
              <button className="btn btn--primary" onClick={guardar}
                disabled={guardando}>
                {guardando ? "Guardando…" : "Guardar"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default JugadoresPage;