const mongoose = require("mongoose");

const reservationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    bookId: { type: mongoose.Schema.Types.ObjectId, ref: "Book", required: true },
    reservationDate: { type: Date, default: Date.now },
    expirationDate: { type: Date }, // set 48-72h later
    status: {
      type: String,
      enum: ["active", "fulfilled", "expired", "cancelled"],
      default: "active",
    },
    priority: { type: Number, required: true }, // queue position
    notificationSent: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Reservation", reservationSchema);
