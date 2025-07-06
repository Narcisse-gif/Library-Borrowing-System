const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
const connectDB = require('./config/db');
require('dotenv').config();

const app = express();

// Connect to database
connectDB();

// Middleware
app.use(express.json());
app.use(cors());
app.use(helmet());

// Serve uploaded files (images, etc)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Basic root route
app.get('/', (req, res) => {
  res.send('Library API is running...');
});

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/books', require('./routes/book.routes'));
app.use('/api/borrowings', require('./routes/borrowing.routes'));
app.use('/api/reservations', require('./routes/reservation.routes'));
app.use('/api/dashboard', require('./routes/dashboard.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/notifications', require('./routes/notification.routes')); // Assuming you have this route file

// Error handling middleware (optional but recommended)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal server error' });
});

module.exports = app;
