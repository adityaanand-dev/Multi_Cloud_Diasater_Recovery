const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Database connection pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'drapp',
  user: process.env.DB_USER || 'dbadmin',
  password: process.env.DB_PASSWORD || 'password',
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// Health check endpoint
app.get('/health', async (req, res) => {
  let dbStatus = 'disconnected';
  try {
    await pool.query('SELECT 1');
    dbStatus = 'connected';
  } catch (err) {
    dbStatus = `error: ${err.message}`;
  }

  res.json({
    status: 'healthy',
    service: 'backend',
    cloud: process.env.CLOUD_PROVIDER || 'unknown',
    region: process.env.CLOUD_REGION || 'unknown',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    database: dbStatus,
    uptime: process.uptime(),
  });
});

// Sample API endpoints
app.get('/api/status', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as current_time, current_database() as db_name');
    res.json({
      cloud: process.env.CLOUD_PROVIDER || 'unknown',
      region: process.env.CLOUD_REGION || 'unknown',
      database: result.rows[0],
      instance: os.hostname(),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/dr-status', (req, res) => {
  res.json({
    primary: {
      cloud: 'AWS',
      region: 'ap-south-1',
      status: process.env.CLOUD_PROVIDER === 'aws' ? 'active' : 'standby',
    },
    secondary: {
      cloud: 'Azure',
      region: 'centralindia',
      status: process.env.CLOUD_PROVIDER === 'azure' ? 'active' : 'standby',
    },
    failover: {
      type: 'DNS-based automatic',
      rto_target: '<5 minutes',
      rpo_target: '<5 minutes',
    },
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Multi-Cloud DR Backend running on port ${PORT}`);
  console.log(`Cloud: ${process.env.CLOUD_PROVIDER || 'local'}`);
  console.log(`Region: ${process.env.CLOUD_REGION || 'local'}`);
});
