// src/api/auth.api.js
import api from './api'

export const loginApi       = (cedula, contrasena) => api.post('/auth/login', { cedula, contrasena })
export const logoutApi      = ()                   => api.post('/auth/logout')
export const meApi          = ()                   => api.get('/auth/me')