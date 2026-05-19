// src/pages/entrenamientos/EntrenamientosPage.jsx
import { useState, useEffect, useCallback } from 'react'
import { entrenamientosApi, catalogosApi } from '../../api/api'

const S = {
  tabla:  { width: '100%', borderCollapse: 'collapse', fontSize: 14 },
  th:     { padding: '10px 12px', background: '#1A3C6E', color: '#fff',
            textAlign: 'left', fontWeight: 600, fontSize: 13 },
  td:     { padding: '9px 12px', borderBottom: '1px solid #E5E7EB',
            verticalAlign: 'middle' },
  badge:  (estado) => ({
            display: 'inline-block', padding: '3px 10px', borderRadius: 12,
            fontSize: 12, fontWeight: 700,
            background: estado === 'programado' ? '#DBEAFE'
                      : estado === 'realizado'  ? '#DCFCE7'
                      :                           '#FEE2E2',
            color:      estado === 'programado' ? '#1D4ED8'
                      : estado === 'realizado'  ? '#15803D'
                      :                           '#991B1B',
          }),
  overlay: { position: 'fixed', inset: 0, background: 'rgba(0,0,0,.45)',
             display: 'flex', alignItems: 'center', justifyContent: 'center',
             zIndex: 1000 },
  modal:   { background: '#fff', borderRadius: 12, padding: '28px 32px',
             width: '100%', maxWidth: 540, maxHeight: '90vh', overflowY: 'auto',
             boxShadow: '0 20px 60px rgba(0,0,0,.25)' },
  input:   { width: '100%', padding: '8px 10px', border: '1px solid #D1D5DB',
             borderRadius: 6, fontSize: 14, boxSizing: 'border-box' },
  label:   { display: 'block', fontSize: 13, fontWeight: 600,
             color: '#374151', marginBottom: 4 },
  fila:    { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14,
             marginBottom: 14 },
  errBox:  { background: '#FEE2E2', color: '#991B1B', borderRadius: 6,
             padding: '8px 12px', fontSize: 13, marginBottom: 12 },
}

// Modal de confirmación personalizado
function ModalConfirm({ mensaje, onSi, onNo }) {
  return (
    <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,.5)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  zIndex: 2000 }}>
      <div style={{ background: '#fff', borderRadius: 12, padding: '28px 32px',
                    maxWidth: 400, width: '100%', boxShadow: '0 20px 60px rgba(0,0,0,.3)' }}>
        <p style={{ fontSize: 15, color: '#374151', marginBottom: 24,
                    fontWeight: 500, textAlign: 'center' }}>
          {mensaje}
        </p>
        <div style={{ display: 'flex', justifyContent: 'center', gap: 12 }}>
          <button className="btn btn--secondary" onClick={onNo}>Cancelar</button>
          <button className="btn btn--danger"    onClick={onSi}>Confirmar</button>
        </div>
      </div>
    </div>
  )
}

const VACÍO = {
  fecha: '', hora_inicio: '', hora_fin: '',
  tipo: '', id_lugar: '',
}

const TIPOS = ['Físico', 'Táctico', 'Técnico', 'Mixto']

const HORAS_INICIO = Array.from({ length: 16 }, (_, i) => {
  const h = i + 6
  return `${String(h).padStart(2, '0')}:00`
})

function minutosDesdeHora(hora = '') {
  const [h, m] = String(hora).split(':').map(Number)
  if (!Number.isFinite(h) || !Number.isFinite(m)) return null
  return h * 60 + m
}

function calcularDuracionMinutos(horaInicio, horaFin) {
  const inicio = minutosDesdeHora(horaInicio)
  const fin = minutosDesdeHora(horaFin)
  if (inicio === null || fin === null || fin <= inicio) return null
  return fin - inicio
}

function calcularDuracionHoras(horaInicio, horaFin) {
  const minutos = calcularDuracionMinutos(horaInicio, horaFin)
  if (!minutos) return null
  return minutos / 60
}

