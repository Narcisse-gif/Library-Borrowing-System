const Reservation = require("../models/reservation.model");
const Book = require("../models/book.model");
const User = require("../models/user.model");
const { sendEmail } = require("../services/mail.service");
const Borrowing = require("../models/borrowing.model");

// POST: Reserve a book
exports.reserveBook = async (req, res) => {
  const userId = req.user.id;
  const { bookId } = req.body;

  try {
    const book = await Book.findById(bookId);
    if (!book) return res.status(404).json({ message: "Book not found" });

    const alreadyReserved = await Reservation.findOne({ userId, bookId, status: "active" });
    if (alreadyReserved)
      return res.status(400).json({ message: "You already have an active reservation" });

    const count = await Reservation.countDocuments({ bookId, status: "active" });

    const expiration = new Date();
    expiration.setDate(expiration.getDate() + 2); // 48h expiration

    const reservation = await Reservation.create({
      userId,
      bookId,
      expirationDate: expiration,
      priority: count + 1,
      status: "active",
    });

    book.reservationCount = (book.reservationCount || 0) + 1;
    await book.save();

    const user = await User.findById(userId);
    await sendEmail(
      user.email,
      "Reservation Confirmed",
      `Your reservation for "${book.title}" was successful. You have 48h to pick it up.`
    );

    const populated = await Reservation.findById(reservation._id)
      .populate("bookId", "title author")
      .populate("userId", "name email");

    res.status(201).json({
      id: populated._id,
      book: populated.bookId,
      user: populated.userId,
      status: populated.status,
      reservationDate: populated.reservationDate?.toISOString(),
      expirationDate: populated.expirationDate?.toISOString(),
      priority: populated.priority,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: User reservations
exports.getUserReservations = async (req, res) => {
  try {
    const reservations = await Reservation.find({ userId: req.params.userId })
      .populate("bookId", "title author")
      .populate("userId", "name email")
      .sort({ reservationDate: -1 });

    const result = reservations.map((r) => ({
      id: r._id,
      book: r.bookId,
      user: r.userId,
      status: r.status,
      reservationDate: r.reservationDate?.toISOString(),
      expirationDate: r.expirationDate?.toISOString(),
      priority: r.priority,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT: Cancel a reservation
exports.cancelReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findById(req.params.id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });

    if (reservation.status !== "active")
      return res.status(400).json({ message: "Cannot cancel this reservation" });

    reservation.status = "cancelled";
    await reservation.save();

    res.json({ message: "Reservation cancelled" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT: Fulfill reservation
exports.fulfillReservation = async (req, res) => {
  try {
    const r = await Reservation.findById(req.params.id).populate("userId").populate("bookId");
    if (!r || r.status !== 'active') return res.status(400).json({ error: 'Invalid reservation' });

    // Create borrowing
    const borrowing = await Borrowing.create({
      bookId: r.bookId._id,
      userId: r.userId._id,
      borrowDate: new Date(),
      dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
      status: 'active'
    });

    // Update book status
    const book = await Book.findById(r.bookId._id);
    book.status = "borrowed";
    book.currentBorrower = r.userId._id;
    book.borrowCount += 1;
    await book.save();

    r.status = 'fulfilled';
    await r.save();

    // Notify user
    await sendEmail(
      r.userId.email,
      'Reservation fulfilled',
      `Your reservation for "${r.bookId.title}" is now checked out to you. Due date: ${borrowing.dueDate.toLocaleDateString()}`
    );

    res.json({ success: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
};

// PUT: Expire old reservations and notify users
exports.expireOldReservations = async (req, res) => {
  try {
    const now = new Date();
    const expiredReservations = await Reservation.find({
      expirationDate: { $lt: now },
      status: "active",
    }).populate("userId").populate("bookId");

    let count = 0;

    for (const reservation of expiredReservations) {
      reservation.status = "expired";
      await reservation.save();

      await sendEmail(
        reservation.userId.email,
        "Reservation Expired",
        `Your reservation for "${reservation.bookId.title}" has expired and is no longer valid.`
      );

      count++;
    }

    res.json({ message: `${count} reservations expired and users notified.` });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: Queue for a specific book
exports.getBookQueue = async (req, res) => {
  try {
    const queue = await Reservation.find({ bookId: req.params.bookId, status: "active" })
      .sort({ priority: 1 })
      .populate("userId", "name email")
      .populate("bookId", "title author");

    const result = queue.map((r) => ({
      id: r._id,
      user: r.userId,
      book: r.bookId,
      priority: r.priority,
      status: r.status,
      expirationDate: r.expirationDate,
      reservationDate: r.reservationDate,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: All reservations (admin)
exports.getAllReservations = async (req, res) => {
  try {
    const reservations = await Reservation.find()
      .populate("bookId", "title author")
      .populate("userId", "name email")
      .sort({ reservationDate: -1 });

    const result = reservations.map((r) => ({
      id: r._id,
      book: r.bookId,
      user: r.userId,
      status: r.status,
      reservationDate: r.reservationDate?.toISOString(),
      expirationDate: r.expirationDate?.toISOString(),
      priority: r.priority,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
