// src/context/AuthContext.jsx
import { createContext, useContext, useState, useEffect, useCallback } from 'react'
import { meApi, loginApi, logoutApi } from '../api/auth.api'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user,    setUser]    = useState(null)   // { cedula, nombre, apellido }
  const [loading, setLoading] = useState(true)   // true mientras verifica sesión al arrancar

  // Al montar la app: preguntarle al backend si ya hay sesión activa (cookie)
  useEffect(() => {
    meApi()
      .then(({ data }) => { if (data.ok) setUser(data) })
      .catch(() => setUser(null))      // 401 = no hay sesión, es normal
      .finally(() => setLoading(false))
  }, [])

  const login = useCallback(async (cedula, contrasena) => {
    const { data } = await loginApi(cedula, contrasena)
    if (data.ok) setUser(data.entrenador)
    return data   // { ok, entrenador } | { ok: false, mensaje }
  }, [])

  const logout = useCallback(async () => {
    await logoutApi()
    setUser(null)
  }, [])

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

// Hook: const { user, login, logout, loading } = useAuth()
export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth debe usarse dentro de <AuthProvider>')
  return ctx
}
