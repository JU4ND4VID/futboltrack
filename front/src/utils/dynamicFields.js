// src/utils/dynamicFields.js
// Helpers reutilizables para formularios dinamicos.

export const ID_FIELDS = new Set(['_id', 'id_entrenamiento', 'id_entrenamiento_mysql'])

export const FIELD_TYPE_OPTIONS = [
  { value: 'text', label: 'Texto corto' },
  { value: 'textarea', label: 'Texto largo' },
  { value: 'number', label: 'Numero' },
  { value: 'list', label: 'Lista' },
  { value: 'json', label: 'JSON' },
]

export function keyToLabel(key = '') {
  return String(key)
    .replace(/_/g, ' ')
    .replace(/\b\w/g, (c) => c.toUpperCase())
}

export function normalizeFieldKey(value = '') {
  return String(value)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '_')
    .replace(/[^a-z0-9_]/g, '')
}

export function normalizeSessionType(value = '') {
  return String(value)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
}

export function inferFieldType(value) {
  if (typeof value === 'number') return 'number'
  if (Array.isArray(value)) {
    const simple = value.every((item) => item === null || ['string', 'number', 'boolean'].includes(typeof item))
    return simple ? 'list' : 'json'
  }
  if (value && typeof value === 'object') return 'json'
  const text = value == null ? '' : String(value)
  return text.length > 90 || text.includes('\n') ? 'textarea' : 'text'
}

function mergeType(previous, next) {
  if (!previous) return next || 'text'
  if (!next || previous === next) return previous
  const types = new Set([previous, next])
  if (types.has('phases')) return 'phases'
  if (types.has('json')) return 'json'
  if (types.has('list') && types.size > 1) return 'json'
  if (types.has('textarea') && (types.has('text') || types.size === 1)) return 'textarea'
  if (types.has('number') && types.size > 1) return 'text'
  return previous
}

export function fieldsFromDocument(doc = {}, extraIgnore = []) {
  const ignore = new Set([...ID_FIELDS, ...extraIgnore])
  return Object.entries(doc || {})
    .filter(([key]) => !ignore.has(key))
    .map(([key, value]) => ({
      key,
      label: keyToLabel(key),
      type: inferFieldType(value),
      esSugerido: true,
      frecuencia: 1,
    }))
}

export function mergeFields(...groups) {
  const map = new Map()
  for (const group of groups) {
    for (const raw of group || []) {
      if (!raw?.key || ID_FIELDS.has(raw.key)) continue
      const previous = map.get(raw.key)
      if (!previous) {
        map.set(raw.key, {
          label: keyToLabel(raw.key),
          type: 'text',
          ...raw,
        })
      } else {
        map.set(raw.key, {
          ...previous,
          ...raw,
          label: previous.label || raw.label || keyToLabel(raw.key),
          type: previous.esBase ? previous.type : mergeType(previous.type, raw.type),
          esBase: Boolean(previous.esBase || raw.esBase),
          esSugerido: Boolean(previous.esSugerido || raw.esSugerido),
          esPersonalizado: Boolean(previous.esPersonalizado || raw.esPersonalizado),
          frecuencia: Math.max(previous.frecuencia || 0, raw.frecuencia || 0),
          total_documentos: Math.max(previous.total_documentos || 0, raw.total_documentos || 0),
        })
      }
    }
  }
  return Array.from(map.values())
}

export function emptyValueForType(type) {
  if (type === 'list') return ['']
  if (type === 'phases') return [{ nombre: '', duracion_min: '', objetivos: '', descripcion: '' }]
  return ''
}

function normalizePhase(phase = {}) {
  return {
    nombre: phase.nombre ?? '',
    duracion_min: phase.duracion_min ?? '',
    objetivos: Array.isArray(phase.objetivos) ? phase.objetivos.join(', ') : (phase.objetivos ?? ''),
    descripcion: phase.descripcion ?? '',
  }
}

export function valueForForm(value, type) {
  if (value === undefined || value === null) return emptyValueForType(type)
  if (type === 'phases') {
    if (Array.isArray(value) && value.length) return value.map(normalizePhase)
    return emptyValueForType(type)
  }
  if (type === 'json') return JSON.stringify(value, null, 2)
  if (type === 'list') {
    if (Array.isArray(value)) return value.length ? value.map((item) => String(item)) : ['']
    return String(value).trim() ? [String(value)] : ['']
  }
  return value
}

export function buildInitialForm(fields = [], doc = {}, defaults = {}) {
  const form = {}
  for (const field of fields) {
    const sourceValue = doc[field.key] !== undefined ? doc[field.key] : defaults[field.key]
    form[field.key] = valueForForm(sourceValue, field.type)
  }
  return form
}

function cleanPhase(phase = {}) {
  const nombre = String(phase.nombre || '').trim()
  const descripcion = String(phase.descripcion || '').trim()
  const objetivosRaw = String(phase.objetivos || '').trim()
  const duracionRaw = String(phase.duracion_min ?? '').trim()
  const duracion = duracionRaw === '' ? null : Number(duracionRaw)

  const item = {}
  if (nombre) item.nombre = nombre
  if (Number.isFinite(duracion) && duracion > 0) item.duracion_min = duracion
  if (descripcion) item.descripcion = descripcion
  if (objetivosRaw) {
    item.objetivos = objetivosRaw
      .split(/\n|,/)
      .map((objetivo) => objetivo.trim())
      .filter(Boolean)
  }
  return item
}

export function valueForPayload(value, type, key) {
  if (type === 'number') {
    if (value === '' || value === null || value === undefined) return 0
    const parsed = Number(value)
    return Number.isFinite(parsed) ? parsed : 0
  }
  if (type === 'list') {
    if (!Array.isArray(value)) {
      return String(value || '')
        .split(/\n|,/)
        .map((item) => item.trim())
        .filter(Boolean)
    }
    return value.map((item) => String(item).trim()).filter(Boolean)
  }
  if (type === 'phases') {
    const list = Array.isArray(value) ? value : []
    return list
      .map(cleanPhase)
      .filter((phase) => Object.keys(phase).length > 0)
  }
  if (type === 'json') {
    const raw = String(value || '').trim()
    if (!raw) return null
    try {
      return JSON.parse(raw)
    } catch (err) {
      throw new Error(`Revisa el campo "${keyToLabel(key)}". El contenido no tiene un formato valido.`)
    }
  }
  return value === undefined || value === null ? '' : String(value)
}

export function buildPayload(fields = [], form = {}) {
  const payload = {}
  for (const field of fields) {
    if (!field?.key || ID_FIELDS.has(field.key)) continue
    payload[field.key] = valueForPayload(form[field.key], field.type, field.key)
  }
  return payload
}

export function hasUsefulValue(value, type) {
  if (type === 'number') return value !== '' && value !== null && value !== undefined
  if (type === 'list') return Array.isArray(value) && value.some((item) => String(item).trim())
  if (type === 'phases') {
    return Array.isArray(value) && value.some((phase) => Object.values(phase || {}).some((item) => String(item || '').trim()))
  }
  if (type === 'json') return String(value || '').trim().length > 0
  return String(value || '').trim().length > 0
}
