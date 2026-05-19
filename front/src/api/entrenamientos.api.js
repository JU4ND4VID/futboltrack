// src/api/entrenamientos.api.js
import api from './api'

export const getEntrenamientos        = ()             => api.get('/entrenamientos/')
export const getEntrenamiento         = (id)           => api.get(`/entrenamientos/${id}`)
export const createEntrenamiento      = (data)         => api.post('/entrenamientos/', data)
export const updateEstadoEntrenamiento = (id, estado)  => api.put(`/entrenamientos/${id}`, { estado })
export const deleteEntrenamiento      = (id)           => api.delete(`/entrenamientos/${id}`)