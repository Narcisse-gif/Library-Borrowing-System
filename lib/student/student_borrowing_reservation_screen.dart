import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/borrowing_model.dart';
import '../../models/reservation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/borrowing_service.dart';
import '../../services/reservation_service.dart';

class StudentBorrowingReservationScreen extends StatefulWidget {
  const StudentBorrowingReservationScreen({super.key});

  @override
  State<StudentBorrowingReservationScreen> createState() =>
      _StudentBorrowingReservationScreenState();
}

class _StudentBorrowingReservationScreenState
    extends State<StudentBorrowingReservationScreen> {
  List<BorrowingModel> borrowings = [];
  List<ReservationModel> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      try {
        final allBorrows = await BorrowingService.fetchUserBorrowings(userId);
        final activeBorrows = allBorrows.where((b) => b.status.toLowerCase() == 'active').toList();

        final allReserves = await ReservationService.fetchUserReservations(userId);
        final currentReserves = allReserves
            .where((r) => r.status.toLowerCase() == 'active' || r.status.toLowerCase() == 'pending')
            .toList();

        setState(() {
          borrowings = activeBorrows;
          reservations = currentReserves;
        });
      } catch (e) {
        _showPopup(context, "Error", "Failed to load data.\n$e", isSuccess: false);
      }
    }
    setState(() => isLoading = false);
  }

  void _showPopup(BuildContext context, String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _renewLoan(String borrowingId) async {
    final success = await BorrowingService.renewBorrowing(borrowingId);
    _showPopup(
      context,
      success ? "Renewed" : "Failed",
      success
          ? "Borrowing renewed successfully ✅"
          : "❌ Failed to renew borrowing",
      isSuccess: success,
    );
    if (success) await _loadData();
  }

  void _cancelReservation(String reservationId) async {
    final success = await ReservationService.cancelReservation(reservationId);
    _showPopup(
      context,
      success ? "Cancelled" : "Failed",
      success
          ? "Reservation cancelled ✅"
          : "❌ Failed to cancel reservation",
      isSuccess: success,
    );
    if (success) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📘 My Current Borrowings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (borrowings.isEmpty)
              const Text("No borrowings found")
            else
              Column(
                children: borrowings.map((b) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book, color: Colors.indigo),
                      title: Text(b.book.title),
                      subtitle: Text(
                          "Due: ${b.dueDate.toLocal().toString().substring(0, 10)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Renew",
                        onPressed: () => _renewLoan(b.id!),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            const Text(
              "📌 My Reservations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (reservations.isEmpty)
              const Text("No reservations found")
            else
              Column(
                children: reservations.map((r) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.bookmark, color: Colors.orange),
                      title: Text(r.book.title),
                      subtitle: Text("Status: ${r.status}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel),
                        tooltip: "Cancel",
                        onPressed: () => _cancelReservation(r.id!),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
