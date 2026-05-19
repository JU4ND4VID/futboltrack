// src/components/DynamicFields.jsx
import { useEffect, useRef, useState } from 'react'
import { FIELD_TYPE_OPTIONS, ID_FIELDS, keyToLabel, normalizeFieldKey } from '../utils/dynamicFields'

export function FieldHeader({ field }) {
  return <span>{field.label || keyToLabel(field.key)}</span>
}

export function ListaEditable({ items = [''], onChange, placeholder, S }) {
  const list = Array.isArray(items) && items.length ? items : ['']

  function set(index, value) {
    const next = [...list]
    next[index] = value
    onChange(next)
  }

  function add() {
    onChange([...list, ''])
  }

  function remove(index) {
    const next = list.filter((_, idx) => idx !== index)
    onChange(next.length ? next : [''])
  }

  return (
    <div>
      {list.map((item, index) => (
        <div key={index} style={{ display: 'flex', gap: 6, marginBottom: 6 }}>
          <input
            style={{ ...S.input, flex: 1 }}
            value={item}
            placeholder={placeholder || 'Valor'}
            onChange={(event) => set(index, event.target.value)}
          />
          {list.length > 1 ? (
            <button
              type="button"
              className="btn btn--danger btn--sm"
              onClick={() => remove(index)}
              style={{ whiteSpace: 'nowrap' }}
            >
              Quitar
            </button>
          ) : null}
        </div>
      ))}
      <button type="button" className="btn btn--secondary btn--sm" onClick={add}>
        + Agregar
      </button>
    </div>
  )
}

function emptyPhase() {
  return { nombre: '', duracion_min: '', objetivos: '', descripcion: '' }
}

export function FasesEditor({ fases = [], onChange, S }) {
  const list = Array.isArray(fases) && fases.length ? fases : [emptyPhase()]

  function setPhase(index, key, value) {
    const next = list.map((phase, idx) => idx === index ? { ...phase, [key]: value } : phase)
    onChange(next)
  }

  function addPhase() {
    onChange([...list, emptyPhase()])
  }

  function removePhase(index) {
    const next = list.filter((_, idx) => idx !== index)
    onChange(next.length ? next : [emptyPhase()])
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      {list.map((phase, index) => (
        <div key={index} style={{ border: '1px solid #E5E7EB', borderRadius: 10, padding: 14, background: '#fff' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <strong style={{ color: '#1A3C6E', fontSize: 14 }}>Fase {index + 1}</strong>
            {list.length > 1 ? (
              <button type="button" className="btn btn--danger btn--sm" onClick={() => removePhase(index)}>
                Quitar fase
              </button>
            ) : null}
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: 12, marginBottom: 12 }}>
            <div>
              <label style={S.label}>Nombre</label>
              <input
                style={S.input}
                value={phase.nombre || ''}
                placeholder="Calentamiento, parte principal..."
                onChange={(event) => setPhase(index, 'nombre', event.target.value)}
              />
            </div>
            <div>
              <label style={S.label}>Duración (min)</label>
              <input
                style={S.input}
                type="number"
                min="0"
                step="1"
                value={phase.duracion_min ?? ''}
                placeholder="20"
                onChange={(event) => setPhase(index, 'duracion_min', event.target.value)}
              />
            </div>
          </div>

          <div style={{ marginBottom: 12 }}>
            <label style={S.label}>Objetivos</label>
            <input
              style={S.input}
              value={phase.objetivos || ''}
              placeholder="Separar varios objetivos con coma"
              onChange={(event) => setPhase(index, 'objetivos', event.target.value)}
            />
          </div>

          <div>
            <label style={S.label}>Descripción</label>
            <textarea
              style={{ ...S.textarea, minHeight: 70 }}
              value={phase.descripcion || ''}
              placeholder="Describe la actividad de esta fase"
              onChange={(event) => setPhase(index, 'descripcion', event.target.value)}
            />
          </div>
        </div>
      ))}

      <button type="button" className="btn btn--secondary btn--sm" onClick={addPhase} style={{ alignSelf: 'flex-start' }}>
        + Agregar fase
      </button>
    </div>
  )
}

export function DynamicFieldInput({ field, value, onChange, S }) {
  if (field.type === 'select') {
    return (
      <select
        style={S.input}
        value={value || ''}
        onChange={(event) => onChange(event.target.value)}
        disabled={field.readOnly}
      >
        <option value="">Selecciona...</option>
        {(field.options || []).map((option) => (
          <option key={option} value={option}>{option}</option>
        ))}
      </select>
    )
  }

  if (field.type === 'list') {
    return (
      <ListaEditable
        items={value}
        onChange={onChange}
        placeholder={field.placeholder}
        S={S}
      />
    )
  }

  if (field.type === 'phases') {
    return <FasesEditor fases={value} onChange={onChange} S={S} />
  }

  if (field.type === 'json' || field.type === 'textarea') {
    return (
      <textarea
        style={{ ...S.textarea, fontFamily: field.type === 'json' ? 'monospace' : undefined }}
        value={value || ''}
        placeholder={field.placeholder || (field.type === 'json' ? '[ ] o { }' : '')}
        onChange={(event) => onChange(event.target.value)}
        readOnly={field.readOnly}
      />
    )
  }

  return (
    <input
      style={S.input}
      type={field.type === 'number' ? 'number' : 'text'}
      min={field.type === 'number' ? '0' : undefined}
      step={field.step || (field.type === 'number' ? '1' : undefined)}
      value={value ?? ''}
      placeholder={field.placeholder || ''}
      onChange={(event) => onChange(event.target.value)}
      readOnly={field.readOnly}
    />
  )
}

