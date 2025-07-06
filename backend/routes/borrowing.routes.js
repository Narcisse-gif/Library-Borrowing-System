const express = require("express");
const {
  borrowBook,
  returnBook,
  renewBook,
  getUserBorrowings,
  getOverdueBorrowings,
  sendOverdueReminders,
  getAllBorrowings
} = require("../controllers/borrowing.controller");

const { protect, authorize } = require("../middleware/auth.middleware");

const router = express.Router();

router.post("/", protect, authorize("student"), borrowBook);
router.put("/:id/return", protect, authorize("student", "admin"), returnBook);
router.put("/:id/renew", protect, authorize("student"), renewBook);
router.get("/user/:userId", protect, authorize("student", "admin"), getUserBorrowings);
router.get("/", protect, authorize("admin"), getAllBorrowings);
router.get("/overdue", protect, authorize("admin"), getOverdueBorrowings);
router.post("/overdue/remind", protect, authorize("admin"), sendOverdueReminders);

module.exports = router;
