const Borrowing = require("../models/borrowing.model");
const Book = require("../models/book.model");
const Reservation = require("../models/reservation.model");
const User = require("../models/user.model");
const { sendEmail, sendOverdueReminder } = require("../services/mail.service");

// POST: Borrow a book
exports.borrowBook = async (req, res) => {
  const userId = req.user.id;
  const { bookId } = req.body;
  try {
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ message: "Book not found" });
    if (book.status !== "available")
      return res.status(400).json({ message: "Book is not available" });

    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 14);

    const b = await Borrowing.create({ userId, bookId, dueDate });

    book.status = "borrowed";
    book.currentBorrower = userId;
    book.borrowCount += 1;
    await book.save();

    const populated = await Borrowing.findById(b._id)
      .populate("bookId", "title author")
      .populate("userId", "name email");

    res.status(201).json({
      id: populated._id,
      book: populated.bookId,
      user: populated.userId,
      borrowDate: populated.borrowDate?.toISOString(),
      dueDate: populated.dueDate?.toISOString(),
      returnDate: populated.returnDate?.toISOString() || null,
      status: populated.status,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

// PUT: Return a book
exports.returnBook = async (req, res) => {
  try {
    const b = await Borrowing.findById(req.params.id);
    if (!b || b.status !== "active") return res.status(400).json({ error: "Invalid borrowing" });

    b.status = "returned";
    b.returnDate = new Date();
    await b.save();

    const book = await Book.findById(b.bookId);
    if (!book) return res.status(404).json({ error: "Book not found" });

    book.status = "available";
    book.currentBorrower = null;
    await book.save();

    const next = await Reservation.findOne({
      bookId: b.bookId,
      status: { $in: ["active", "pending"] },
    }).sort({ reservationDate: 1 });

    if (next) {
      const newBorrow = await Borrowing.create({
        bookId: next.bookId,
        userId: next.userId,
        borrowDate: new Date(),
        dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        status: "active",
      });

      book.status = "borrowed";
      book.currentBorrower = next.userId;
      await book.save();

      next.status = "fulfilled";
      await next.save();

      const user = await User.findById(next.userId);

      await sendEmail(
        user.email,
        "Your reserved book is now available",
        `Hi ${user.name}, the book "${book.title}" was just returned and is now yours. Due: ${newBorrow.dueDate.toLocaleDateString()}`
      );
    }

    res.json({ success: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
};

// PUT: Renew a book
exports.renewBook = async (req, res) => {
  try {
    const b = await Borrowing.findById(req.params.id);
    if (!b || b.status !== "active")
      return res.status(400).json({ message: "Invalid or inactive borrowing" });

    if (b.renewalsLeft <= 0)
      return res.status(400).json({ message: "No renewals left" });

    b.dueDate.setDate(b.dueDate.getDate() + 14);
    b.renewalsLeft -= 1;
    await b.save();

    res.json({
      message: "Book renewed successfully",
      newDueDate: b.dueDate?.toISOString(),
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

// GET: Borrowings of a user
exports.getUserBorrowings = async (req, res) => {
  try {
    const borrowings = await Borrowing.find({ userId: req.params.userId })
      .populate("bookId", "title author")
      .populate("userId", "name email")
      .sort({ borrowDate: -1 });

    const result = borrowings.map((b) => ({
      id: b._id,
      book: b.bookId,
      user: b.userId,
      borrowDate: b.borrowDate?.toISOString(),
      returnDate: b.returnDate?.toISOString() || null,
      dueDate: b.dueDate?.toISOString(),
      status: b.status,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: All borrowings (admin)
exports.getAllBorrowings = async (req, res) => {
  try {
    const borrowings = await Borrowing.find()
      .populate("bookId")
      .populate("userId")
      .sort({ borrowDate: -1 });

    const formatted = borrowings.map((b) => ({
      id: b._id,
      book: b.bookId,
      user: b.userId,
      borrowDate: b.borrowDate?.toISOString(),
      returnDate: b.returnDate?.toISOString() || null,
      dueDate: b.dueDate?.toISOString(),
      status: b.status,
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
};

// GET: Overdue borrowings
exports.getOverdueBorrowings = async (req, res) => {
  try {
    const now = new Date();
    const arr = await Borrowing.find({ dueDate: { $lt: now }, status: "active" })
      .populate("bookId", "title")
      .populate("userId", "name email");

    const result = arr.map((b) => ({
      bookTitle: b.bookId.title,
      userName: b.userId.name,
      userEmail: b.userId.email,
      dueDate: b.dueDate?.toISOString(),
    }));

    res.json(result);
  } catch (e) {
    res.status(500).json({ message: "Server error" });
  }
};

// POST: Send email reminders
exports.sendOverdueReminders = async (req, res) => {
  try {
    const now = new Date();
    const arr = await Borrowing.find({ dueDate: { $lt: now }, status: "active" })
      .populate("bookId", "title")
      .populate("userId", "name email");

    for (const b of arr) {
      await sendOverdueReminder(b.userId.email, b.userId.name, b.bookId.title, b.dueDate);
    }

    res.json({ message: `Sent ${arr.length} reminder emails.` });
  } catch (e) {
    res.status(500).json({ message: "Failed to send reminders" });
  }
};
