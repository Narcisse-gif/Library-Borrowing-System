const User = require("../models/user.model");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const sendEmail = require("../services/mail.service");

// LOGIN
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email }).select("+password");

    if (!user)
      return res.status(400).json({ message: "Invalid email or password" });

    // 🔒 Email verification disabled temporarily
    // if (!user.emailVerified) {
    //   return res.status(403).json({
    //     message: "Please verify your email before logging in.",
    //   });
    // }

    const isMatch = await user.comparePassword(password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid email or password" });

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// RESEND EMAIL VERIFICATION — 🔒 Currently disabled
exports.resendVerification = async (req, res) => {
  return res
    .status(200)
    .json({ message: "Email verification is currently disabled." });

  // const { email } = req.body;
  // try {
  //   const user = await User.findOne({ email });
  //   if (!user)
  //     return res.status(404).json({ message: "No user with this email found" });

  //   if (user.emailVerified)
  //     return res.status(400).json({ message: "Email is already verified" });

  //   const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
  //     expiresIn: "1d",
  //   });

  //   user.emailVerificationToken = token;
  //   await user.save();

  //   const url = `${process.env.CLIENT_URL}/verify-email/${token}`;
  //   await sendEmail(
  //     user.email,
  //     "Resend Email Verification",
  //     `Click the link to verify your email: ${url}`
  //   );

  //   res.json({ message: "Verification email resent successfully." });
  // } catch (err) {
  //   res.status(500).json({ message: err.message });
  // }
};

// REGISTER
exports.register = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ message: "Email already exists" });

    user = new User({ name, email, password, role });

    // 🔒 Disable email verification and token
    // const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    //   expiresIn: "1d",
    // });
    // user.emailVerificationToken = token;

    await user.save();

    // Skip sending verification email
    // const url = `${process.env.CLIENT_URL}/verify-email/${token}`;
    // await sendEmail(
    //   user.email,
    //   "Verify your email",
    //   `Welcome! Please verify your email by clicking the following link:\n${url}`
    // );

    res.status(201).json({ message: "User registered successfully." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// VERIFY EMAIL — 🔒 Currently disabled
exports.verifyEmail = async (req, res) => {
  return res
    .status(200)
    .json({ message: "Email verification is currently disabled." });

  // try {
  //   const { token } = req.params;

  //   let decoded;
  //   try {
  //     decoded = jwt.verify(token, process.env.JWT_SECRET);
  //   } catch (err) {
  //     return res
  //       .status(400)
  //       .json({ message: "Invalid or expired verification token" });
  //   }

  //   const user = await User.findById(decoded.id);
  //   if (!user) return res.status(404).json({ message: "User not found" });

  //   if (user.emailVerified)
  //     return res.status(400).json({ message: "Email already verified" });

  //   user.emailVerified = true;
  //   user.emailVerificationToken = undefined;
  //   await user.save();

  //   res.json({ message: "Email verified successfully" });
  // } catch (err) {
  //   res.status(500).json({ message: err.message });
  // }
};

// FORGOT PASSWORD
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    const resetToken = crypto.randomBytes(32).toString("hex");
    const hashedToken = crypto.createHash("sha256").update(resetToken).digest("hex");

    user.passwordResetToken = hashedToken;
    user.passwordResetExpires = Date.now() + 1000 * 60 * 30; // 30 minutes
    await user.save();

    const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;
    await sendEmail(
      user.email,
      "Password Reset Request",
      `To reset your password, click this link:\n${resetUrl}\nThis link will expire in 30 minutes.`
    );

    res.json({ message: "Password reset email sent." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// UPDATE USER PROFILE
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, email, password } = req.body;

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    if (name) user.name = name;

    if (email && email !== user.email) {
      const existing = await User.findOne({ email });
      if (existing) {
        return res.status(400).json({ message: "Email already in use" });
      }
      user.email = email;
    }

    if (password && password.length >= 6) {
      user.password = password;
    }

    await user.save();

    res.json({
      message: "Profile updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};




// RESET PASSWORD
exports.resetPassword = async (req, res) => {
  const { token } = req.params;
  const { password } = req.body;

  try {
    const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() },
    });

    if (!user) return res.status(400).json({ message: "Invalid or expired token" });

    user.password = password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    res.json({ message: "Password reset successful" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
