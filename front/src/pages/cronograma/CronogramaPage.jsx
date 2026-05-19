// src/pages/cronograma/CronogramaPage.jsx
import { useState, useEffect, useCallback } from 'react'
import FullCalendar from '@fullcalendar/react'
import dayGridPlugin from '@fullcalendar/daygrid'
import interactionPlugin from '@fullcalendar/interaction'
import esLocale from '@fullcalendar/core/locales/es'
import { entrenamientosApi } from '../../api/api'
import './CronogramaPage.css'

const COLORES_ESTADO = {
  programado: { bg: '#1A3C6E', text: '#ffffff' },
  realizado:  { bg: '#16A34A', text: '#ffffff' },
  cancelado:  { bg: '#DC2626', text: '#ffffff' },
}

const BADGES_ESTADO = {
  programado: 'badge--azul',
  realizado:  'badge--verde',
  cancelado:  'badge--rojo',
}

const ESTADOS_VALIDOS = ['programado', 'realizado', 'cancelado']

function CronogramaPage() {
  const [entrenamientos, setEntrenamientos]         = useState([])
  const [sesionSeleccionada, setSesionSeleccionada] = useState(null)
  const [cargando, setCargando]                     = useState(true)
  const [error, setError]                           = useState('')
  const [accion, setAccion]                         = useState('')   // mensaje de feedback

  // ── Leer usuario en sesión ────────────────────────────────────
  const user    = JSON.parse(localStorage.getItem('ft_user') || '{}')
  const esAdmin = user.tipo_usuario === 'admin'

   const puedeModificar = sesionSeleccionada && (
    esAdmin ||
    sesionSeleccionada.cedula_entrenador === user.cedula
  )
  // ── Cargar entrenamientos ─────────────────────────────────────
  const cargar = useCallback(async () => {
    setCargando(true)
    setError('')
    try {
      const data = await entrenamientosApi.listar()
      setEntrenamientos(data)
    } catch (err) {
      setError(err.message)
    } finally {
      setCargando(false)
    }
  }, [])

  useEffect(() => { cargar() }, [cargar])

  // ── Mapear a formato FullCalendar ─────────────────────────────
  const eventos = entrenamientos.map(e => ({
    id:    String(e.id_entrenamiento),
    title: `${e.tipo} · ${e.categoria_nombre}`,
    date:  e.fecha,
    backgroundColor: COLORES_ESTADO[e.estado]?.bg   ?? '#6B7280',
    borderColor:     COLORES_ESTADO[e.estado]?.bg   ?? '#6B7280',
    textColor:       COLORES_ESTADO[e.estado]?.text ?? '#ffffff',
    extendedProps: e,
  }))

  function handleEventClick(info) {
    setSesionSeleccionada({ ...info.event.extendedProps, id: info.event.id })
    setAccion('')
  }

  function cerrarPanel() {
    setSesionSeleccionada(null)
    setAccion('')
  }

  // ── Cambiar estado ────────────────────────────────────────────
  async function cambiarEstado(nuevoEstado) {
    if (!sesionSeleccionada) return
    const id = Number(sesionSeleccionada.id_entrenamiento)
    setAccion('Guardando…')
    try {
      await entrenamientosApi.actualizarEstado(id, nuevoEstado)
      setAccion(`Estado actualizado a "${nuevoEstado}"`)
      await cargar()
      // Actualizar el panel con la nueva info
      const actualizado = entrenamientos.find(e => e.id_entrenamiento === id)
      if (actualizado) setSesionSeleccionada({ ...actualizado, id: String(id) })
    } catch (err) {
      setAccion(`Error: ${err.message}`)
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────
  async function eliminar() {
    if (!sesionSeleccionada) return
    if (!window.confirm('¿Eliminar este entrenamiento? Esta acción no se puede deshacer.')) return
    const id = sesionSeleccionada.id_entrenamiento
    setAccion('Eliminando…')
    try {
      await entrenamientosApi.eliminar(id)
      setSesionSeleccionada(null)
      await cargar()
    } catch (err) {
      setAccion(`Error: ${err.message}`)
    }
  }

return (
  <div className="cronograma">

    {/* ── Encabezado ── */}
    <div className="page-header">
      <div>
        <h2 className="page-title">Cronograma</h2>
        <p className="page-subtitle">Sesiones de entrenamiento del mes</p>
      </div>
    </div>

    {/* ── Leyenda ── */}
    <div className="cronograma__leyenda">
      {Object.entries(COLORES_ESTADO).map(([estado, col]) => (
        <span key={estado} className="leyenda__item">
          <span className="leyenda__dot" style={{ background: col.bg }}></span>
          {estado.charAt(0).toUpperCase() + estado.slice(1)}
        </span>
      ))}
    </div>

    {/* ── Error global ── */}
    {error && (
      <div style={{ color: '#DC2626', marginBottom: 12 }}>⚠ {error}</div>
    )}

    {/* ── Layout: calendario + panel ── */}
    <div className={`cronograma__body ${sesionSeleccionada ? 'cronograma__body--split' : ''}`}>

      {/* Calendario */}
      <div className="cronograma__calendar">
        {cargando ? (
          <p style={{ padding: 24, color: '#6B7280' }}>Cargando entrenamientos…</p>
        ) : (
          <FullCalendar
            plugins={[dayGridPlugin, interactionPlugin]}
            initialView="dayGridMonth"
            locale={esLocale}
            events={eventos}
            eventClick={handleEventClick}
            headerToolbar={{
              left:   'prev,next today',
              center: 'title',
              right:  ''
            }}
            height="100%"
            eventDisplay="block"
          />
        )}
      </div>

      {/* Panel lateral de detalle */}
      {sesionSeleccionada && (
        <div className="cronograma__panel">
          <div className="panel__header">
            <h3 className="panel__title">Detalle de sesión</h3>
            <button className="panel__close" onClick={cerrarPanel}>✕</button>
          </div>

          <div className="panel__body">
            <h4 className="panel__nombre">
              {sesionSeleccionada.tipo} — {sesionSeleccionada.categoria_nombre}
            </h4>

            <span className={`badge ${BADGES_ESTADO[sesionSeleccionada.estado] ?? ''}`}>
              {sesionSeleccionada.estado}
            </span>

            <div className="panel__info">
              <div className="panel__fila">
                <span className="panel__etiqueta">Fecha</span>
                <span className="panel__valor">{sesionSeleccionada.fecha}</span>
              </div>
              <div className="panel__fila">
                <span className="panel__etiqueta">Horario</span>
                <span className="panel__valor">
                  {sesionSeleccionada.hora_inicio} – {sesionSeleccionada.hora_fin}
                </span>
              </div>
              <div className="panel__fila">
                <span className="panel__etiqueta">Lugar</span>
                <span className="panel__valor">{sesionSeleccionada.lugar_nombre}</span>
              </div>
              <div className="panel__fila">
                <span className="panel__etiqueta">Entrenador</span>
                <span className="panel__valor">{sesionSeleccionada.entrenador_nombre}</span>
              </div>
              <div className="panel__fila">
                <span className="panel__etiqueta">Sesiones cat.</span>
                <span className="panel__valor">{sesionSeleccionada.total_sesiones_categoria}</span>
              </div>
            </div>

            {/* ── Cambiar estado — solo si puede modificar ── */}
            {puedeModificar ? (
              <div style={{ marginTop: 12 }}>
                <p style={{ fontSize: 13, color: '#6B7280', marginBottom: 6 }}>
                  Cambiar estado:
                </p>
                <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                  {ESTADOS_VALIDOS.filter(e => e !== sesionSeleccionada.estado).map(e => (
                    <button key={e} className="btn btn--secondary btn--sm"
                      onClick={() => cambiarEstado(e)}>
                      → {e}
                    </button>
                  ))}
                </div>
              </div>
            ) : (
              <div style={{ marginTop: 12, padding: '8px 12px', background: '#F9FAFB',
                            border: '1px solid #E5E7EB', borderRadius: 6,
                            fontSize: 13, color: '#9CA3AF' }}>
                🔒 Solo el entrenador asignado puede modificar esta sesión.
              </div>
            )}

            {accion && (
              <p style={{ marginTop: 8, fontSize: 13, color: '#16A34A' }}>{accion}</p>
            )}

            {/* ── Eliminar — solo si puede modificar ── */}
            {puedeModificar && sesionSeleccionada.estado !== 'realizado' && (
              <div className="panel__acciones" style={{ marginTop: 16 }}>
                <button className="btn btn--danger btn--sm" onClick={eliminar}>
                  Eliminar sesión
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  </div>
)
}

export default CronogramaPage
