import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Login from './screens/Login'
import Signup from './screens/Signup'
import Home from './screens/Home'

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/login" />} />
        <Route path="/login" element={<Login />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/home" element={<Home />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App