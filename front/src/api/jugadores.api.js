// src/api/jugadores.api.js
import api from './api'

export const getJugadores    = ()             => api.get('/jugadores/')
export const getJugador      = (cedula)       => api.get(`/jugadores/${cedula}`)
export const createJugador   = (data)         => api.post('/jugadores/', data)
export const updateJugador   = (cedula, data) => api.put(`/jugadores/${cedula}`, data)
export const deleteJugador   = (cedula)       => api.delete(`/jugadores/${cedula}`)