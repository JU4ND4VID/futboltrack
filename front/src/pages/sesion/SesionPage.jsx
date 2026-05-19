// src/pages/sesion/SesionPage.jsx
import { useCallback, useEffect, useState } from 'react'
import { sesionesApi, entrenamientosApi } from '../../api/api'
import {
  buildInitialForm,
  buildPayload,
  emptyValueForType,
  fieldsFromDocument,
  hasUsefulValue,
  mergeFields,
  normalizeSessionType,
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
  tipoBadge: (tipo) => ({
    display: 'inline-block', padding: '4px 12px', borderRadius: 20, fontSize: 12,
    fontWeight: 700, background: tipo === 'Fisico' || tipo === 'Físico' ? '#FEF3C7'
      : tipo === 'Tecnico' || tipo === 'Técnico' ? '#DBEAFE'
      : tipo === 'Tactico' || tipo === 'Táctico' ? '#F3E8FF'
      : tipo === 'Mixto' ? '#DCFCE7' : '#F3F4F6',
    color: tipo === 'Fisico' || tipo === 'Físico' ? '#92400E'
      : tipo === 'Tecnico' || tipo === 'Técnico' ? '#1D4ED8'
      : tipo === 'Tactico' || tipo === 'Táctico' ? '#6B21A8'
      : tipo === 'Mixto' ? '#15803D' : '#374151',
  }),
}

const CAMPOS_PLAN_OCULTOS = new Set(['duracion_total_min'])

const CAMPOS_PLAN_BASE = [
  { key: 'objetivo_sesion', label: 'Objetivo de la sesion', type: 'textarea', esBase: true,
    placeholder: 'Objetivo principal del entrenamiento' },
  { key: 'materiales', label: 'Materiales', type: 'list', esBase: true,
    placeholder: 'Balones, petos, conos...' },
  { key: 'fases', label: 'Fases del plan', type: 'phases', esBase: true },
]

const CAMPOS_POR_TIPO = {
  fisico: [
    { key: 'series', label: 'Series', type: 'number', esBase: true, step: '1' },
    { key: 'repeticiones', label: 'Repeticiones', type: 'number', esBase: true, step: '1' },
    { key: 'descripcion_ejercicio', label: 'Descripcion del ejercicio', type: 'textarea', esBase: true },
  ],
  tecnico: [
    { key: 'ejercicios_tecnicos', label: 'Ejercicios tecnicos', type: 'textarea', esBase: true },
    { key: 'balones', label: 'Balones', type: 'number', esBase: true, step: '1' },
    { key: 'conos', label: 'Conos', type: 'number', esBase: true, step: '1' },
  ],
  tactico: [
    { key: 'sistema_de_juego', label: 'Sistema de juego', type: 'text', esBase: true,
      placeholder: '4-3-3, 4-4-2, 3-5-2...' },
    { key: 'descripcion_tactica', label: 'Descripcion tactica', type: 'textarea', esBase: true },
  ],
  mixto: [
    { key: 'series', label: 'Series', type: 'number', esBase: true, step: '1' },
    { key: 'repeticiones', label: 'Repeticiones', type: 'number', esBase: true, step: '1' },
    { key: 'descripcion_ejercicio', label: 'Descripcion del ejercicio', type: 'textarea', esBase: true },
    { key: 'ejercicios_tecnicos', label: 'Ejercicios tecnicos', type: 'textarea', esBase: true },
    { key: 'balones', label: 'Balones', type: 'number', esBase: true, step: '1' },
    { key: 'conos', label: 'Conos', type: 'number', esBase: true, step: '1' },
  ],
}

function camposBasePlan(tipo) {
  const t = normalizeSessionType(tipo)
  return [
    ...CAMPOS_PLAN_BASE,
    ...(CAMPOS_POR_TIPO[t] || []),
  ]
}

function defaultsEntrenamiento(entrenamiento) {
  return {
    categoria: entrenamiento?.categoria_nombre || '',
    entrenador: entrenamiento?.entrenador_nombre || '',
  }
}

function minutosDesdeHora(hora = '') {
  const [h, m] = String(hora).slice(0, 5).split(':').map(Number)
  if (!Number.isFinite(h) || !Number.isFinite(m)) return null
  return h * 60 + m
}

