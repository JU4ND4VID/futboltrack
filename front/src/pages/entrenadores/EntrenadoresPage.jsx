// src/pages/entrenadores/EntrenadoresPage.jsx
// Gestión de entrenadores y categorías — solo visible para administradores.
import { useState, useEffect, useCallback } from 'react'
import { catalogosApi, entrenadoresApi } from '../../api/api'

const S = {
  tabla:  { width: '100%', borderCollapse: 'collapse', fontSize: 14 },
  th:     { padding: '10px 12px', background: '#1A3C6E', color: '#fff',
            textAlign: 'left', fontWeight: 600, fontSize: 13 },
  td:     { padding: '9px 12px', borderBottom: '1px solid #E5E7EB', verticalAlign: 'middle' },
  overlay:{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,.45)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 },
  overlayTop:{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,.35)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1100 },
  modal:  { background: '#fff', borderRadius: 12, padding: '28px 32px',
            width: '100%', maxWidth: 560, maxHeight: '90vh', overflowY: 'auto',
            boxShadow: '0 20px 60px rgba(0,0,0,.25)' },
  modalSm:{ background: '#fff', borderRadius: 12, padding: '24px 28px',
            width: '100%', maxWidth: 460, maxHeight: '90vh', overflowY: 'auto',
            boxShadow: '0 20px 60px rgba(0,0,0,.25)' },
  input:  { width: '100%', padding: '8px 10px', border: '1px solid #D1D5DB',
            borderRadius: 6, fontSize: 14, boxSizing: 'border-box' },
  label:  { display: 'block', fontSize: 13, fontWeight: 600, color: '#374151', marginBottom: 4 },
  fila:   { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14, marginBottom: 14 },
  errBox: { background: '#FEE2E2', color: '#991B1B', borderRadius: 6,
            padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  okBox:  { background: '#DCFCE7', color: '#15803D', borderRadius: 6,
            padding: '8px 12px', fontSize: 13, marginBottom: 12 },
  badge:  { display: 'inline-block', padding: '2px 10px', borderRadius: 12,
            fontSize: 12, fontWeight: 600, background: '#EFF6FF', color: '#1D4ED8' },
  badgeOk:{ display: 'inline-block', padding: '2px 10px', borderRadius: 12,
            fontSize: 12, fontWeight: 600, background: '#DCFCE7', color: '#15803D' },
  badgeWarn:{ display: 'inline-block', padding: '2px 10px', borderRadius: 12,
            fontSize: 12, fontWeight: 600, background: '#FEF3C7', color: '#92400E' },
  card:   { background: '#fff', border: '1px solid #E5E7EB', borderRadius: 10, padding: 16, marginTop: 22 },
}

const FORM_VACIO = {
  cedula_entrenador: '', nombre: '', apellido: '',
  email: '', contrasena: '', telefono: '', id_categoria: '',
}

const CATEGORIA_VACIA = {
  nombre: '', edad_minima: '', edad_maxima: '',
}

function Campo({ label, children }) {
  return (
    <div style={{ marginBottom: 14 }}>
      <label style={S.label}>{label}</label>
      {children}
    </div>
  )
}

function nombreCompleto(e) {
  return `${e?.nombre || ''} ${e?.apellido || ''}`.trim()
}

