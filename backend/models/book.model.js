const mongoose = require("mongoose");

const bookSchema = new mongoose.Schema({
  title: { type: String, required: true, text: true },
  author: { type: String, required: true, text: true },
  genre: { type: String, required: true, text: true },
  isbn: { type: String, required: true, unique: true },
  description: { type: String },
  coverImagePath: { type: String, default: "" },
  status: {
    type: String,
    enum: ["available", "borrowed", "reserved"],
    default: "available",
  },
  addedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  currentBorrower: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
  reservationCount: { type: Number, default: 0 },
  nextAvailableDate: { type: Date, default: null },
  borrowCount: { type: Number, default: 0 },
}, { timestamps: true });


// Enable text search on title, author, and genre
bookSchema.index({ title: "text", author: "text", genre: "text" });

module.exports = mongoose.model("Book", bookSchema);
