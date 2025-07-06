const { sendEmail, sendOverdueReminder } = require("../services/mail.service");

// Simple test endpoint to send a generic email
exports.sendTestEmail = async (req, res) => {
  try {
    await sendEmail(
      "test@example.com", // You can change this to your test email
      "📢 Test Notification",
      "This is a test notification sent from the Library system."
    );
    res.json({ message: "Test email sent successfully!" });
  } catch (error) {
    console.error("❌ Error sending test email:", error);
    res.status(500).json({ message: "Failed to send test email." });
  }
};

// Another test for overdue reminder email
exports.sendTestReminder = async (req, res) => {
  try {
    await sendOverdueReminder(
      "student@example.com",        // Replace with a real/test email
      "John Doe",                   // Student's name
      "Introduction to AI",         // Book title
      new Date("2025-07-01")        // Due date
    );
    res.json({ message: "Test reminder email sent." });
  } catch (error) {
    console.error("❌ Error sending reminder:", error);
    res.status(500).json({ message: "Failed to send reminder." });
  }
};