function calcularDuracionMinutos(entrenamiento) {
  const inicio = minutosDesdeHora(entrenamiento?.hora_inicio)
  const fin = minutosDesdeHora(entrenamiento?.hora_fin)
  if (inicio === null || fin === null || fin <= inicio) return null
  return fin - inicio
}

function formatearDuracion(minutos) {
  if (!minutos) return ''
  const horas = Math.floor(minutos / 60)
  const resto = minutos % 60
  if (!resto) return `${horas} h`
  return `${horas} h ${resto} min`
}

function filtrarCamposPlan(campos = []) {
  return campos.filter((campo) => !CAMPOS_PLAN_OCULTOS.has(campo.key))
}

function validarAntesDeGuardar(campos, form) {
  const utiles = campos.some((campo) => hasUsefulValue(form[campo.key], campo.type))
  if (!utiles) return 'Debes diligenciar al menos un campo del plan.'
  return null
}

function SesionPage() {
  const [entrenamientos, setEntrenamientos] = useState([])
  const [idSeleccionado, setIdSeleccionado] = useState('')
  const [plan, setPlan] = useState(null)
  const [camposComunes, setCamposComunes] = useState([])
  const [campos, setCampos] = useState([])
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
  const tipoActual = entSeleccionado?.tipo || ''
  const duracionSesion = calcularDuracionMinutos(entSeleccionado)

  const cargarCamposComunes = useCallback(async (id = '') => {
    try {
      const data = await sesionesApi.obtenerCamposPlan(id)
      const comunes = filtrarCamposPlan(data.campos || [])
      setCamposComunes(comunes)
      return comunes
    } catch (_) {
      setCamposComunes([])
      return []
    }
  }, [])

  function construirCampos(doc, tipo, comunes = camposComunes) {
    return mergeFields(
      camposBasePlan(tipo),
      comunes,
      fieldsFromDocument(doc || {}, Array.from(CAMPOS_PLAN_OCULTOS))
    )
  }

  useEffect(() => {
    entrenamientosApi.listar()
      .then(setEntrenamientos)
      .catch((err) => setError(err.message))
  }, [])


  useEffect(() => {
    if (!idSeleccionado) return
    const next = construirCampos(plan, tipoActual)
    setCampos(next)
    setForm((prev) => ({
      ...buildInitialForm(next, plan || {}, defaultsEntrenamiento(entSeleccionado)),
      ...prev,
    }))
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [camposComunes])

  const cargar = useCallback(async (id, entrenamientoActual, comunesOverride = null) => {
    if (!id) return
    const comunes = comunesOverride || camposComunes
    setCargando(true)
    setError('')
    setExito('')
    setPlan(null)
    setModo('ver')

    try {
      const data = await sesionesApi.obtenerPlan(id)
      const next = mergeFields(
        camposBasePlan(entrenamientoActual?.tipo || ''),
        comunes,
        fieldsFromDocument(data || {}, Array.from(CAMPOS_PLAN_OCULTOS))
      )
      setPlan(data)
      setCampos(next)
      setForm(buildInitialForm(next, data || {}, defaultsEntrenamiento(entrenamientoActual)))
    } catch (err) {
      const is404 = err.message.includes('404') || err.message.toLowerCase().includes('no tiene')
      if (is404) {
        const next = mergeFields(camposBasePlan(entrenamientoActual?.tipo || ''), comunes)
        setPlan(null)
        setCampos(next)
        setForm(buildInitialForm(next, {}, defaultsEntrenamiento(entrenamientoActual)))
      } else {
        setError(err.message)
      }
    } finally {
      setCargando(false)
    }
  }, [camposComunes])

  async function handleSeleccion(event) {
    const id = event.target.value
    const entrenamiento = entrenamientos.find((item) => String(item.id_entrenamiento) === id)
    setIdSeleccionado(id)
    setModo('ver')
    setFormError('')
    const comunes = await cargarCamposComunes(id)
    cargar(id, entrenamiento, comunes)
  }

  async function abrirCrear() {
    const comunes = await cargarCamposComunes(idSeleccionado)
    const next = construirCampos(null, tipoActual, comunes)
    setCampos(next)
    setForm(buildInitialForm(next, {}, defaultsEntrenamiento(entSeleccionado)))
    setModo('crear')
    setFormError('')
  }

  async function abrirEditar() {
    const comunes = await cargarCamposComunes(idSeleccionado)
    const next = construirCampos(plan, tipoActual, comunes)
    setCampos(next)
    setForm(buildInitialForm(next, plan || {}, defaultsEntrenamiento(entSeleccionado)))
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
    const validation = validarAntesDeGuardar(campos, form)
    if (validation) {
      setFormError(validation)
      return
    }

    setGuardando(true)
    setFormError('')
    setError('')
    try {
      const payload = buildPayload(campos, form)
      payload.tipo_entrenamiento = tipoActual
      if (!payload.categoria && entSeleccionado?.categoria_nombre) payload.categoria = entSeleccionado.categoria_nombre
      if (!payload.entrenador && entSeleccionado?.entrenador_nombre) payload.entrenador = entSeleccionado.entrenador_nombre
      if (duracionSesion) payload.duracion_total_min = duracionSesion

      if (modo === 'crear') {
        await sesionesApi.crearPlan(Number(idSeleccionado), payload)
        setExito('Plan creado correctamente.')
      } else {
        await sesionesApi.actualizarPlan(Number(idSeleccionado), payload)
        setExito('Plan actualizado correctamente.')
      }
      const comunes = await cargarCamposComunes(idSeleccionado)
      await cargar(idSeleccionado, entSeleccionado, comunes)
    } catch (err) {
      setFormError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  async function eliminar() {
    if (!window.confirm('¿Eliminar el plan de esta sesion? Esta accion no se puede deshacer.')) return
    setEliminando(true)
    setError('')
    try {
      await sesionesApi.eliminarPlan(Number(idSeleccionado))
      setExito('Plan eliminado correctamente.')
      setPlan(null)
      setModo('ver')
      const comunes = await cargarCamposComunes(idSeleccionado)
      const next = construirCampos(null, tipoActual, comunes)
      setCampos(next)
      setForm(buildInitialForm(next, {}, defaultsEntrenamiento(entSeleccionado)))
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
          titulo="Agregar campo al plan"
          onAgregar={agregarCampo}
          onCerrar={() => setModalCampo(false)}
        />
      ) : null}

      <div className="page-header">
        <div>
          <h2 className="page-title">Plan de Sesion</h2>
          <p className="page-subtitle">Define objetivos, materiales y fases de trabajo para la sesion.</p>
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
          <span style={S.tipoBadge(entSeleccionado.tipo)}>{entSeleccionado.tipo}</span>{' '}
          {entSeleccionado.fecha} - {entSeleccionado.hora_inicio} a {entSeleccionado.hora_fin} - {entSeleccionado.lugar_nombre}
          {duracionSesion ? <span style={{ marginLeft: 8, color: '#374151' }}>({formatearDuracion(duracionSesion)})</span> : null}
        </div>
      ) : null}

      {cargando ? (
        <p style={{ color: '#6B7280' }}>Cargando plan...</p>
      ) : idSeleccionado ? (
        modo === 'ver' ? (
          plan ? (
            <>
              {!esAdmin ? (
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginBottom: 16 }}>
                  <button className="btn btn--secondary btn--sm" onClick={abrirEditar}>Editar plan</button>
                  <button className="btn btn--danger btn--sm" onClick={eliminar} disabled={eliminando}>
                    {eliminando ? 'Eliminando...' : 'Eliminar plan'}
                  </button>
                </div>
              ) : null}
              <DynamicValuesView doc={plan} fields={campos} S={S} />
            </>
          ) : (
            <div style={{ textAlign: 'center', padding: '40px 0' }}>
              <p style={{ color: '#6B7280', marginBottom: 16 }}>
                Esta sesion no tiene plan registrado aun.
              </p>
              {!esAdmin ? <button className="btn btn--primary" onClick={abrirCrear}>+ Crear plan de sesion</button> : null}
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
                {guardando ? 'Guardando...' : modo === 'crear' ? 'Crear plan' : 'Actualizar plan'}
              </button>
            </div>
          </>
        )
      ) : null}
    </div>
  )
}

export default SesionPage
