# Project Documentation: Library Borrowing System

## 1. Project Description

The Library Borrowing System is a comprehensive application designed to streamline the process of managing and borrowing library books. This project addresses the needs of both mobile development and web services with REST API development. It aims to replicate real-world library workflows for students and administrators, focusing on ease of use and clear organization. The system facilitates efficient book management, borrowing transactions, and user role administration.

## 2. Functional Requirements

### 2.1. Users (Students)

The system provides the following functionalities for regular users (students):

- **Register/Login**: Users can create new accounts and log in to access the system.

- **Search Books**: Users can search for books by title, author, or genre to find desired materials.

- **Borrow or Reserve Books**: Users have the ability to borrow available books or reserve books that are currently checked out.

- **View Current Loans and History**: Users can view a list of books they currently have borrowed and review their past borrowing history.

- **Get Reminders**: The system sends reminders for return deadlines to help users manage their borrowed books.

### 2.2. Admins

Administrators have elevated privileges to manage the library system:

- **Add/Edit/Remove Books**: Admins can add new books to the inventory, edit existing book details, or remove books from the system.

- **Update Availability Status**: Admins can update the availability status of books (e.g., mark as lost, damaged, or available).

- **Track Borrow/Return Events**: Admins can monitor and track all borrowing and return transactions within the system.

- **Manage Book Inventory**: Admins are responsible for overseeing the entire book collection.

- **View Borrowing Activity Logs**: Admins can access detailed logs of all borrowing activities.

- **Update Borrowing Rules or Limits**: Admins can modify the rules and limits associated with borrowing books (e.g., maximum number of books, borrowing duration).

## 3. Technical Requirements

### 3.1. Backend (Node.js + Express + MongoDB)

The backend of the Library Borrowing System is built using Node.js, Express, and MongoDB, providing a robust and scalable foundation for the application:

- **REST API with Endpoints**: A comprehensive RESTful API is implemented with dedicated endpoints for managing users, books, and loan transactions.

- **JWT-based Authentication and Role-based Access**: JSON Web Token (JWT) is used for secure user authentication, and role-based access control ensures that users can only access functionalities permitted by their assigned roles (e.g., student, admin).

- **Reminder Logic for Due Dates**: The backend incorporates logic to send automated reminders to users about upcoming due dates for borrowed books.

- **Optional: Book Tagging and Categorization**: The system supports optional features for tagging and categorizing books, enhancing searchability and organization.

### 3.2. Mobile App (Flutter)

The mobile application is developed using Flutter, ensuring a cross-platform and responsive user experience:

- **Book Catalog with Filters and Search**: The app provides a user-friendly interface to browse the library catalog, complete with filtering and search capabilities to quickly find books.

- **Book Detail and Availability View**: Users can view detailed information about each book, including its availability status.

- **Borrow/Reserve Button with Confirmation**: A clear and intuitive button allows users to borrow or reserve books, with a confirmation step to prevent accidental actions.

- **Dashboard for Active and Past Loans**: A personalized dashboard displays the user's active loans and a history of past borrowing activities.

## 4. Sample Database Schema

The database schema is designed to store information about users, books, and borrowing transactions. The following outlines the structure of the main collections:

### 4.1. Users

```json
{
  "name": "string",
  "email": "string",
  "password": "hashed",
  "role": "student | admin"
}
```

### 4.2. Books

```json
{
  "title": "string",
  "author": "string",
  "genre": "string",
  "status": "available | borrowed | reserved",
  "addedBy": "ref to Users"
}
```

### 4.3. Borrowings

```json
{
  "userId": "ref to Users",
  "bookId": "ref to Books",
  "borrowDate": "ISODate",
  "returnDate": "ISODate",
  "status": "active | returned | overdue"
}
```



## 7. API Documentation

This section details the RESTful API endpoints provided by the backend, built using Node.js and Express. The API facilitates communication between the mobile application and the database, handling user authentication, book management, and borrowing processes. All API interactions are secured with JWT-based authentication and implement role-based access control.

