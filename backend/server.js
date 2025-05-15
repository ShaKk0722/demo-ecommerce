// backend/server.js
import express from 'express';
import helmet from 'helmet';
import morgan from 'morgan';
import cors from 'cors';
import dotenv from 'dotenv';
import pool from './db/db.js';

import initRoutes from './routes/index.routes.js';

dotenv.config();
const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));

app.get('/test', (req, res) => {
  res.send('Hello from backend!');
});

app.get('/testdb', async (req, res) => {
  const result = await pool.query('SELECT current_database()');
  res.send(`The database name is: ${result.rows[0].current_database}`);
});

initRoutes(app);

app.listen(PORT, () => {
  console.log(`Server is running on PORT ${PORT}`);
});
