// src/pages/login/LoginPage.jsx
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { authApi } from '../../api/api'
import './LoginPage.css'

function LoginPage() {
  const navigate = useNavigate()
  const [cedula, setCedula]         = useState('')
  const [contrasena, setContrasena] = useState('')
  const [error, setError]           = useState('')
  const [cargando, setCargando]     = useState(false)

  async function handleLogin() {
    if (!cedula.trim() || !contrasena) {
      setError('Por favor completa todos los campos.')
      return
    }

    setCargando(true)
    setError('')

    try {
      const data = await authApi.login(cedula.trim(), contrasena)

      // Guardar datos del entrenador en localStorage para mostrar en el layout
      localStorage.setItem('ft_user', JSON.stringify(data.entrenador))

      navigate('/cronograma', { replace: true })
    } catch (err) {
      setError(err.message || 'Error al conectar con el servidor.')
      setContrasena('')
    } finally {
      setCargando(false)
    }
  }

  function handleKeyDown(e) {
    if (e.key === 'Enter') handleLogin()
  }

  return (
    <div className="login">
      <div className="login__card">

        <div className="login__header">
          <span className="login__icon">⚽</span>
          <h1 className="login__title">FutbolTrack</h1>
          <p className="login__subtitle">Sistema de Gestión de Entrenamientos</p>
        </div>

        <div className="login__form">
          <div className="login__field">
            <label className="login__label">Cédula</label>
            <input
              className="login__input"
              type="text"
              placeholder="Número de documento"
              value={cedula}
              onChange={e => setCedula(e.target.value)}
              onKeyDown={handleKeyDown}
              autoFocus
            />
          </div>

          <div className="login__field">
            <label className="login__label">Contraseña</label>
            <input
              className="login__input"
              type="password"
              placeholder="Contraseña"
              value={contrasena}
              onChange={e => setContrasena(e.target.value)}
              onKeyDown={handleKeyDown}
            />
          </div>

          {error && (
            <div className="login__error" role="alert">{error}</div>
          )}

          <button
            className="login__btn"
            onClick={handleLogin}
            disabled={cargando}
          >
            {cargando ? 'Ingresando...' : 'Ingresar'}
          </button>
        </div>

        <p className="login__footer">Universidad El Bosque · Bases de Datos II</p>
      </div>
    </div>
  )
}

export default LoginPage
