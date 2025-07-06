const express = require("express");
const router = express.Router();
const {
  getBooks,
  getBookById,
  createBook,
  updateBook,
  deleteBook,
} = require("../controllers/book.controller");

const { protect, authorize } = require("../middleware/auth.middleware");

// Public routes
router.get("/", getBooks);
router.get("/:id", getBookById);

// Admin routes
router.post("/", protect, authorize("admin"), createBook);
router.put("/:id", protect, authorize("admin"), updateBook);
router.delete("/:id", protect, authorize("admin"), deleteBook);

module.exports = router;
