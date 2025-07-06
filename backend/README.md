# Library Management System - Backend

## Overview

This is the backend REST API for the Library Management System project. It is built with Node.js, Express, and MongoDB to provide secure and scalable services for managing users, books, borrowings, and reservations. The backend supports role-based access for students and administrators.

---

## Features

- User registration with email verification
- Secure login with JWT authentication
- Password reset via email
- Role-based authorization (student/admin)
- Book inventory management (CRUD)
- Borrowing and returning books with due dates
- Reservation system with queue, expiration, and notifications
- Admin and student dashboards with analytics
- Email notifications for key user actions
- Input validation, rate limiting, and security best practices

---

## Tech Stack

- **Node.js** & **Express.js** — Server and API framework
- **MongoDB** & **Mongoose** — Database and ODM
- **JWT** — Authentication tokens
- **bcrypt** — Password hashing
- **Nodemailer** — Email notifications
- **Express-validator** — Input validation
- **Helmet & CORS** — Security middleware
- **express-rate-limit** — Rate limiting to prevent abuse

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) v16+
- [MongoDB](https://www.mongodb.com/) (local or Atlas)
- An SMTP email service (Gmail, SendGrid, etc.) for sending emails

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/library-management-backend.git
   cd library-management-backend
   
Install dependencies:
npm install

Create a .env file in the root directory and add the following environment variables:

PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
CLIENT_URL=http://localhost:3000
EMAIL_HOST=smtp.example.com
EMAIL_PORT=587
EMAIL_USER=your_email@example.com
EMAIL_PASS=your_email_password


Start the server:
npm run dev
The API will be available at http://localhost:5000/api

API Documentation
The API base path is /api

Authentication endpoints under /api/auth

Book management under /api/books

Borrowings under /api/borrowings

Reservations under /api/reservations

Dashboards under /api/dashboard


Project Structure

backend/
├── config/            # Database and auth config
├── controllers/       # Route handlers and business logic
├── middleware/        # Custom middleware (auth, validation, rate limiting)
├── models/            # Mongoose schemas
├── routes/            # API routes
├── utils/             # Utility functions (email sending, etc.)
├── app.js             # Express app setup
└── server.js          # Server startup


Security
Passwords are hashed with bcrypt (12 salt rounds)

JWT tokens secure authentication and expire after 7 days

Rate limiting protects login and password reset endpoints

Helmet and CORS are used to set HTTP security headers

Input validation with express-validator to prevent injection attacks

Testing
Use Postman or Insomnia with the provided collection to test API endpoints

Further unit and integration tests can be added with Jest or Mocha


License
MIT License