function formatearDuracion(minutos) {
  if (!minutos) return ''
  const horas = minutos / 60
  return `${horas} hora${horas === 1 ? '' : 's'}`
}

function opcionesHoraFin(horaInicio) {
  if (!horaInicio) return []
  const [h] = horaInicio.split(':').map(Number)
  return [h + 1, h + 2]
    .filter(fin => fin <= 22)
    .map(fin => `${String(fin).padStart(2, '0')}:00`)
}

function Campo({ label, children }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={S.label}>{label}</label>
      {children}
    </div>
  )
}

function EntrenamientosPage() {
  const [entrenamientos, setEntrenamientos] = useState([])
  const [lugares, setLugares]               = useState([])
  const [cargando, setCargando]             = useState(true)
  const [error, setError]                   = useState('')
  const [modal, setModal]                   = useState(false)
  const [form, setForm]                     = useState(VACÍO)
  const [guardando, setGuardando]           = useState(false)
  const [formError, setFormError]           = useState('')
  const [filtroEstado, setFiltroEstado]     = useState('todos')
  const [busqueda, setBusqueda]             = useState('')
  const [confirm, setConfirm]               = useState(null) // { mensaje, onSi }

  // ── Permisos ──────────────────────────────────────────────────
  const user    = JSON.parse(localStorage.getItem('ft_user') || '{}')
  const esAdmin = user.tipo_usuario === 'admin'

  const cargar = useCallback(async () => {
    setCargando(true)
    setError('')
    try {
      const [e, l] = await Promise.all([
        entrenamientosApi.listar(),
        catalogosApi.lugares(),
      ])
      // Ordenar por id_entrenamiento ascendente (punto 3)
      setEntrenamientos(e)
      setLugares(l)
    } catch (err) {
      setError(err.message)
    } finally {
      setCargando(false)
    }
  }, [])

  useEffect(() => { cargar() }, [cargar])

  // ── Filtros ───────────────────────────────────────────────────
  const filtrados = entrenamientos.filter(e => {
    const porEstado  = filtroEstado === 'todos' || e.estado === filtroEstado
    const q          = busqueda.toLowerCase()
    const porBusqueda = !busqueda || (
      e.tipo?.toLowerCase().includes(q) ||
      e.categoria_nombre?.toLowerCase().includes(q) ||
      e.lugar_nombre?.toLowerCase().includes(q) ||
      e.entrenador_nombre?.toLowerCase().includes(q) ||
      e.fecha?.includes(q) ||
      String(e.id_entrenamiento).includes(q)
    )
    return porEstado && porBusqueda
  })

  function setF(key, val) { setForm(f => ({ ...f, [key]: val })) }

  function cambiarHoraInicio(val) {
    setForm(f => ({ ...f, hora_inicio: val, hora_fin: '' }))
  }

  // ── Confirmar acción personalizada ────────────────────────────
  function pedirConfirm(mensaje, accion) {
    setConfirm({ mensaje, onSi: () => { setConfirm(null); accion() } })
  }

  // ── Guardar ───────────────────────────────────────────────────
  async function guardar() {
    setGuardando(true)
    setFormError('')
    try {
      if (!user.id_categoria) {
        setFormError('No se pudo obtener tu categoría. Vuelve a iniciar sesión.')
        setGuardando(false)
        return
      }
      const duracionHoras = calcularDuracionHoras(form.hora_inicio, form.hora_fin)
      if (![1, 2].includes(duracionHoras)) {
        setFormError('La duración del entrenamiento debe ser de 1 o 2 horas.')
        setGuardando(false)
        return
      }

      const payload = {
        ...form,
        cedula_entrenador: user.cedula,
        id_categoria:      user.id_categoria,
        id_lugar:          Number(form.id_lugar),
      }
      await entrenamientosApi.crear(payload)
      setModal(false)
      await cargar()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  // ── Cambiar estado ────────────────────────────────────────────
  function handleCambiarEstado(id, estado) {
    pedirConfirm(
      `¿Marcar este entrenamiento como "${estado}"?`,
      () => entrenamientosApi.actualizarEstado(id, estado)
              .then(cargar)
              .catch(err => alert(err.message))
    )
  }

  // ── Eliminar ──────────────────────────────────────────────────
  function handleEliminar(id) {
    pedirConfirm(
      '¿Estás seguro de que deseas eliminar este entrenamiento? Esta acción no se puede deshacer.',
      () => entrenamientosApi.eliminar(id)
              .then(cargar)
              .catch(err => alert(err.message))
    )
  }

  const horasFin = opcionesHoraFin(form.hora_inicio)
  const duracionSeleccionada = calcularDuracionMinutos(form.hora_inicio, form.hora_fin)

  // Columnas según rol
  const columnas = ['#', 'Fecha', 'Horario', 'Tipo', 'Categoría', 'Lugar',
                    'Entrenador', 'Estado', ...(!esAdmin ? ['Acciones'] : [])]

  return (
    <div>
      {/* Modal de confirmación personalizado */}
      {confirm && (
        <ModalConfirm
          mensaje={confirm.mensaje}
          onSi={confirm.onSi}
          onNo={() => setConfirm(null)}
        />
      )}

      <div className="page-header">
        <div>
          <h2 className="page-title">Entrenamientos</h2>
          <p className="page-subtitle">Gestión de sesiones programadas</p>
        </div>
        {/* Botón crear — solo entrenadores, no admin */}
        {!esAdmin && (
          <button className="btn btn--primary"
            onClick={() => { setForm(VACÍO); setFormError(''); setModal(true) }}>
            + Nuevo entrenamiento
          </button>
        )}
      </div>

      {/* Filtros */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
        {['todos', 'programado', 'realizado', 'cancelado'].map(e => (
          <button key={e}
            className={`btn btn--sm ${filtroEstado === e ? 'btn--primary' : 'btn--secondary'}`}
            onClick={() => setFiltroEstado(e)}>
            {e.charAt(0).toUpperCase() + e.slice(1)}
          </button>
        ))}
      </div>

      {/* Buscador (punto 7) */}
      <div style={{ marginBottom: 16 }}>
        <input style={{ ...S.input, maxWidth: 360 }}
          placeholder="Buscar por tipo, categoría, lugar, entrenador o fecha…"
          value={busqueda}
          onChange={e => setBusqueda(e.target.value)} />
      </div>

      {error && <div style={S.errBox}>⚠ {error}</div>}

      {cargando ? (
        <p style={{ color: '#6B7280' }}>Cargando entrenamientos…</p>
      ) : (
        <div style={{ overflowX: 'auto', borderRadius: 10, border: '1px solid #E5E7EB' }}>
          <table style={S.tabla}>
            <thead>
              <tr>
                {columnas.map(h => <th key={h} style={S.th}>{h}</th>)}
              </tr>
            </thead>
            <tbody>
              {filtrados.length === 0 ? (
                <tr><td colSpan={columnas.length}
                  style={{ ...S.td, textAlign: 'center', color: '#9CA3AF' }}>
                  Sin entrenamientos
                </td></tr>
              ) : filtrados.map(e => (
                <tr key={e.id_entrenamiento}>
                  <td style={S.td}>{e.id_entrenamiento}</td>
                  <td style={S.td}>{e.fecha}</td>
                  <td style={S.td}>{e.hora_inicio} – {e.hora_fin}</td>
                  <td style={S.td}>{e.tipo}</td>
                  <td style={S.td}>{e.categoria_nombre}</td>
                  <td style={S.td}>{e.lugar_nombre}</td>
                  <td style={S.td}>{e.entrenador_nombre}</td>
                  <td style={S.td}>
                    <span style={S.badge(e.estado)}>{e.estado}</span>
                  </td>
                  {/* Acciones — solo entrenadores, oculto para admin (punto 4) */}
                  {!esAdmin && (
                    <td style={S.td}>
                      {e.estado === 'programado' &&
                       e.cedula_entrenador === user.cedula && (
                        <button className="btn btn--secondary btn--sm"
                          style={{ marginRight: 6 }}
                          onClick={() => handleCambiarEstado(e.id_entrenamiento, 'realizado')}>
                          Marcar realizado
                        </button>
                      )}
                      {e.estado !== 'realizado' &&
                       e.cedula_entrenador === user.cedula && (
                        <button className="btn btn--danger btn--sm"
                          onClick={() => handleEliminar(e.id_entrenamiento)}>
                          Eliminar
                        </button>
                      )}
                      {e.cedula_entrenador !== user.cedula && (
                        <span style={{ fontSize: 12, color: '#9CA3AF' }}>
                          Sin permisos
                        </span>
                      )}
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal crear — solo entrenadores */}
      {modal && !esAdmin && (
        <div style={S.overlay} onClick={e => e.target === e.currentTarget && setModal(false)}>
          <div style={S.modal}>
            <h3 style={{ marginBottom: 20, color: '#1A3C6E' }}>Nuevo entrenamiento</h3>

            {formError && <div style={S.errBox}>{formError}</div>}

            <div style={S.fila}>
              <Campo label="Fecha">
                <input style={S.input} type="date" value={form.fecha}
                  onChange={e => setF('fecha', e.target.value)} />
              </Campo>
              <Campo label="Tipo">
                <select style={S.input} value={form.tipo}
                  onChange={e => setF('tipo', e.target.value)}>
                  <option value="">Selecciona…</option>
                  {TIPOS.map(t => <option key={t} value={t}>{t}</option>)}
                </select>
              </Campo>
            </div>

            <div style={S.fila}>
              <Campo label="Hora inicio">
                <select style={S.input} value={form.hora_inicio}
                  onChange={e => cambiarHoraInicio(e.target.value)}>
                  <option value="">Selecciona…</option>
                  {HORAS_INICIO.map(h => <option key={h} value={h}>{h}</option>)}
                </select>
              </Campo>
              <Campo label="Hora fin">
                <select style={S.input} value={form.hora_fin}
                  onChange={e => setF('hora_fin', e.target.value)}
                  disabled={!form.hora_inicio}>
                  <option value="">
                    {form.hora_inicio ? 'Selecciona…' : 'Primero elige inicio'}
                  </option>
                  {horasFin.map(h => {
                    const duracion = calcularDuracionMinutos(form.hora_inicio, h)
                    return <option key={h} value={h}>{h} ({formatearDuracion(duracion)})</option>
                  })}
                </select>
              </Campo>
            </div>

            {duracionSeleccionada && (
              <div style={{ background: '#F0FDF4', color: '#166534', borderRadius: 8,
                            padding: '10px 12px', fontSize: 13, fontWeight: 600,
                            marginBottom: 14 }}>
                Duración: {formatearDuracion(duracionSeleccionada)}
              </div>
            )}

            <div style={S.fila}>
              <Campo label="Lugar">
                <select style={S.input} value={form.id_lugar}
                  onChange={e => setF('id_lugar', e.target.value)}>
                  <option value="">Selecciona…</option>
                  {lugares.map(l => (
                    <option key={l.id_lugar} value={l.id_lugar}>{l.nombre}</option>
                  ))}
                </select>
              </Campo>
              <Campo label="Categoría">
                <div style={{ padding: '8px 10px', background: '#F9FAFB',
                              border: '1px solid #E5E7EB', borderRadius: 6,
                              fontSize: 14, color: '#374151' }}>
                  {user.categoria_nombre || 'Cargando…'}
                </div>
              </Campo>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 20 }}>
              <button className="btn btn--secondary"
                onClick={() => setModal(false)} disabled={guardando}>
                Cancelar
              </button>
              <button className="btn btn--primary"
                onClick={guardar} disabled={guardando}>
                {guardando ? 'Guardando…' : 'Crear entrenamiento'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default EntrenamientosPage