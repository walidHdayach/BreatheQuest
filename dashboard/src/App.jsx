import { useState, useEffect } from 'react'
import { initializeApp } from 'firebase/app'
import { getFirestore, collection, getDocs, doc, getDoc } from 'firebase/firestore'

// Replace with your Firebase config (same as Flutter app)
const firebaseConfig = {
  apiKey: 'YOUR_API_KEY',
  authDomain: 'YOUR_PROJECT.firebaseapp.com',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT.appspot.com',
  messagingSenderId: 'YOUR_SENDER_ID',
  appId: 'YOUR_APP_ID',
}

const app = initializeApp(firebaseConfig)
const db = getFirestore(app)

export default function App() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    async function load() {
      try {
        const usersSnap = await getDocs(collection(db, 'users'))
        const list = []
        for (const u of usersSnap.docs) {
          const d = u.data()
          const sessionsSnap = await getDocs(collection(db, `users/${u.id}/sessions`))
          const sessions = sessionsSnap.docs.map(s => ({ id: s.id, ...s.data() }))
          list.push({
            id: u.id,
            displayName: d.displayName ?? d.email ?? u.id,
            email: d.email,
            streak: d.streak ?? 0,
            totalMinutes: d.totalMinutes ?? 0,
            badges: d.badges ?? [],
            sessionsCount: sessions.length,
            sessions,
          })
        }
        setUsers(list)
      } catch (e) {
        setError(e.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  if (loading) return <div className="loading">Chargement…</div>
  if (error) return <div className="error">Erreur: {error}. Vérifiez la config Firebase et les règles Firestore (lecture admin ou émulateur).</div>

  const totalSessions = users.reduce((a, u) => a + u.sessionsCount, 0)
  const totalMinutes = users.reduce((a, u) => a + (u.totalMinutes || 0), 0)

  return (
    <div className="dashboard">
      <h1>BreatheQuest – Dashboard</h1>
      <p className="tagline">Respire. Joue. Récupère.</p>
      <div className="stats">
        <div className="card">
          <strong>{users.length}</strong>
          <span>Utilisateurs</span>
        </div>
        <div className="card">
          <strong>{totalSessions}</strong>
          <span>Sessions totales</span>
        </div>
        <div className="card">
          <strong>{totalMinutes}</strong>
          <span>Minutes totales</span>
        </div>
      </div>
      <h2>Par utilisateur</h2>
      <div className="user-list">
        {users.map((u) => (
          <div key={u.id} className="user-card card">
            <h3>{u.displayName}</h3>
            {u.email && <p className="email">{u.email}</p>}
            <ul>
              <li>Série: <strong>{u.streak}</strong></li>
              <li>Minutes: <strong>{u.totalMinutes}</strong></li>
              <li>Sessions: <strong>{u.sessionsCount}</strong></li>
              <li>Badges: {u.badges.join(', ') || '—'}</li>
            </ul>
          </div>
        ))}
      </div>
    </div>
  )
}
