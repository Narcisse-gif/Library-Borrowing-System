const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");
const authMiddleware = require("../middleware/auth.middleware"); // contains .protect and .authorize

const {
  loginLimiter,
  forgotPasswordLimiter,
  resendVerificationLimiter,
} = require("../middleware/rateLimiter");

// Public routes
router.post("/register", authController.register);
router.post("/login", loginLimiter, authController.login);
router.post("/resend-verification", resendVerificationLimiter, authController.resendVerification);
router.get("/verify-email/:token", authController.verifyEmail);
router.post("/forgot-password", forgotPasswordLimiter, authController.forgotPassword);
router.post("/reset-password/:token", authController.resetPassword);


router.put("/profile", authMiddleware.protect, authController.updateUserProfile);

module.exports = router;
