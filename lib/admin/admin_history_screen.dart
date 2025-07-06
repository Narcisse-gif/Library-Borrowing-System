// File: lib/screens/admin/admin_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/borrowing_model.dart';
import '../../models/reservation_model.dart';
import '../../services/borrowing_service.dart';
import '../../services/reservation_service.dart';

class AdminHistoryScreen extends StatefulWidget {
  const AdminHistoryScreen({super.key});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<BorrowingModel> returnedBorrowings = [];
  List<ReservationModel> fulfilledReservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);
    try {
      final allBorrowings = await BorrowingService.fetchAllBorrowings();
      final allReservations = await ReservationService.fetchAllReservations();

      setState(() {
        returnedBorrowings = allBorrowings
            .where((b) => b.status.toLowerCase() == 'returned')
            .toList();
        fulfilledReservations = allReservations
            .where((r) => r.status.toLowerCase() == 'fulfilled')
            .toList();
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to load history: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin History (Returned / Fulfilled)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadHistory,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("📘 Returned Borrowings",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (returnedBorrowings.isEmpty)
              const Text("No returned borrowings."),
            ...returnedBorrowings.map(
                  (b) => ListTile(
                leading: const Icon(Icons.book, color: Colors.green),
                title: Text(b.book.title),
                subtitle: Text(
                    "By: ${b.user.name} | Returned: ${DateFormat.yMMMd().format(b.returnDate!)}"),
              ),
            ),
            const SizedBox(height: 24),
            const Text("📌 Fulfilled Reservations",
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (fulfilledReservations.isEmpty)
              const Text("No fulfilled reservations."),
            ...fulfilledReservations.map(
                  (r) => ListTile(
                leading:
                const Icon(Icons.check_circle, color: Colors.blue),
                title: Text(r.book.title),
                subtitle: Text(
                    "By: ${r.user.name} | Fulfilled: ${DateFormat.yMMMd().format(r.reservedAt)}"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
