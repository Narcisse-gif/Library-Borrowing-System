import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/borrowing_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/reservation_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../models/borrowing_model.dart';
import '../../models/reservation_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, int> stats = {};
  List<BorrowingModel> borrowings = [];
  List<ReservationModel> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      final result = await DashboardService.fetchStudentDashboard(userId);
      final borrows = await BorrowingService.fetchUserBorrowings(userId);
      final reserves = await ReservationService.fetchUserReservations(userId);
      setState(() {
        stats = result;
        borrowings = borrows;
        reservations = reserves;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overview",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              DashboardCard(
                icon: Icons.book,
                title: "Borrowed Books",
                count: stats['borrowed'] ?? 0,
                color: Colors.indigo,
              ),
              DashboardCard(
                icon: Icons.bookmark,
                title: "Reservations",
                count: stats['reservations'] ?? 0,
                color: Colors.orange,
              ),
              DashboardCard(
                icon: Icons.warning,
                title: "Overdue",
                count: stats['overdue'] ?? 0,
                color: Colors.red,
              ),
              DashboardCard(
                icon: Icons.check_circle,
                title: "Books Read",
                count: stats['read'] ?? 0,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
