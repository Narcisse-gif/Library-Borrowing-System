import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // adjust path if needed
import '../screens/dashboard/admin_dashboard_screen.dart';
import 'admin_book_list_screen.dart';
import 'user_management_screen.dart';
import 'admin_borrowings_reservations_screen.dart';
import 'admin_history_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  // GlobalKey for AdminDashboardScreenState (now public)
  final GlobalKey<AdminDashboardScreenState> _dashboardKey = GlobalKey<AdminDashboardScreenState>();

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboardScreen(key: _dashboardKey),
      const AdminBookListScreen(key: PageStorageKey('books')),
      const UserManagementScreen(key: PageStorageKey('users')),
      const AdminBorrowingsReservationsScreen(key: PageStorageKey('borrowings')),
      const AdminHistoryScreen(key: PageStorageKey('history')),
    ];
  }

  final List<String> _titles = [
    "Dashboard",
    "Books",
    "Users",
    "Borrowings",
    "History",
  ];

  void _refreshCurrentScreen() {
    if (_selectedIndex == 0) {
      // Call refreshData() on dashboard screen
      _dashboardKey.currentState?.refreshData();
    } else {
      setState(() {
        // For other screens, just rebuild if needed
      });
    }
  }

  void _signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login'); // Adjust route if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          // Removed refresh icon here as requested
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Borrowings'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
