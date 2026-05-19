// src/pages/observaciones/ObservacionesPage.jsx
import { useCallback, useEffect, useState } from 'react'
import { sesionesApi, entrenamientosApi } from '../../api/api'
import {
  buildInitialForm,
  buildPayload,
  emptyValueForType,
  fieldsFromDocument,
  mergeFields,
} from '../../utils/dynamicFields'
import {
  DynamicFieldsForm,
  DynamicValuesView,
  ModalNuevoCampo,
} from '../../components/DynamicFields'

const S = {
  select: { padding: '8px 12px', border: '1px solid #D1D5DB', borderRadius: 6,
            fontSize: 14, minWidth: 280, background: '#fff', cursor: 'pointer' },
  input: { width: '100%', padding: '8px 10px', border: '1px solid #D1D5DB',
           borderRadius: 6, fontSize: 14, boxSizing: 'border-box', background: '#fff' },
  textarea: { width: '100%', padding: '8px 10px', border: '1px solid #D1D5DB',
              borderRadius: 6, fontSize: 14, boxSizing: 'border-box', resize: 'vertical', minHeight: 90,
              background: '#fff' },
  label: { display: 'block', fontSize: 13, fontWeight: 700, color: '#374151', marginBottom: 4 },
  card: { background: '#F9FAFB', border: '1px solid #E5E7EB', borderRadius: 10,
          padding: '16px 18px', marginBottom: 12 },
  h4: { fontSize: 14, fontWeight: 700, color: '#1A3C6E', margin: '0 0 8px' },
  pill: { display: 'inline-block', background: '#EFF6FF', color: '#1D4ED8',
          borderRadius: 16, padding: '3px 10px', fontSize: 12, fontWeight: 600,
          marginRight: 6, marginBottom: 4 },
  pre: { whiteSpace: 'pre-wrap', background: '#111827', color: '#F9FAFB', borderRadius: 8,
         padding: 10, margin: 0, fontSize: 12, overflowX: 'auto' },
  errBox: { background: '#FEE2E2', color: '#991B1B', borderRadius: 6,
            padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  okBox: { background: '#DCFCE7', color: '#15803D', borderRadius: 6,
           padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  infoBox: { background: '#EFF6FF', color: '#1D4ED8', borderRadius: 6,
             padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  tagSugerido: { display: 'inline-block', padding: '2px 8px', borderRadius: 10,
                 fontSize: 11, fontWeight: 700, background: '#DBEAFE', color: '#1D4ED8' },
  tagPersonalizado: { display: 'inline-block', padding: '2px 8px', borderRadius: 10,
                      fontSize: 11, fontWeight: 700, background: '#F3E8FF', color: '#6B21A8' },
}

const ESTADOS_ANIMO = ['muy motivado', 'motivado', 'concentrado', 'cansado', 'tenso', 'regular', 'neutro']
const CLIMAS = ['soleado', 'parcialmente nublado', 'nublado', 'lluvioso', 'frio', 'caluroso']

const CAMPOS_OBSERVACION_BASE = [
  { key: 'observacion_general', label: 'Observacion general', type: 'textarea', esBase: true,
    placeholder: 'Resumen general de la sesion...' },
  { key: 'aspectos_positivos', label: 'Aspectos positivos', type: 'list', esBase: true,
    placeholder: 'Buena actitud, alta intensidad...' },
  { key: 'aspectos_a_mejorar', label: 'Aspectos a mejorar', type: 'list', esBase: true,
    placeholder: 'Comunicacion, transiciones...' },
  { key: 'estado_animo_grupo', label: 'Estado de animo del grupo', type: 'select', esBase: true,
    options: ESTADOS_ANIMO },
  { key: 'condiciones_clima', label: 'Condiciones climaticas', type: 'select', esBase: true,
    options: CLIMAS },
  { key: 'jugadores_destacados', label: 'Jugadores destacados', type: 'list', esBase: true,
    placeholder: 'Nombre o cedula del jugador' },
]

function ObservacionesPage() {
  const [entrenamientos, setEntrenamientos] = useState([])
  const [idSeleccionado, setIdSeleccionado] = useState('')
  const [obs, setObs] = useState(null)
  const [camposComunes, setCamposComunes] = useState([])
  const [campos, setCampos] = useState(CAMPOS_OBSERVACION_BASE)
  const [modo, setModo] = useState('ver')
  const [form, setForm] = useState({})
  const [cargando, setCargando] = useState(false)
  const [guardando, setGuardando] = useState(false)
  const [eliminando, setEliminando] = useState(false)
  const [modalCampo, setModalCampo] = useState(false)
  const [error, setError] = useState('')
  const [exito, setExito] = useState('')
  const [formError, setFormError] = useState('')

  const user = JSON.parse(localStorage.getItem('ft_user') || '{}')
  const esAdmin = user.tipo_usuario === 'admin'

  const entSeleccionado = entrenamientos.find(
    (e) => String(e.id_entrenamiento) === idSeleccionado
  )

  const cargarCamposComunes = useCallback(async (id = '') => {
    try {
      const data = await sesionesApi.obtenerCamposObservaciones(id)
      const comunes = data.campos || []
      setCamposComunes(comunes)
      return comunes
    } catch (_) {
      setCamposComunes([])
      return []
    }
  }, [])

  function construirCampos(doc, comunes = camposComunes) {
    return mergeFields(
      CAMPOS_OBSERVACION_BASE,
      comunes,
      fieldsFromDocument(doc || {})
    )
  }

  useEffect(() => {
    entrenamientosApi.listar()
      .then(setEntrenamientos)
      .catch((err) => setError(err.message))
  }, [])


  useEffect(() => {
    if (!idSeleccionado) return
    const next = construirCampos(obs)
    setCampos(next)
    setForm((prev) => ({ ...buildInitialForm(next, obs || {}), ...prev }))
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [camposComunes])

  const cargar = useCallback(async (id, comunesOverride = null) => {
    if (!id) return
    const comunes = comunesOverride || camposComunes
    setCargando(true)
    setError('')
    setExito('')
    setObs(null)
    setModo('ver')

    try {
      const data = await sesionesApi.obtenerObservaciones(id)
      const next = mergeFields(CAMPOS_OBSERVACION_BASE, comunes, fieldsFromDocument(data || {}))
      setObs(data)
      setCampos(next)
      setForm(buildInitialForm(next, data || {}))
    } catch (err) {
      const is404 = err.message.includes('404') || err.message.toLowerCase().includes('no hay')
      if (is404) {
        const next = mergeFields(CAMPOS_OBSERVACION_BASE, comunes)
        setObs(null)
        setCampos(next)
        setForm(buildInitialForm(next, {}))
      } else {
        setError(err.message)
      }
    } finally {
      setCargando(false)
    }
  }, [camposComunes])

  async function handleSeleccion(event) {
    const id = event.target.value
    setIdSeleccionado(id)
    setModo('ver')
    setFormError('')
    const comunes = await cargarCamposComunes(id)
    cargar(id, comunes)
  }

  async function abrirCrear() {
    const comunes = await cargarCamposComunes(idSeleccionado)
    const next = construirCampos(null, comunes)
    setCampos(next)
    setForm(buildInitialForm(next, {}))
    setModo('crear')
    setFormError('')
  }

  async function abrirEditar() {
    const comunes = await cargarCamposComunes(idSeleccionado)
    const next = construirCampos(obs, comunes)
    setCampos(next)
    setForm(buildInitialForm(next, obs || {}))
    setModo('editar')
    setFormError('')
  }

  function agregarCampo(nuevoCampo) {
    if (campos.some((campo) => campo.key === nuevoCampo.key)) {
      setError(`Ya existe un campo con el nombre "${nuevoCampo.key}".`)
      setModalCampo(false)
      return
    }
    setCampos((prev) => [...prev, nuevoCampo])
    setForm((prev) => ({ ...prev, [nuevoCampo.key]: emptyValueForType(nuevoCampo.type) }))
    setModalCampo(false)
  }

  function quitarCampo(key) {
    if (!window.confirm(`¿Quitar el campo "${key}" de esta vista?`)) return
    setCampos((prev) => prev.filter((campo) => campo.key !== key))
    setForm((prev) => {
      const next = { ...prev }
      delete next[key]
      return next
    })
  }

  async function guardar() {
    if (!String(form.observacion_general || '').trim()) {
      setFormError('La observacion general es obligatoria.')
      return
    }

    setGuardando(true)
    setFormError('')
    setError('')
    try {
      const payload = buildPayload(campos, form)
      await sesionesApi.guardarObservaciones(Number(idSeleccionado), payload)
      setExito(modo === 'crear'
        ? 'Observaciones guardadas correctamente.'
        : 'Observaciones actualizadas correctamente.')
      const comunes = await cargarCamposComunes(idSeleccionado)
      await cargar(idSeleccionado, comunes)
    } catch (err) {
      setFormError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  async function eliminar() {
    if (!window.confirm('¿Eliminar las observaciones de esta sesion? Esta accion no se puede deshacer.')) return
    setEliminando(true)
    setError('')
    try {
      await sesionesApi.eliminarObservaciones(Number(idSeleccionado))
      setExito('Observaciones eliminadas correctamente.')
      setObs(null)
      setModo('ver')
      const comunes = await cargarCamposComunes(idSeleccionado)
      const next = construirCampos(null, comunes)
      setCampos(next)
      setForm(buildInitialForm(next, {}))
    } catch (err) {
      setError(err.message)
    } finally {
      setEliminando(false)
    }
  }

  return (
    <div>
      {modalCampo ? (
        <ModalNuevoCampo
          S={S}
          titulo="Agregar campo a observaciones"
          onAgregar={agregarCampo}
          onCerrar={() => setModalCampo(false)}
        />
      ) : null}

      <div className="page-header">
        <div>
          <h2 className="page-title">Observaciones de Sesion</h2>
          <p className="page-subtitle">Registra conclusiones, aspectos positivos y oportunidades de mejora.</p>
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
        <label style={{ fontWeight: 600, fontSize: 14, color: '#374151' }}>Sesion:</label>
        <select style={S.select} value={idSeleccionado} onChange={handleSeleccion}>
          <option value="">-- Selecciona una sesion --</option>
          {entrenamientos.map((e) => (
            <option key={e.id_entrenamiento} value={e.id_entrenamiento}>
              #{e.id_entrenamiento} - {e.fecha} - {e.tipo} - {e.categoria_nombre}
            </option>
          ))}
        </select>
      </div>

      {error ? <div style={S.errBox}>! {error}</div> : null}
      {exito ? <div style={S.okBox}>OK {exito}</div> : null}

      {entSeleccionado ? (
        <div style={{ background: '#F0F4FF', borderRadius: 8, padding: '12px 16px',
                      marginBottom: 16, fontSize: 14, color: '#1A3C6E' }}>
          <strong>{entSeleccionado.tipo}</strong> - {entSeleccionado.fecha} - {entSeleccionado.hora_inicio} a {entSeleccionado.hora_fin} - {entSeleccionado.lugar_nombre}
        </div>
      ) : null}

      {cargando ? (
        <p style={{ color: '#6B7280' }}>Cargando observaciones...</p>
      ) : idSeleccionado ? (
        modo === 'ver' ? (
          obs ? (
            <>
              {!esAdmin ? (
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginBottom: 16 }}>
                  <button className="btn btn--secondary btn--sm" onClick={abrirEditar}>Editar observaciones</button>
                  <button className="btn btn--danger btn--sm" onClick={eliminar} disabled={eliminando}>
                    {eliminando ? 'Eliminando...' : 'Eliminar observaciones'}
                  </button>
                </div>
              ) : null}
              <DynamicValuesView doc={obs} fields={campos} S={S} />
            </>
          ) : (
            <div style={{ textAlign: 'center', padding: '40px 0' }}>
              <p style={{ color: '#6B7280', marginBottom: 16 }}>
                Esta sesion no tiene observaciones registradas aun.
              </p>
              {!esAdmin ? <button className="btn btn--primary" onClick={abrirCrear}>+ Registrar observaciones</button> : null}
            </div>
          )
        ) : (
          <>
            {formError ? <div style={S.errBox}>{formError}</div> : null}
            <div style={{ display: 'flex', justifyContent: 'flex-end', alignItems: 'center', marginBottom: 12 }}>
              <button className="btn btn--secondary btn--sm" onClick={() => setModalCampo(true)}>
                + Agregar campo
              </button>
            </div>
            <DynamicFieldsForm
              fields={campos}
              form={form}
              setForm={setForm}
              S={S}
              onRemoveField={quitarCampo}
            />
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 20 }}>
              <button className="btn btn--secondary" onClick={() => { setModo('ver'); setFormError('') }} disabled={guardando}>
                Cancelar
              </button>
              <button className="btn btn--primary" onClick={guardar} disabled={guardando}>
                {guardando ? 'Guardando...' : modo === 'crear' ? 'Guardar observaciones' : 'Actualizar observaciones'}
              </button>
            </div>
          </>
        )
      ) : null}
    </div>
  )
}

export default ObservacionesPage
