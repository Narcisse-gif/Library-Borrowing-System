import 'package:flutter/material.dart';
import 'package:library_borrowing_system/screens/book/book_detail_screen.dart';
import 'package:library_borrowing_system/screens/history/student_history_screen.dart';
import 'package:library_borrowing_system/screens/profile/edit_profile_screen.dart';
import 'package:library_borrowing_system/screens/profile/profile_screen.dart';
import 'package:library_borrowing_system/student/student_home_screen.dart';
import 'package:provider/provider.dart';
import 'admin/admin_borrowings_reservations_screen.dart';
import 'admin/admin_home_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/student_dashboard_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/auth/resend_verification_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library Borrowing System',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/student': (context) => const StudentDashboardScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/resend-verification': (context) => const ResendVerificationScreen(),
          '/book-detail': (context) {
            final book = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return BookDetailScreen(book: book);
          },
          '/profile': (context) => const ProfileScreen(),
          '/history': (context) => const StudentHistoryScreen(),
          '/admin': (context) =>  AdminDashboardScreen(),
          '/admin': (context) => const AdminHomeScreen(),
          '/admin/borrowings': (context) => const AdminBorrowingsReservationsScreen(),
          '/student': (context) => const StudentHomeScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),

        },
        onGenerateRoute: (settings) {
          final name = settings.name;
          if (name == null) return null;

          if (name.startsWith('/reset-password/')) {
            final token = name.split('/').last;
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(token: token),
            );
          } else if (name.startsWith('/verify-email/')) {
            final token = name.split('/').last;
            return MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(token: token),
            );
          }

          return null;
        },
      ),
    );
  }
}