### 7.1. Authentication and User Management (auth.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Rate Limit Applied |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :----------------- |
| `POST` | `/api/auth/register`         | Registers a new user account.                  | None           | No                 |
| `POST` | `/api/auth/login`            | Authenticates a user and returns a JWT.        | None           | Yes                |
| `POST` | `/api/auth/resend-verification` | Resends email verification link.               | None           | Yes                |
| `GET`  | `/api/auth/verify-email/:token` | Verifies user's email address using a token.   | None           | No                 |
| `POST` | `/api/auth/forgot-password`  | Initiates password reset process.              | None           | Yes                |
| `POST` | `/api/auth/reset-password/:token` | Resets user's password using a token.          | None           | No                 |
| `PUT`  | `/api/auth/profile`          | Updates the authenticated user's profile.      | Required       | No                 |





### 7.2. Book Management (book.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `GET`  | `/api/books/`                | Retrieves a list of all books.                 | None           | None          |
| `GET`  | `/api/books/:id`             | Retrieves a single book by its ID.             | None           | None          |
| `POST` | `/api/books/`                | Creates a new book entry.                      | Required       | `admin`       |
| `PUT`  | `/api/books/:id`             | Updates an existing book entry by its ID.      | Required       | `admin`       |
| `DELETE` | `/api/books/:id`             | Deletes a book entry by its ID.                | Required       | `admin`       |





### 7.3. Borrowing Management (borrowing.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `POST` | `/api/borrowings/`           | Allows a user to borrow a book.                | Required       | `student`     |
| `PUT`  | `/api/borrowings/:id/return` | Marks a borrowed book as returned.             | Required       | `student`, `admin` |
| `PUT`  | `/api/borrowings/:id/renew`  | Allows a user to renew a borrowed book.        | Required       | `student`     |
| `GET`  | `/api/borrowings/user/:userId` | Retrieves all borrowings for a specific user.  | Required       | `student`, `admin` |
| `GET`  | `/api/borrowings/`           | Retrieves all borrowing records.               | Required       | `admin`       |
| `GET`  | `/api/borrowings/overdue`    | Retrieves all overdue borrowing records.       | Required       | `admin`       |
| `POST` | `/api/borrowings/overdue/remind` | Sends overdue reminders to users.              | Required       | `admin`       |





### 7.4. Dashboard (dashboard.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `GET`  | `/api/dashboard/student/:userId` | Retrieves dashboard data for a specific student. | Required       | `student`, `admin` |
| `GET`  | `/api/dashboard/admin/overview` | Retrieves an overview for the admin dashboard. | Required       | `admin`       |
| `GET`  | `/api/dashboard/admin/analytics` | Retrieves analytics data for the admin dashboard. | Required       | `admin`       |
| `GET`  | `/api/dashboard/admin/overview/top-borrowers` | Retrieves a list of top borrowers for admin. | Required       | `admin`       |





### 7.5. Notification (notification.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `GET`  | `/api/notifications/test`    | Sends a test email.                            | None           | None          |
| `GET`  | `/api/notifications/reminder` | Sends a test reminder.                         | None           | None          |





### 7.6. Reservation Management (reservation.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `POST` | `/api/reservations/`         | Allows a user to reserve a book.               | Required       | `student`     |
| `GET`  | `/api/reservations/user/:userId` | Retrieves all reservations for a specific user. | Required       | `student`, `admin` |
| `PUT`  | `/api/reservations/:id/cancel` | Cancels an existing book reservation.          | Required       | `student`, `admin` |
| `GET`  | `/api/reservations/queue/:bookId` | Retrieves the reservation queue for a book.    | Required       | `admin`       |
| `PUT`  | `/api/reservations/:id/fulfill` | Fulfills a book reservation.                   | Required       | `admin`       |
| `PUT`  | `/api/reservations/expire/check` | Expires old reservations (can be cron job).    | Required       | `admin`       |
| `GET`  | `/api/reservations/`         | Retrieves all reservation records.             | Required       | `admin`       |





### 7.7. User Management (user.routes.js)

| Method | Endpoint                     | Description                                    | Authentication | Role Required |
| :----- | :--------------------------- | :--------------------------------------------- | :------------- | :------------ |
| `GET`  | `/api/users/`                | Retrieves a list of all users.                 | Required       | `admin`       |



