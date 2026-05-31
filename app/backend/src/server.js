const os = require("os");
const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
const port = Number(process.env.PORT || 3000);

const pool = new Pool({
  host: process.env.PGHOST || "localhost",
  port: Number(process.env.PGPORT || 5432),
  database: process.env.PGDATABASE || "ticketsdb",
  user: process.env.PGUSER || "tickets",
  password: process.env.PGPASSWORD || "tickets",
  max: 10,
  idleTimeoutMillis: 30000
});

app.use(cors());
app.use(express.json());

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function initializeDatabase() {
  const ddl = `
    CREATE TABLE IF NOT EXISTS tickets (
      id SERIAL PRIMARY KEY,
      title VARCHAR(160) NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      priority VARCHAR(20) NOT NULL DEFAULT 'normale',
      status VARCHAR(20) NOT NULL DEFAULT 'ouvert',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );

    INSERT INTO tickets (title, description, priority, status)
    SELECT 'Incident portail client', 'Le portail client répond lentement depuis ce matin.', 'haute', 'ouvert'
    WHERE NOT EXISTS (SELECT 1 FROM tickets);

    INSERT INTO tickets (title, description, priority, status)
    SELECT 'Demande accès VPN', 'Créer un accès VPN pour un nouveau technicien support.', 'normale', 'en_cours'
    WHERE (SELECT COUNT(*) FROM tickets) = 1;
  `;

  for (let attempt = 1; attempt <= 20; attempt += 1) {
    try {
      await pool.query(ddl);
      return;
    } catch (error) {
      if (attempt === 20) {
        throw error;
      }
      console.log(`Base de données indisponible, nouvel essai ${attempt}/20...`);
      await sleep(1500);
    }
  }
}

function normalizeTicket(row) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    priority: row.priority,
    status: row.status,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

async function healthHandler(_req, res) {
  try {
    await pool.query("SELECT 1");
    res.json({
      status: "ok",
      service: "backend-api",
      hostname: os.hostname(),
      database: "connected",
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({
      status: "degraded",
      service: "backend-api",
      hostname: os.hostname(),
      database: "unavailable",
      error: error.message
    });
  }
}

app.get("/health", healthHandler);
app.get("/api/health", healthHandler);

app.get("/api/tickets", async (_req, res, next) => {
  try {
    const result = await pool.query(
      "SELECT * FROM tickets ORDER BY created_at DESC, id DESC"
    );
    res.json(result.rows.map(normalizeTicket));
  } catch (error) {
    next(error);
  }
});

app.post("/api/tickets", async (req, res, next) => {
  const title = String(req.body.title || "").trim();
  const description = String(req.body.description || "").trim();
  const priority = String(req.body.priority || "normale").trim();

  if (!title) {
    res.status(400).json({ error: "Le titre est obligatoire." });
    return;
  }

  try {
    const result = await pool.query(
      `INSERT INTO tickets (title, description, priority, status)
       VALUES ($1, $2, $3, 'ouvert')
       RETURNING *`,
      [title, description, priority]
    );
    res.status(201).json(normalizeTicket(result.rows[0]));
  } catch (error) {
    next(error);
  }
});

app.patch("/api/tickets/:id", async (req, res, next) => {
  const id = Number(req.params.id);
  const status = String(req.body.status || "").trim();
  const allowedStatuses = new Set(["ouvert", "en_cours", "resolu", "ferme"]);

  if (!Number.isInteger(id) || id <= 0) {
    res.status(400).json({ error: "Identifiant invalide." });
    return;
  }

  if (!allowedStatuses.has(status)) {
    res.status(400).json({ error: "Statut invalide." });
    return;
  }

  try {
    const result = await pool.query(
      `UPDATE tickets
       SET status = $1, updated_at = NOW()
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rowCount === 0) {
      res.status(404).json({ error: "Ticket introuvable." });
      return;
    }

    res.json(normalizeTicket(result.rows[0]));
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  console.error(error);
  res.status(500).json({
    error: "Erreur interne du backend.",
    detail: process.env.NODE_ENV === "production" ? undefined : error.message
  });
});

initializeDatabase()
  .then(() => {
    app.listen(port, "0.0.0.0", () => {
      console.log(`Backend Wendev tickets démarré sur le port ${port}`);
    });
  })
  .catch((error) => {
    console.error("Impossible d'initialiser la base de données", error);
    process.exit(1);
  });
