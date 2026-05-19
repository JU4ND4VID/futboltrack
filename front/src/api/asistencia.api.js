// src/api/asistencia.api.js
import api from './api'

// asistencias = [{ identificacion_jugador, estado_asistencia, observacion }]
export const getAsistencia  = (idEntrenamiento)              => api.get(`/asistencia/${idEntrenamiento}`)
export const saveAsistencia = (idEntrenamiento, asistencias) => api.post(`/asistencia/${idEntrenamiento}`, asistencias)