const { Pool } = require("pg");

// All config comes from environment variables (set these in your infra / docker run / task def)
const pool = new Pool({
  host: process.env.DB_HOST,        // e.g. mydb.xxxxxx.rds.amazonaws.com
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: process.env.DB_SSL === "false" ? false : { rejectUnauthorized: false }, // RDS usually needs SSL
});

// Create the items table if it doesn't exist yet
async function init() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS items (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    );
  `);
}

module.exports = { pool, init };
