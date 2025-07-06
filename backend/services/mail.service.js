const nodemailer = require("nodemailer");

// MailDev transport configuration
const transporter = nodemailer.createTransport({
  host: "localhost",
  port: 1025,
  ignoreTLS: true,
});

/**
 * Generic email sender
 */
async function sendEmail(to, subject, text) {
  await transporter.sendMail({
    from: '"Library Admin 📚" <no-reply@library.local>',
    to,
    subject,
    text,
  });
}

/**
 * Send overdue book reminder
 */
async function sendOverdueReminder(to, userName, bookTitle, dueDate) {
  const message = `
Hello ${userName},

This is a friendly reminder that the book "${bookTitle}" you borrowed is overdue since ${new Date(dueDate).toLocaleDateString()}.

Please return the book as soon as possible to avoid penalties.

Thank you,
Library Management
  `;

  await sendEmail(to, "📚 Overdue Book Reminder", message);
}

module.exports = {
  sendEmail,
  sendOverdueReminder,
};
