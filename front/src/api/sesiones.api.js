// src/api/sesiones.api.js  - planes, estadisticas y observaciones (MongoDB)
import { api } from './api'

// Planes de sesion
export const getCamposPlan = (id) => api.get(`/api/sesion/planes/campos-comunes${id ? `?id_entrenamiento=${id}` : ''}`)
export const getPlan = (id) => api.get(`/api/sesion/${id}`)
export const createPlan = (id, data) => api.post(`/api/sesion/${id}`, data)
export const updatePlan = (id, data) => api.put(`/api/sesion/${id}`, data)
export const deletePlan = (id) => api.delete(`/api/sesion/${id}`)

// Estadisticas
export const getCamposEstadisticas = (id) => api.get(`/api/sesion/estadisticas/campos-comunes${id ? `?id_entrenamiento=${id}` : ''}`)
export const getEstadisticasSesion = (id) => api.get(`/api/sesion/estadisticas/${id}`)
export const saveEstadisticasSesion = (id, data) => api.post(`/api/sesion/estadisticas/${id}`, data)
export const deleteEstadisticasSesion = (id) => api.delete(`/api/sesion/estadisticas/${id}`)
export const getEstadisticasJugador = (cedula) => api.get(`/api/sesion/estadisticas/jugador/${cedula}`)

// Observaciones post-sesion
export const getCamposObservaciones = (id) => api.get(`/api/sesion/observaciones/campos-comunes${id ? `?id_entrenamiento=${id}` : ''}`)
export const getObservaciones = (id) => api.get(`/api/sesion/observaciones/${id}`)
export const saveObservaciones = (id, data) => api.post(`/api/sesion/observaciones/${id}`, data)
export const deleteObservaciones = (id) => api.delete(`/api/sesion/observaciones/${id}`)
