const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Please provide your name"],
      trim: true,
    },
    email: {
      type: String,
      required: [true, "Please provide your email"],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/\S+@\S+\.\S+/, "Please provide a valid email"],
    },
    password: {
      type: String,
      required: [true, "Please provide a password"],
      minlength: 8,
      select: false,
    },
    role: {
      type: String,
      enum: ["student", "admin"],
      default: "student",
    },

    emailVerified: {
      type: Boolean,
      default: false,
    },
    emailVerificationToken: String,

    passwordResetToken: String,
    passwordResetExpires: Date,

    loginAttempts: {
      type: Number,
      default: 0,
    },
    lockUntil: Date,
  },
  { timestamps: true }
);

// Hash password before saving (only if modified)
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  const salt = await bcrypt.genSalt(12);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Increment login attempts and lock account if needed
userSchema.methods.incLoginAttempts = function () {
  const LOCK_TIME = 60 * 60 * 1000; // 1 hour lock
  if (this.lockUntil && this.lockUntil < Date.now()) {
    // Reset login attempts and lockUntil if lock expired
    this.loginAttempts = 1;
    this.lockUntil = undefined;
  } else {
    this.loginAttempts += 1;
    if (this.loginAttempts >= 5 && !this.lockUntil) {
      this.lockUntil = Date.now() + LOCK_TIME;
    }
  }
  return this.save();
};

// Virtual field to check if account is locked
userSchema.virtual("isLocked").get(function () {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

module.exports = mongoose.model("User", userSchema);
