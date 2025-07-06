const Book = require("../models/book.model");
const fs = require("fs");
const path = require("path");

// GET all books with pagination and search
exports.getBooks = async (req, res) => {
  const { page = 1, limit = 10, search = "", genre, author, status } = req.query;
  const query = {};

  if (search) query.$text = { $search: search };
  if (genre) query.genre = genre;
  if (author) query.author = author;
  if (status) query.status = status;

  try {
    const books = await Book.find(query)
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .sort({ createdAt: -1 });

    const total = await Book.countDocuments(query);

    res.json({ total, page: Number(page), limit: Number(limit), books });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Helper: Save base64 image
const saveBase64Image = (base64String) => {
  const matches = base64String.match(/^data:(.+);base64,(.+)$/);
  const buffer = Buffer.from(matches ? matches[2] : base64String, "base64");
  const fileName = `book-${Date.now()}.png`;
  const filePath = path.join(__dirname, "..", "uploads", fileName);
  fs.writeFileSync(filePath, buffer);
  return `/uploads/${fileName}`;
};

// GET book by ID
exports.getBookById = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id).populate("addedBy", "name");
    if (!book) return res.status(404).json({ message: "Book not found" });
    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST create a new book (admin only)
exports.createBook = async (req, res) => {
  const { title, author, genre, isbn, description, coverImage, status } = req.body;

  console.log("📚 Creating book with data:", req.body); // Debug log

  try {
    const bookExists = await Book.findOne({ isbn });
    if (bookExists) return res.status(400).json({ message: "ISBN already exists" });

    let coverImagePath = "";
    if (coverImage) {
      coverImagePath = saveBase64Image(coverImage);
    }

    const book = await Book.create({
      title,
      author,
      genre,
      isbn,
      description,
      coverImagePath,
      status, // ✅ Include status
      addedBy: req.user.id,
    });

    res.status(201).json(book);
  } catch (err) {
    console.error("❌ Error creating book:", err); // Optional: error log
    res.status(500).json({ message: err.message });
  }
};


// PUT update a book (admin only)
exports.updateBook = async (req, res) => {
  try {
    const { coverImage, ...updateData } = req.body;

    if (coverImage) {
      updateData.coverImagePath = saveBase64Image(coverImage);
    }

    const book = await Book.findByIdAndUpdate(req.params.id, updateData, { new: true });
    if (!book) return res.status(404).json({ message: "Book not found" });

    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE a book (admin only)
exports.deleteBook = async (req, res) => {
  try {
    const book = await Book.findByIdAndDelete(req.params.id);
    if (!book) return res.status(404).json({ message: "Book not found" });
    res.json({ message: "Book deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
