import { useNavigate } from 'react-router-dom'
import { useEffect, useState } from 'react'

export default function Home() {
  const navigate = useNavigate()
  const [user, setUser] = useState<{ name: string; email: string } | null>(null)

  useEffect(() => {
    const stored = localStorage.getItem('user')
    if (!stored) {
      navigate('/login')
      return
    }
    setUser(JSON.parse(stored))
  }, [])

  const handleLogout = () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-gray-950 flex items-center justify-center px-4">
      <div className="w-full max-w-md bg-gray-900 rounded-2xl shadow-lg p-8 border border-gray-800 text-center">

        {/* Avatar */}
        <div className="w-16 h-16 rounded-full bg-indigo-600 flex items-center justify-center text-2xl font-bold text-white mx-auto mb-4">
          {user?.name?.charAt(0).toUpperCase()}
        </div>

        <h1 className="text-2xl font-bold text-white mb-1">
          Welcome, {user?.name}! 👋
        </h1>
        <p className="text-gray-400 text-sm mb-2">{user?.email}</p>

        <div className="bg-green-500/10 border border-green-500/30 text-green-400 text-sm px-4 py-2 rounded-lg inline-block mb-8">
          ✅ Successfully logged in 
        </div>

        

        <button
          onClick={handleLogout}
          className="w-full bg-gray-800 hover:bg-gray-700 text-gray-300 font-medium py-3 rounded-lg transition text-sm border border-gray-700"
        >
          Logout
        </button>
      </div>
    </div>
  )
}