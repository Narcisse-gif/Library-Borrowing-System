const User = require("../models/user.model");
const Book = require("../models/book.model");
const Borrowing = require("../models/borrowing.model");
const Reservation = require("../models/reservation.model");

// 🎓 Student Dashboard
exports.getStudentDashboard = async (req, res) => {
  const userId = req.params.userId;

  try {
    const borrowings = await Borrowing.find({ userId }).sort({ borrowDate: -1 });
    const reservations = await Reservation.find({ userId }).sort({ reservationDate: -1 });

    const borrowedBooks = borrowings.filter(b => b.status === "active").length;
    const overdueBooks = borrowings.filter(b => b.status === "overdue").length;
    const booksRead = borrowings.filter(b => b.status === "returned").length;

    const activeReservations = reservations.filter(r => r.status === "active").length;

    // Count books read this year
    const currentYear = new Date().getFullYear();
    const readThisYear = borrowings.filter(b => {
      if (!b.returnDate) return false;
      const returnDate = new Date(b.returnDate);
      return b.status === "returned" && returnDate.getFullYear() === currentYear;
    }).length;

    res.json({
      borrowedBooks,
      overdueBooks,
      activeReservations,
      booksRead,
      readThisYear,
      recentBorrowings: borrowings.slice(0, 5),
      recentReservations: reservations.slice(0, 5),
    });
  } catch (err) {
    console.error("Error in getStudentDashboard:", err);
    res.status(500).json({ message: err.message });
  }
};

// 👨‍💼 Admin Overview Dashboard
exports.getAdminOverview = async (req, res) => {
  try {
    const totalBooks = await Book.countDocuments();
    const borrowedBooks = await Book.countDocuments({ status: "borrowed" });
    const reservedBooks = await Book.countDocuments({ status: "reserved" });
    const availableBooks = await Book.countDocuments({ status: "available" });

    const totalUsers = await User.countDocuments();
    const totalBorrowings = await Borrowing.countDocuments();
    const totalReservations = await Reservation.countDocuments();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayBorrowings = await Borrowing.countDocuments({
      borrowDate: { $gte: today },
    });

    const todayReturns = await Borrowing.countDocuments({
      returnDate: { $gte: today },
    });

    const todayOverdue = await Borrowing.countDocuments({
      dueDate: { $lt: new Date() },
      status: "active",
    });

    const popularBooks = await Book.find()
      .sort({ borrowCount: -1 })
      .limit(5)
      .select("title borrowCount");

    res.json({
      totalBooks,
      borrowedBooks,
      reservedBooks,
      availableBooks,
      totalUsers,
      totalBorrowings,
      totalReservations,
      todayBorrowings,
      todayReturns,
      todayOverdue,
      popularBooks,
    });
  } catch (err) {
    console.error("Error in getAdminOverview:", err);
    res.status(500).json({ message: err.message });
  }
};

// 📊 Admin Analytics
exports.getAdminAnalytics = async (req, res) => {
  try {
    const startOfYear = new Date(new Date().getFullYear(), 0, 1);
    const monthlyData = Array(12).fill(0);

    const monthlyBorrowings = await Borrowing.find({
      borrowDate: { $gte: startOfYear },
    });

    monthlyBorrowings.forEach(b => {
      const month = new Date(b.borrowDate).getMonth(); // 0 = January
      monthlyData[month]++;
    });

    res.json({
      monthlyBorrowingTrend: monthlyData,
    });
  } catch (err) {
    console.error("Error in getAdminAnalytics:", err);
    res.status(500).json({ message: err.message });
  }
};

// 🏆 Top Borrowers
exports.getTopBorrowers = async (req, res) => {
  try {
    const topBorrowers = await Borrowing.aggregate([
      { $group: { _id: "$userId", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 },
      {
        $lookup: {
          from: "users",
          localField: "_id",
          foreignField: "_id",
          as: "userDetails"
        }
      },
      { $unwind: "$userDetails" },
      {
        $project: {
          _id: 0,
          name: "$userDetails.name",
          count: 1
        }
      }
    ]);

    res.status(200).json(topBorrowers);
  } catch (err) {
    console.error("Error fetching top borrowers:", err);
    res.status(500).json({ message: "Failed to fetch top borrowers" });
  }
};
