const mongoose = require("mongoose");

const borrowingSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    bookId: { type: mongoose.Schema.Types.ObjectId, ref: "Book", required: true },
    borrowDate: { type: Date, default: Date.now },
    dueDate: { type: Date, required: true },
    returnDate: { type: Date },
    status: {
      type: String,
      enum: ["active", "returned", "overdue"],
      default: "active",
    },
    renewalsLeft: { type: Number, default: 1 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Borrowing", borrowingSchema);
