class ApiEndpoints {
  static const String baseUrl = "http://10.0.2.2:5000/api"; // Android emulator localhost

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String verifyEmail = "$baseUrl/auth/verify-email";
  static const String resendVerification = "$baseUrl/auth/resend-verification";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

  static const String updateProfile = "$baseUrl/auth/profile"; // ✅ CORRECTED

  static const String studentDashboard = "$baseUrl/dashboard/student";
  static const adminOverview = "$baseUrl/dashboard/admin/overview";
  static const String books = "$baseUrl/books";
  static const String borrowings = "$baseUrl/borrowings";
  static const String reservations = "$baseUrl/reservations";
  static const String users = "$baseUrl/users";
}
