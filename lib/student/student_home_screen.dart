import 'package:flutter/material.dart';
import 'package:library_borrowing_system/student/student_borrowing_reservation_screen.dart';
import '../screens/dashboard/student_dashboard_screen.dart';
import '../screens/book/book_catalog_screen.dart';
import '../screens/history/student_history_screen.dart';
import '../screens/profile/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const StudentDashboardScreen(),
    const BookCatalogScreen(),
    const StudentBorrowingReservationScreen(),
    const StudentHistoryScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    "Dashboard",
    "Books",
    "Borrowings",
    "History",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Books"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: "Borrowings / Reservations"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
