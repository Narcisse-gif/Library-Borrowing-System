const cron = require("node-cron");
const Reservation = require("../models/reservation.model");
const Borrowing = require("../models/borrowing.model");
const User = require("../models/user.model");
const Book = require("../models/book.model");
const sendEmail = require("../services/mail.service");

if (process.env.ENABLE_CRON === "true") {
  console.log("🔁 Cron jobs enabled");

  // ⏰ Expire reservations every 30 minutes
  cron.schedule("*/30 * * * *", async () => {
    try {
      console.log("⏰ [Reservation] Checking for expired reservations...");
      const now = new Date();

      const expired = await Reservation.find({
        expirationDate: { $lt: now },
        status: "active",
      }).populate("userId").populate("bookId");

      for (const r of expired) {
        r.status = "expired";
        await r.save();

        await sendEmail(
          r.userId.email,
          "Reservation Expired",
          `Your reservation for "${r.bookId.title}" has expired and is no longer valid.`
        );
      }

      console.log(`✅ [Reservation] ${expired.length} expired and notified.`);
    } catch (err) {
      console.error("❌ [Reservation] Cron error:", err.message);
    }
  });

  // ⏰ Check overdue borrowings every night at 00:30
  cron.schedule("30 0 * * *", async () => {
    try {
      console.log("⏰ [Borrowing] Checking for overdue books...");
      const now = new Date();

      const overdue = await Borrowing.find({
        dueDate: { $lt: now },
        status: "active",
      }).populate("userId").populate("bookId");

      for (const b of overdue) {
        b.status = "overdue";
        await b.save();

        await sendEmail(
          b.userId.email,
          "Book Overdue Notice",
          `The book "${b.bookId.title}" you borrowed is now overdue. Please return it immediately to avoid penalties.`
        );
      }

      console.log(`📢 [Borrowing] ${overdue.length} overdue notices sent.`);
    } catch (err) {
      console.error("❌ [Borrowing] Cron error:", err.message);
    }
  });
} else {
  console.log("⚠️ Cron jobs disabled via .env");
}
