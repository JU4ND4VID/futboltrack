// src/pages/asistencia/AsistenciaPage.jsx
import { useState, useEffect, useCallback } from 'react'
import { asistenciaApi, entrenamientosApi } from '../../api/api'

const S = {
  select:  { padding: '8px 12px', border: '1px solid #D1D5DB', borderRadius: 6,
             fontSize: 14, minWidth: 260, background: '#fff' },
  tabla:   { width: '100%', borderCollapse: 'collapse', fontSize: 14 },
  th:      { padding: '10px 12px', background: '#1A3C6E', color: '#fff',
             textAlign: 'left', fontWeight: 600, fontSize: 13 },
  td:      { padding: '9px 12px', borderBottom: '1px solid #E5E7EB',
             verticalAlign: 'middle' },
  badge:   (estado) => ({
             display: 'inline-block', padding: '3px 10px', borderRadius: 12,
             fontSize: 12, fontWeight: 700,
             background: estado === 'presente'    ? '#DCFCE7'
                       : estado === 'justificado' ? '#FEF9C3'
                       :                           '#FEE2E2',
             color:      estado === 'presente'    ? '#15803D'
                       : estado === 'justificado' ? '#92400E'
                       :                           '#991B1B',
           }),
  errBox:  { background: '#FEE2E2', color: '#991B1B', borderRadius: 6,
             padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  okBox:   { background: '#DCFCE7', color: '#15803D', borderRadius: 6,
             padding: '8px 12px', fontSize: 13, marginBottom: 12 },
}

const ESTADOS = ['presente', 'ausente', 'justificado']

function AsistenciaPage() {
  const [entrenamientos, setEntrenamientos] = useState([])
  const [idSeleccionado, setIdSeleccionado] = useState('')
  const [asistencia, setAsistencia]         = useState([])
  const [ediciones, setEdiciones]           = useState({})
  const [editando, setEditando]             = useState(false)
  const [cargandoLista, setCargandoLista]   = useState(true)
  const [cargandoAsis, setCargandoAsis]     = useState(false)
  const [guardando, setGuardando]           = useState(false)
  const [error, setError]                   = useState('')
  const [exito, setExito]                   = useState('')

  const user = JSON.parse(localStorage.getItem('ft_user') || '{}')
  const esAdmin = user.tipo_usuario === 'admin'

  useEffect(() => {
    entrenamientosApi.listar()
      .then(data => setEntrenamientos(data))
      .catch(err => setError(err.message))
      .finally(() => setCargandoLista(false))
  }, [])

  const cargarAsistencia = useCallback(async (id) => {
    if (!id) return
    setCargandoAsis(true)
    setError('')
    setExito('')
    setEditando(false)
    setEdiciones({})
    try {
      const data = await asistenciaApi.listar(id)
      setAsistencia(data)
    } catch (err) {
      setError(err.message)
      setAsistencia([])
    } finally {
      setCargandoAsis(false)
    }
  }, [])

  function handleSeleccion(e) {
    const id = e.target.value
    setIdSeleccionado(id)
    cargarAsistencia(id)
  }

  function iniciarEdicion() {
    const init = {}
    asistencia.forEach(j => { init[j.identificacion_jugador] = j.estado_asistencia })
    setEdiciones(init)
    setEditando(true)
  }

  function cancelar() {
    setEditando(false)
    setEdiciones({})
  }

  function cambiarEstado(identificacion, nuevoEstado) {
    setEdiciones(prev => ({ ...prev, [identificacion]: nuevoEstado }))
  }

  function marcarTodos(estado) {
    const next = {}
    asistencia.forEach(j => { next[j.identificacion_jugador] = estado })
    setEdiciones(next)
  }

  async function guardar() {
    if (!idSeleccionado) return
    setGuardando(true)
    setError('')
    setExito('')
    try {
      const payload = Object.entries(ediciones).map(([identificacion_jugador, estado_asistencia]) => ({
        identificacion_jugador,
        estado_asistencia,
      }))
      await asistenciaApi.registrar(Number(idSeleccionado), payload)
      setExito('Asistencia registrada correctamente.')
      setEditando(false)
      await cargarAsistencia(idSeleccionado)
    } catch (err) {
      setError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  const estadosVista = editando ? ediciones : Object.fromEntries(
    asistencia.map(j => [j.identificacion_jugador, j.estado_asistencia])
  )

  const resumen = {
    total:        asistencia.length,
    presentes:    Object.values(estadosVista).filter(e => e === 'presente').length,
    ausentes:     Object.values(estadosVista).filter(e => e === 'ausente').length,
    justificados: Object.values(estadosVista).filter(e => e === 'justificado').length,
  }

  const entSeleccionado = entrenamientos.find(
    e => String(e.id_entrenamiento) === idSeleccionado
  )

  return (
    <div>
      <div className="page-header">
        <div>
          <h2 className="page-title">Asistencia</h2>
          <p className="page-subtitle">Registra la asistencia por sesión de entrenamiento</p>
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
        <label style={{ fontWeight: 600, fontSize: 14, color: '#374151' }}>Sesión:</label>
        {cargandoLista ? (
          <span style={{ color: '#6B7280', fontSize: 14 }}>Cargando sesiones…</span>
        ) : (
          <select style={S.select} value={idSeleccionado} onChange={handleSeleccion}>
            <option value="">— Selecciona una sesión —</option>
            {entrenamientos.map(e => (
              <option key={e.id_entrenamiento} value={e.id_entrenamiento}>
                #{e.id_entrenamiento} · {e.fecha} · {e.tipo} · {e.categoria_nombre} [{e.estado}]
              </option>
            ))}
          </select>
        )}
      </div>

      {error && <div style={S.errBox}>⚠ {error}</div>}
      {exito && <div style={S.okBox}>✓ {exito}</div>}

      {entSeleccionado && (
        <div style={{ background: '#F0F4FF', borderRadius: 8, padding: '12px 16px',
                      marginBottom: 16, fontSize: 14, color: '#1A3C6E' }}>
          <strong>{entSeleccionado.tipo}</strong> — {entSeleccionado.lugar_nombre} —{' '}
          {entSeleccionado.hora_inicio} a {entSeleccionado.hora_fin} —{' '}
          Entrenador: {entSeleccionado.entrenador_nombre}
        </div>
      )}

      {cargandoAsis ? (
        <p style={{ color: '#6B7280' }}>Cargando jugadores…</p>
      ) : idSeleccionado && asistencia.length === 0 ? (
        <p style={{ color: '#6B7280' }}>No hay jugadores registrados para esta sesión.</p>
      ) : asistencia.length > 0 ? (
        <>
          {/* Resumen */}
          <div style={{ display: 'flex', gap: 12, marginBottom: 16, flexWrap: 'wrap' }}>
            {[
              { label: 'Total',        val: resumen.total,        bg: '#E0E7FF', color: '#3730A3' },
              { label: 'Presentes',    val: resumen.presentes,    bg: '#DCFCE7', color: '#15803D' },
              { label: 'Ausentes',     val: resumen.ausentes,     bg: '#FEE2E2', color: '#991B1B' },
              { label: 'Justificados', val: resumen.justificados, bg: '#FEF9C3', color: '#92400E' },
            ].map(r => (
              <div key={r.label} style={{ background: r.bg, color: r.color, borderRadius: 8,
                                          padding: '8px 16px', fontWeight: 700, fontSize: 14 }}>
                {r.val} {r.label}
              </div>
            ))}
          </div>

          {/* Botón editar (solo en modo ver) */}
          {!editando && !esAdmin && (
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: 12 }}>
              <button className="btn btn--primary btn--sm" onClick={iniciarEdicion}>
                Editar asistencia
              </button>
            </div>
          )}

          {/* Marcar todos (solo en modo editar) */}
          {editando && (
            <div style={{ display: 'flex', gap: 8, marginBottom: 12, flexWrap: 'wrap' }}>
              <span style={{ fontSize: 13, color: '#6B7280', lineHeight: '30px' }}>Marcar todos:</span>
              {ESTADOS.map(e => (
                <button key={e} className="btn btn--secondary btn--sm"
                  onClick={() => marcarTodos(e)}>
                  {e}
                </button>
              ))}
            </div>
          )}

          <div style={{ overflowX: 'auto', borderRadius: 10, border: '1px solid #E5E7EB' }}>
            <table style={S.tabla}>
              <thead>
                <tr>
                  {['Cédula', 'Nombre', 'Estado asistencia'].map(h => (
                    <th key={h} style={S.th}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {asistencia.map(j => {
                  const est = estadosVista[j.identificacion_jugador] ?? j.estado_asistencia
                  return (
                    <tr key={j.identificacion_jugador}>
                      <td style={S.td}>{j.identificacion_jugador}</td>
                      <td style={S.td}>{j.nombre} {j.apellido}</td>
                      <td style={S.td}>
                        {editando ? (
                          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                            <span style={S.badge(est)}>{est}</span>
                            <select
                              style={{ padding: '4px 8px', border: '1px solid #D1D5DB',
                                       borderRadius: 6, fontSize: 13 }}
                              value={est}
                              onChange={e => cambiarEstado(j.identificacion_jugador, e.target.value)}
                            >
                              {ESTADOS.map(s => <option key={s} value={s}>{s}</option>)}
                            </select>
                          </div>
                        ) : (
                          <span style={S.badge(est)}>{est}</span>
                        )}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>

          {editando && (
            <div style={{ marginTop: 16, display: 'flex', justifyContent: 'flex-end', gap: 8 }}>
              <button className="btn btn--secondary" onClick={cancelar} disabled={guardando}>
                Cancelar
              </button>
              <button className="btn btn--primary" onClick={guardar} disabled={guardando}>
                {guardando ? 'Guardando…' : 'Guardar asistencia'}
              </button>
            </div>
          )}
        </>
      ) : null}
    </div>
  )
}

export default AsistenciaPage