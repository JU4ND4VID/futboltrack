// src/components/PrivateRoute.jsx
// Protege rutas privadas verificando si hay sesión en localStorage.
// MainLayout hace una validación adicional con el servidor al montar.
import { Navigate } from 'react-router-dom'

export default function PrivateRoute({ children }) {
  const hayUsuario = Boolean(localStorage.getItem('ft_user'))
  return hayUsuario ? children : <Navigate to="/login" replace />
}
