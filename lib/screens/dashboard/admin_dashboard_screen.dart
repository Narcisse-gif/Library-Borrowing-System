import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int totalBooks = 0;
  int totalUsers = 0;
  int totalBorrowings = 0;
  int totalReservations = 0;

  List<dynamic> topBorrowers = [];
  List<dynamic> overdueBooks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOverview();
  }

  /// Public method to refresh dashboard externally
  Future<void> refreshData() async {
    setState(() => isLoading = true);
    await fetchOverview();
  }

  Future<void> fetchOverview() async {
    try {
      final data = await AdminService.getOverview();
      final overdueData = await AdminService.getOverdueBooks();
      final borrowerData = await AdminService.getTopBorrowers();

      setState(() {
        totalBooks = data['totalBooks'] ?? 0;
        totalUsers = data['totalUsers'] ?? 0;
        totalBorrowings = data['totalBorrowings'] ?? 0;
        totalReservations = data['totalReservations'] ?? 0;

        topBorrowers = borrowerData;
        overdueBooks = overdueData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _sendReminders() async {
    final success = await AdminService.sendOverdueReminders();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '📧 Reminder emails sent successfully!'
            : '❌ Failed to send reminder emails.'),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendReminders,
        icon: const Icon(Icons.email, color: Colors.white),
        label: const Text("Send Reminders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
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
                  _buildDashboardCard("Total Books", totalBooks, Icons.book, Colors.blue),
                  _buildDashboardCard("Total Users", totalUsers, Icons.people, Colors.green),
                  _buildDashboardCard("Total Borrowings", totalBorrowings, Icons.assignment, Colors.indigo),
                  _buildDashboardCard("Total Reservations", totalReservations, Icons.bookmark, Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Top Borrowers",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topBorrowers.length,
                itemBuilder: (context, index) {
                  final b = topBorrowers[index];
                  final name = b['name']?.toString() ?? 'Unknown';
                  final count = b['count'] ?? 0;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?'),
                    ),
                    title: Text(name),
                    subtitle: Text("Borrowed: $count books"),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text("Overdue Borrowings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: overdueBooks.length,
                itemBuilder: (context, index) {
                  final o = overdueBooks[index];
                  return ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text(o['bookTitle'] ?? 'Unknown Book'),
                    subtitle: Text(
                        "By: ${o['userName'] ?? 'Unknown'} - Due: ${o['dueDate'] ?? 'N/A'}"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