export function DynamicFieldsForm({ fields, form, setForm, S, onRemoveField }) {
  function setField(key, value) {
    setForm((prev) => ({ ...prev, [key]: value }))
  }

  return (
    <div>
      {fields.map((field) => (
        <div key={field.key} style={S.card}>
          <div style={{ display: 'flex', justifyContent: 'space-between', gap: 10, marginBottom: 8 }}>
            <label style={S.label}>
              <FieldHeader field={field} S={S} />
            </label>
            {(field.esSugerido || field.esPersonalizado) && !field.esBase ? (
              <button
                type="button"
                className="btn btn--secondary btn--sm"
                onClick={() => onRemoveField(field.key)}
                title="Quitar de esta vista"
              >
                Quitar
              </button>
            ) : null}
          </div>
          <DynamicFieldInput
            field={field}
            value={form[field.key]}
            onChange={(value) => setField(field.key, value)}
            S={S}
          />
        </div>
      ))}
    </div>
  )
}

function renderArrayOfObjects(value, S) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {value.map((item, index) => (
        <div key={index} style={{ border: '1px solid #E5E7EB', borderRadius: 8, padding: 10, background: '#fff' }}>
          <strong style={{ display: 'block', color: '#1A3C6E', marginBottom: 4 }}>
            {item.nombre || `Bloque ${index + 1}`}
            {item.duracion_min ? ` · ${item.duracion_min} min` : ''}
          </strong>
          {item.descripcion ? <div style={{ marginBottom: 4 }}>{item.descripcion}</div> : null}
          {Array.isArray(item.objetivos) && item.objetivos.length ? (
            <div>
              {item.objetivos.map((objetivo, idx) => <span key={idx} style={S.pill}>{objetivo}</span>)}
            </div>
          ) : null}
        </div>
      ))}
    </div>
  )
}

function renderValue(value, S) {
  if (value === undefined || value === null || value === '') {
    return <span style={{ color: '#9CA3AF' }}>--</span>
  }

  if (Array.isArray(value)) {
    const simple = value.every((item) => item === null || ['string', 'number', 'boolean'].includes(typeof item))
    if (simple) {
      if (!value.length) return <span style={{ color: '#9CA3AF' }}>--</span>
      return value.map((item, index) => (
        <span key={index} style={S.pill}>{String(item)}</span>
      ))
    }
    return renderArrayOfObjects(value, S)
  }

  if (typeof value === 'object') {
    return <pre style={S.pre}>{JSON.stringify(value, null, 2)}</pre>
  }

  return <span>{String(value)}</span>
}

export function DynamicValuesView({ doc, fields, S }) {
  const visibleFields = fields.filter((field) => doc && !ID_FIELDS.has(field.key) && Object.prototype.hasOwnProperty.call(doc, field.key))

  if (!visibleFields.length) {
    return <div style={S.infoBox}>No hay campos visibles para este registro.</div>
  }

  return (
    <div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 12 }}>
        {visibleFields.map((field) => (
          <div key={field.key} style={S.card}>
            <h4 style={S.h4}><FieldHeader field={field} S={S} /></h4>
            <div style={{ fontSize: 14, lineHeight: 1.5 }}>{renderValue(doc[field.key], S)}</div>
          </div>
        ))}
      </div>
    </div>
  )
}

export function ModalNuevoCampo({ onAgregar, onCerrar, S, titulo = 'Agregar campo personalizado' }) {
  const [key, setKey] = useState('')
  const [label, setLabel] = useState('')
  const [type, setType] = useState('text')
  const [error, setError] = useState('')
  const inputRef = useRef(null)

  useEffect(() => { inputRef.current?.focus() }, [])

  function handleKey(event) {
    const nextKey = normalizeFieldKey(event.target.value)
    setKey(nextKey)
    if (!label.trim()) setLabel(keyToLabel(nextKey))
  }

  function submit() {
    if (!key.trim()) {
      setError('El nombre del campo es obligatorio.')
      return
    }
    if (!label.trim()) {
      setError('La etiqueta es obligatoria.')
      return
    }
    onAgregar({
      key: key.trim(),
      label: label.trim(),
      type,
      esPersonalizado: true,
      placeholder: type === 'json' ? '[ ] o { }' : 'Valor',
    })
  }

  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000,
    }}>
      <div style={{
        background: '#fff', borderRadius: 12, padding: 28, width: 400,
        boxShadow: '0 20px 60px rgba(0,0,0,0.2)',
      }}>
        <h3 style={{ margin: '0 0 16px', fontSize: 16, color: '#111827' }}>{titulo}</h3>

        {error ? <div style={S.errBox}>{error}</div> : null}

        <div style={{ marginBottom: 14 }}>
          <label style={S.label}>Nombre del campo</label>
          <input
            ref={inputRef}
            style={S.input}
            placeholder="ej. intensidad_grupal"
            value={key}
            onChange={handleKey}
          />
          <span style={{ fontSize: 11, color: '#9CA3AF' }}>Solo letras minusculas, numeros y guion bajo.</span>
        </div>

        <div style={{ marginBottom: 14 }}>
          <label style={S.label}>Etiqueta visible</label>
          <input
            style={S.input}
            placeholder="ej. Intensidad grupal"
            value={label}
            onChange={(event) => setLabel(event.target.value)}
          />
        </div>

        <div style={{ marginBottom: 20 }}>
          <label style={S.label}>Tipo de dato</label>
          <select style={S.input} value={type} onChange={(event) => setType(event.target.value)}>
            {FIELD_TYPE_OPTIONS.map((option) => (
              <option key={option.value} value={option.value}>{option.label}</option>
            ))}
          </select>
        </div>

        <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
          <button type="button" className="btn btn--secondary" onClick={onCerrar}>Cancelar</button>
          <button type="button" className="btn btn--primary" onClick={submit}>Agregar campo</button>
        </div>
      </div>
    </div>
  )
}
