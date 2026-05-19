// src/api/catalogos.api.js
import { api } from './api'

export const getLugares = () => api.get('/api/lugares')
export const getCategorias = () => api.get('/api/categorias')
export const createCategoria = (data) => api.post('/api/categorias', data)
export const updateCategoria = (id, data) => api.put(`/api/categorias/${id}`, data)
export const deleteCategoria = (id) => api.delete(`/api/categorias/${id}`)
