// src/App.jsx
import { Routes, Route, Navigate } from 'react-router-dom'
import PrivateRoute from './components/PrivateRoute'

import MainLayout         from './layouts/MainLayout'
import LoginPage          from './pages/login/LoginPage'
import CronogramaPage     from './pages/cronograma/CronogramaPage'
import JugadoresPage      from './pages/jugadores/JugadoresPage'
import EntrenamientosPage from './pages/entrenamientos/EntrenamientosPage'
import AsistenciaPage     from './pages/asistencia/AsistenciaPage'
import EstadisticasPage   from './pages/estadisticas/EstadisticasPage'
import SesionPage         from './pages/sesion/SesionPage'
import ObservacionesPage   from './pages/observaciones/ObservacionesPage'
import EntrenadoresPage   from './pages/entrenadores/EntrenadoresPage'

function App() {
  return (
    <Routes>

      {/* Pública */}
      <Route path="/login" element={<LoginPage />} />

      {/* Privadas — todas dentro del layout con sidebar */}
      <Route
        path="/"
        element={
          <PrivateRoute>
            <MainLayout />
          </PrivateRoute>
        }
      >
        <Route index element={<Navigate to="/cronograma" replace />} />
        <Route path="cronograma"     element={<CronogramaPage />} />
        <Route path="jugadores"      element={<JugadoresPage />} />
        <Route path="entrenamientos" element={<EntrenamientosPage />} />
        <Route path="asistencia"     element={<AsistenciaPage />} />
        <Route path="estadisticas"   element={<EstadisticasPage />} />
        <Route path="sesion"         element={<SesionPage />} />
        <Route path="observaciones"  element={<ObservacionesPage />} />
        <Route path="entrenadores"   element={<EntrenadoresPage />} />
      </Route>

      <Route path="*" element={<Navigate to="/cronograma" replace />} />

    </Routes>
  )
}

export default App