const rateLimit = require("express-rate-limit");

// Limit repeated requests to sensitive endpoints for 5 minutes
const createRateLimiter = (maxRequests, windowMs, message) =>
  rateLimit({
    windowMs, // time window in ms
    max: maxRequests, // max requests per windowMs
    message: { message }, // JSON response message
    standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
    legacyHeaders: false, // Disable `X-RateLimit-*` headers
  });

const loginLimiter = createRateLimiter(
  5, // max 5 requests
  5 * 60 * 1000, // 5 minutes
  "Too many login attempts, please try again after 5 minutes."
);

const forgotPasswordLimiter = createRateLimiter(
  3,
  10 * 60 * 1000, // 10 minutes
  "Too many password reset requests, please try again later."
);

const resendVerificationLimiter = createRateLimiter(
  3,
  10 * 60 * 1000, // 10 minutes
  "Too many verification email requests, please try again later."
);

module.exports = {
  loginLimiter,
  forgotPasswordLimiter,
  resendVerificationLimiter,
};
