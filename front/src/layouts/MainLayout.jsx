// src/layouts/MainLayout.jsx
import { useEffect, useState } from 'react'
import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import {
  MdCalendarMonth,
  MdPeople,
  MdFitnessCenter,
  MdChecklist,
  MdBarChart,
  MdSportsScore,
  MdNoteAlt,
  MdLogout,
  MdManageAccounts
} from 'react-icons/md'
import { authApi } from '../api/api'
import './MainLayout.css'

const NAV_BASE = [
  { to: '/cronograma',     label: 'Cronograma',        icon: <MdCalendarMonth /> },
  { to: '/jugadores',      label: 'Jugadores',          icon: <MdPeople /> },
  { to: '/entrenamientos', label: 'Entrenamientos',     icon: <MdFitnessCenter /> },
  { to: '/asistencia',     label: 'Asistencia',         icon: <MdChecklist /> },
  { to: '/estadisticas',   label: 'Estadísticas',       icon: <MdBarChart /> },
  { to: '/sesion',         label: 'Plan de Sesión',     icon: <MdSportsScore /> },
  { to: '/observaciones',  label: 'Observaciones',      icon: <MdNoteAlt /> },
]

const NAV_ADMIN_EXTRA = [
  { to: '/entrenadores', label: 'Entrenadores', icon: <MdManageAccounts /> },
]

function MainLayout() {
  const navigate = useNavigate()
  const [usuario, setUsuario] = useState(null)

  useEffect(() => {
    const cached = localStorage.getItem('ft_user')
    if (cached) {
      setUsuario(JSON.parse(cached))
    }

    authApi.me()
  .then(data => {
    const u = {
      cedula:           data.cedula,
      nombre:           data.nombre,
      apellido:         data.apellido,
      id_categoria:     data.id_categoria,
      categoria_nombre: data.categoria_nombre,
      tipo_usuario:     data.tipo_usuario,      // ← admin | entrenador
    }
    setUsuario(u)
    localStorage.setItem('ft_user', JSON.stringify(u))
  })
  .catch(() => {
    localStorage.removeItem('ft_user')
    navigate('/login', { replace: true })
  })
  }, [navigate])

  async function handleLogout() {
    try {
      await authApi.logout()
    } catch {
      // Ignorar errores de red — cerramos sesión de todos modos
    }
    localStorage.removeItem('ft_user')
    navigate('/login', { replace: true })
  }

  const esAdmin  = usuario?.tipo_usuario === 'admin'
  const navItems = esAdmin ? [...NAV_BASE, ...NAV_ADMIN_EXTRA] : NAV_BASE

  const inicial = usuario?.nombre?.[0]?.toUpperCase() ?? 'E'
  const nombreCompleto = usuario
    ? `${usuario.nombre} ${usuario.apellido}`
    : 'Entrenador'

  return (
    <div className="layout">

      {/* ── Sidebar ── */}
      <aside className="sidebar">
        <div className="sidebar__brand">
          <span className="sidebar__brand-icon">⚽</span>
          <span className="sidebar__brand-name">FutbolTrack</span>
        </div>

        <nav className="sidebar__nav">
          {navItems.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive }) =>
                'sidebar__link' + (isActive ? ' sidebar__link--active' : '')
              }
            >
              <span className="sidebar__link-icon">{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          ))}
        </nav>

        <button className="sidebar__logout" onClick={handleLogout}>
          <MdLogout />
          <span>Cerrar sesión</span>
        </button>
      </aside>

      {/* ── Contenido principal ── */}
      <div className="main">
        <header className="topbar">
          <h1 className="topbar__title">FutbolTrack</h1>
          <div className="topbar__user">
            <span className="topbar__avatar">{inicial}</span>
            <span className="topbar__name">{nombreCompleto}</span>
          </div>
        </header>

        <main className="content">
          <Outlet />
        </main>
      </div>

    </div>
  )
}

export default MainLayout