function EntrenadoresPage() {
  const [entrenadores, setEntrenadores] = useState([])
  const [categorias,   setCategorias]   = useState([])
  const [cargando,     setCargando]     = useState(true)
  const [error,        setError]        = useState('')
  const [exito,        setExito]        = useState('')

  const [modal,        setModal]        = useState(null)   // null | 'crear' | 'editar'
  const [form,         setForm]         = useState(FORM_VACIO)
  const [guardando,    setGuardando]    = useState(false)
  const [formError,    setFormError]    = useState('')
  const [busqueda,     setBusqueda]     = useState('')

  const [modalCategoria, setModalCategoria] = useState(null) // null | 'crear' | 'editar'
  const [categoriaForm, setCategoriaForm] = useState(CATEGORIA_VACIA)
  const [categoriaEditandoId, setCategoriaEditandoId] = useState(null)
  const [categoriaError, setCategoriaError] = useState('')
  const [guardandoCategoria, setGuardandoCategoria] = useState(false)

  const cargar = useCallback(async () => {
    setCargando(true)
    setError('')
    try {
      const [e, c] = await Promise.all([
        entrenadoresApi.listar(),
        catalogosApi.categorias(),
      ])
      setEntrenadores(e)
      setCategorias(c)
    } catch (err) {
      setError(err.message)
    } finally {
      setCargando(false)
    }
  }, [])

  useEffect(() => { cargar() }, [cargar])

  const filtrados = entrenadores.filter(e => {
    const q = busqueda.toLowerCase()
    return (
      e.nombre?.toLowerCase().includes(q) ||
      e.apellido?.toLowerCase().includes(q) ||
      e.cedula_entrenador?.includes(q) ||
      e.email?.toLowerCase().includes(q) ||
      e.categoria_nombre?.toLowerCase().includes(q)
    )
  })

  function entrenadorDeCategoria(idCategoria, cedulaIgnorar = '') {
    return entrenadores.find(e =>
      String(e.id_categoria) === String(idCategoria) &&
      String(e.cedula_entrenador) !== String(cedulaIgnorar)
    )
  }

  function abrirCrear() {
    setForm(FORM_VACIO)
    setFormError('')
    setExito('')
    setModal('crear')
  }

  function abrirEditar(e) {
    setForm({
      cedula_entrenador: e.cedula_entrenador,
      nombre:            e.nombre,
      apellido:          e.apellido,
      email:             e.email,
      contrasena:        '',
      telefono:          e.telefono,
      id_categoria:      String(e.id_categoria),
    })
    setFormError('')
    setExito('')
    setModal('editar')
  }

  function cerrar() { setModal(null) }
  function setF(k, v) { setForm(f => ({ ...f, [k]: v })) }
  function setCat(k, v) { setCategoriaForm(f => ({ ...f, [k]: v })) }

  function validarFormularioEntrenador() {
    const soloNum    = /^\d+$/
    const soloLetras = /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/
    const emailRe    = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (modal === 'crear') {
      if (!soloNum.test(form.cedula_entrenador) ||
          form.cedula_entrenador.length < 6 ||
          form.cedula_entrenador.length > 15) {
        return 'Cédula inválida (6–15 dígitos numéricos).'
      }
    }
    if (!soloLetras.test(form.nombre) || form.nombre.trim().length < 2) {
      return 'Nombre inválido (solo letras, mínimo 2 caracteres).'
    }
    if (!soloLetras.test(form.apellido) || form.apellido.trim().length < 2) {
      return 'Apellido inválido (solo letras, mínimo 2 caracteres).'
    }
    if (!emailRe.test(form.email)) return 'Email inválido.'
    if (modal === 'crear' && form.contrasena.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.'
    }
    if (!soloNum.test(form.telefono) || form.telefono.length !== 10) {
      return 'Teléfono inválido (10 dígitos numéricos).'
    }
    if (!form.id_categoria) return 'Selecciona una categoría.'

    const ocupante = entrenadorDeCategoria(form.id_categoria, modal === 'editar' ? form.cedula_entrenador : '')
    if (ocupante) {
      return `La categoría seleccionada ya tiene asignado a ${nombreCompleto(ocupante)}.`
    }

    return ''
  }

  async function guardar() {
    setGuardando(true)
    setFormError('')
    setExito('')

    const errorValidacion = validarFormularioEntrenador()
    if (errorValidacion) {
      setFormError(errorValidacion)
      setGuardando(false)
      return
    }

    try {
      if (modal === 'crear') {
        await entrenadoresApi.crear({ ...form, id_categoria: Number(form.id_categoria) })
        setExito('Entrenador creado correctamente.')
      } else {
        const payload = {
          nombre:       form.nombre,
          apellido:     form.apellido,
          email:        form.email,
          telefono:     form.telefono,
          id_categoria: Number(form.id_categoria),
        }
        if (form.contrasena) payload.contrasena = form.contrasena
        await entrenadoresApi.actualizar(form.cedula_entrenador, payload)
        setExito('Entrenador actualizado correctamente.')
      }
      cerrar()
      await cargar()
    } catch (err) {
      setFormError(err.message)
    } finally {
      setGuardando(false)
    }
  }

  async function eliminar(cedula) {
    if (!window.confirm('¿Eliminar este entrenador? Esta acción no se puede deshacer.')) return
    try {
      await entrenadoresApi.eliminar(cedula)
      setExito('Entrenador eliminado correctamente.')
      await cargar()
    } catch (err) {
      alert(err.message)
    }
  }

  function abrirCrearCategoria() {
    setCategoriaForm(CATEGORIA_VACIA)
    setCategoriaEditandoId(null)
    setCategoriaError('')
    setModalCategoria('crear')
  }

  function abrirEditarCategoria(categoria) {
    setCategoriaForm({
      nombre: categoria.nombre,
      edad_minima: String(categoria.rango_edad_min ?? ''),
      edad_maxima: String(categoria.rango_edad_max ?? ''),
    })
    setCategoriaEditandoId(categoria.id_categoria)
    setCategoriaError('')
    setModalCategoria('editar')
  }

  function validarCategoria() {
    const nombre = categoriaForm.nombre.trim()
    const edadMin = Number(categoriaForm.edad_minima)
    const edadMax = Number(categoriaForm.edad_maxima)

    if (nombre.length < 2 || nombre.length > 60) return 'El nombre debe tener entre 2 y 60 caracteres.'
    if (!Number.isInteger(edadMin) || !Number.isInteger(edadMax)) return 'Las edades deben ser números enteros.'
    if (edadMin < 4 || edadMax > 30) return 'Las edades deben estar entre 4 y 30 años.'
    if (edadMin > edadMax) return 'La edad mínima no puede ser mayor que la edad máxima.'

    const duplicada = categorias.find(c =>
      c.nombre.toLowerCase() === nombre.toLowerCase() &&
      String(c.id_categoria) !== String(categoriaEditandoId || '')
    )
    if (duplicada) return 'Ya existe una categoría con ese nombre.'
    return ''
  }

  async function guardarCategoria() {
    setGuardandoCategoria(true)
    setCategoriaError('')

    const errorValidacion = validarCategoria()
    if (errorValidacion) {
      setCategoriaError(errorValidacion)
      setGuardandoCategoria(false)
      return
    }

    const payload = {
      nombre: categoriaForm.nombre.trim(),
      edad_minima: Number(categoriaForm.edad_minima),
      edad_maxima: Number(categoriaForm.edad_maxima),
    }

    try {
      if (modalCategoria === 'crear') {
        const resp = await catalogosApi.crearCategoria(payload)
        setExito('Categoría creada correctamente.')
        await cargar()
        if (resp.id_categoria && modal) {
          setF('id_categoria', String(resp.id_categoria))
        }
      } else {
        await catalogosApi.actualizarCategoria(categoriaEditandoId, payload)
        setExito('Categoría actualizada correctamente.')
        await cargar()
      }
      setModalCategoria(null)
    } catch (err) {
      setCategoriaError(err.message)
    } finally {
      setGuardandoCategoria(false)
    }
  }

  async function eliminarCategoria(idCategoria) {
    if (!window.confirm('¿Eliminar esta categoría? Solo se puede eliminar si no tiene registros asociados.')) return
    try {
      await catalogosApi.eliminarCategoria(idCategoria)
      setExito('Categoría eliminada correctamente.')
      await cargar()
    } catch (err) {
      alert(err.message)
    }
  }

  return (
    <div>
      <div className="page-header">
        <div>
          <h2 className="page-title">Entrenadores</h2>
          <p className="page-subtitle">Gestión de entrenadores y categorías del club</p>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          <button className="btn btn--secondary" onClick={abrirCrearCategoria}>
            + Nueva categoría
          </button>
          <button className="btn btn--primary" onClick={abrirCrear}>
            + Nuevo entrenador
          </button>
        </div>
      </div>

      <div style={{ marginBottom: 16 }}>
        <input
          style={{ ...S.input, maxWidth: 360 }}
          placeholder="Buscar por nombre, cédula, email o categoría…"
          value={busqueda}
          onChange={e => setBusqueda(e.target.value)}
        />
      </div>

      {error && <div style={S.errBox}>⚠ {error}</div>}
      {exito && <div style={S.okBox}>✓ {exito}</div>}

      {cargando ? (
        <p style={{ color: '#6B7280' }}>Cargando entrenadores…</p>
      ) : (
        <div style={{ overflowX: 'auto', borderRadius: 10, border: '1px solid #E5E7EB' }}>
          <table style={S.tabla}>
            <thead>
              <tr>
                {['Cédula', 'Nombre', 'Email', 'Teléfono', 'Categoría', 'Acciones'].map(h => (
                  <th key={h} style={S.th}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtrados.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ ...S.td, textAlign: 'center', color: '#9CA3AF' }}>
                    Sin entrenadores registrados
                  </td>
                </tr>
              ) : (
                filtrados.map(e => (
                  <tr key={e.cedula_entrenador}>
                    <td style={S.td}>{e.cedula_entrenador}</td>
                    <td style={S.td}>{e.nombre} {e.apellido}</td>
                    <td style={S.td}>{e.email}</td>
                    <td style={S.td}>{e.telefono}</td>
                    <td style={S.td}>
                      <span style={S.badge}>{e.categoria_nombre}</span>
                    </td>
                    <td style={S.td}>
                      <button
                        className="btn btn--secondary btn--sm"
                        style={{ marginRight: 6 }}
                        onClick={() => abrirEditar(e)}
                      >
                        Editar
                      </button>
                      <button
                        className="btn btn--danger btn--sm"
                        onClick={() => eliminar(e.cedula_entrenador)}
                      >
                        Eliminar
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      <div style={S.card}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12, marginBottom: 12 }}>
          <div>
            <h3 style={{ margin: 0, color: '#1A3C6E', fontSize: 17 }}>Categorías</h3>
            <p style={{ margin: '4px 0 0', color: '#6B7280', fontSize: 13 }}>
              Cada categoría puede tener máximo un entrenador asignado.
            </p>
          </div>
          <button className="btn btn--primary btn--sm" onClick={abrirCrearCategoria}>+ Crear categoría</button>
        </div>
        <div style={{ overflowX: 'auto', borderRadius: 10, border: '1px solid #E5E7EB' }}>
          <table style={S.tabla}>
            <thead>
              <tr>
                {['Categoría', 'Rango de edad', 'Estado', 'Entrenador asignado', 'Acciones'].map(h => (
                  <th key={h} style={S.th}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {categorias.length === 0 ? (
                <tr>
                  <td colSpan={5} style={{ ...S.td, textAlign: 'center', color: '#9CA3AF' }}>
                    Sin categorías registradas
                  </td>
                </tr>
              ) : categorias.map(c => {
                const ocupante = entrenadorDeCategoria(c.id_categoria)
                return (
                  <tr key={c.id_categoria}>
                    <td style={S.td}><strong>{c.nombre}</strong></td>
                    <td style={S.td}>{c.rango_edad_min}–{c.rango_edad_max} años</td>
                    <td style={S.td}>
                      <span style={ocupante ? S.badgeWarn : S.badgeOk}>{ocupante ? 'Asignada' : 'Disponible'}</span>
                    </td>
                    <td style={S.td}>{ocupante ? nombreCompleto(ocupante) : '—'}</td>
                    <td style={S.td}>
                      <button className="btn btn--secondary btn--sm" style={{ marginRight: 6 }} onClick={() => abrirEditarCategoria(c)}>
                        Editar
                      </button>
                      <button className="btn btn--danger btn--sm" onClick={() => eliminarCategoria(c.id_categoria)}>
                        Eliminar
                      </button>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {modal && (
        <div style={S.overlay} onClick={e => e.target === e.currentTarget && cerrar()}>
          <div style={S.modal}>
            <h3 style={{ marginBottom: 20, color: '#1A3C6E' }}>
              {modal === 'crear' ? 'Nuevo entrenador' : 'Editar entrenador'}
            </h3>

            {formError && <div style={S.errBox}>{formError}</div>}

            <div style={S.fila}>
              <Campo label="Cédula">
                <input
                  style={S.input}
                  value={form.cedula_entrenador}
                  readOnly={modal === 'editar'}
                  onChange={e => setF('cedula_entrenador', e.target.value)}
                />
              </Campo>
              <Campo label="Categoría">
                <div style={{ display: 'flex', gap: 8 }}>
                  <select
                    style={S.input}
                    value={form.id_categoria}
                    onChange={e => setF('id_categoria', e.target.value)}
                  >
                    <option value="">Selecciona…</option>
                    {categorias.map(c => {
                      const ocupante = entrenadorDeCategoria(c.id_categoria, modal === 'editar' ? form.cedula_entrenador : '')
                      return (
                        <option key={c.id_categoria} value={c.id_categoria} disabled={Boolean(ocupante)}>
                          {c.nombre} ({c.rango_edad_min}–{c.rango_edad_max} años){ocupante ? ` — asignada a ${nombreCompleto(ocupante)}` : ''}
                        </option>
                      )
                    })}
                  </select>
                  <button type="button" className="btn btn--secondary btn--sm" onClick={abrirCrearCategoria} style={{ whiteSpace: 'nowrap' }}>
                    Nueva
                  </button>
                </div>
              </Campo>
            </div>

            <div style={S.fila}>
              <Campo label="Nombre">
                <input style={S.input} value={form.nombre}
                  onChange={e => setF('nombre', e.target.value)} />
              </Campo>
              <Campo label="Apellido">
                <input style={S.input} value={form.apellido}
                  onChange={e => setF('apellido', e.target.value)} />
              </Campo>
            </div>

            <Campo label="Email">
              <input style={S.input} type="email" value={form.email}
                onChange={e => setF('email', e.target.value)} />
            </Campo>

            <div style={S.fila}>
              <Campo label="Teléfono">
                <input style={S.input} value={form.telefono}
                  onChange={e => setF('telefono', e.target.value)} />
              </Campo>
              <Campo label={modal === 'crear' ? 'Contraseña' : 'Nueva contraseña (opcional)'}>
                <input style={S.input} type="password" value={form.contrasena}
                  placeholder={modal === 'editar' ? 'Dejar vacío para no cambiar' : ''}
                  onChange={e => setF('contrasena', e.target.value)} />
              </Campo>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 20 }}>
              <button className="btn btn--secondary" onClick={cerrar} disabled={guardando}>
                Cancelar
              </button>
              <button className="btn btn--primary" onClick={guardar} disabled={guardando}>
                {guardando ? 'Guardando…' : 'Guardar'}
              </button>
            </div>
          </div>
        </div>
      )}

      {modalCategoria && (
        <div style={S.overlayTop} onClick={e => e.target === e.currentTarget && setModalCategoria(null)}>
          <div style={S.modalSm}>
            <h3 style={{ marginBottom: 18, color: '#1A3C6E' }}>
              {modalCategoria === 'crear' ? 'Nueva categoría' : 'Editar categoría'}
            </h3>

            {categoriaError && <div style={S.errBox}>{categoriaError}</div>}

            <Campo label="Nombre de la categoría">
              <input
                style={S.input}
                value={categoriaForm.nombre}
                placeholder="Ej: Sub-18"
                onChange={e => setCat('nombre', e.target.value)}
              />
            </Campo>

            <div style={S.fila}>
              <Campo label="Edad mínima">
                <input
                  style={S.input}
                  type="number"
                  min="4"
                  max="30"
                  value={categoriaForm.edad_minima}
                  onChange={e => setCat('edad_minima', e.target.value)}
                />
              </Campo>
              <Campo label="Edad máxima">
                <input
                  style={S.input}
                  type="number"
                  min="4"
                  max="30"
                  value={categoriaForm.edad_maxima}
                  onChange={e => setCat('edad_maxima', e.target.value)}
                />
              </Campo>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 20 }}>
              <button className="btn btn--secondary" onClick={() => setModalCategoria(null)} disabled={guardandoCategoria}>
                Cancelar
              </button>
              <button className="btn btn--primary" onClick={guardarCategoria} disabled={guardandoCategoria}>
                {guardandoCategoria ? 'Guardando…' : 'Guardar categoría'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default EntrenadoresPage
