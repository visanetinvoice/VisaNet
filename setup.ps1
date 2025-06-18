# Task Tracker Automated Setup Script for Windows

# Create folders
New-Item -ItemType Directory -Force -Path .\backend
New-Item -ItemType Directory -Force -Path .\frontend

# --- Backend files ---
@'
{
  "name": "task-tracker-backend",
  "version": "1.0.0",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "express": "^4.18.2"
  }
}
'@ | Set-Content .\backend\package.json

@'
import express from "express";
import cors from "cors";

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

let tasks = [];
let id = 1;

app.get("/api/tasks", (req, res) => {
  res.json(tasks);
});

app.post("/api/tasks", (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ error: "Title is required" });
  const task = { id: id++, title };
  tasks.push(task);
  res.status(201).json(task);
});

app.delete("/api/tasks/:id", (req, res) => {
  const taskId = Number(req.params.id);
  tasks = tasks.filter((t) => t.id !== taskId);
  res.status(204).end();
});

app.listen(PORT, () => {
  console.log(`Backend API running at http://localhost:${PORT}`);
});
'@ | Set-Content .\backend\index.js

# --- Frontend files ---
@'
{
  "name": "task-tracker-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.0.0"
  }
}
'@ | Set-Content .\frontend\package.json

@'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      "/api": "http://localhost:3001"
    }
  }
});
'@ | Set-Content .\frontend\vite.config.js

@'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Task Tracker</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
'@ | Set-Content .\frontend\index.html

New-Item -ItemType Directory -Force -Path .\frontend\src

@'
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
'@ | Set-Content .\frontend\src\main.jsx

@'
import React, { useEffect, useState } from "react";

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    setLoading(true);
    const res = await fetch("/api/tasks");
    const data = await res.json();
    setTasks(data);
    setLoading(false);
  };

  const addTask = async () => {
    if (!input.trim()) return;
    setLoading(true);
    const res = await fetch("/api/tasks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: input }),
    });
    if (res.ok) {
      setInput("");
      fetchTasks();
    } else {
      setLoading(false);
    }
  };

  const deleteTask = async (id) => {
    setLoading(true);
    await fetch(`/api/tasks/${id}`, { method: "DELETE" });
    fetchTasks();
  };

  return (
    <div style={{ maxWidth: 500, margin: "2rem auto", fontFamily: "sans-serif" }}>
      <h1>Task Tracker</h1>
      <div style={{ display: "flex", gap: 8 }}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Add a new task"
          style={{ flex: 1, padding: 8 }}
          disabled={loading}
          onKeyDown={e => { if (e.key === 'Enter') addTask(); }}
        />
        <button onClick={addTask} disabled={loading || !input.trim()}>
          Add
        </button>
      </div>
      {loading && <p>Loading...</p>}
      <ul>
        {tasks.map((task) => (
          <li key={task.id} style={{ margin: "1rem 0", display: "flex", alignItems: "center", gap: 8 }}>
            <span>{task.title}</span>
            <button
              onClick={() => deleteTask(task.id)}
              disabled={loading}
              style={{ marginLeft: "auto" }}
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
'@ | Set-Content .\frontend\src\App.jsx

Write-Host "All files created!"

# --- Install dependencies ---
Write-Host "Installing backend dependencies..."
cd .\backend
npm install

Write-Host "Installing frontend dependencies..."
cd ..\frontend
npm install

Write-Host ""
Write-Host "Setup complete!"
Write-Host ""
Write-Host "To start the backend (in a new terminal):"
Write-Host "  cd backend"
Write-Host "  npm start"
Write-Host ""
Write-Host "To start the frontend (in a new terminal):"
Write-Host "  cd frontend"
Write-Host "  npm run dev"
Write-Host ""
Write-Host "Then open the printed URL (e.g., http://localhost:5173) in your browser."