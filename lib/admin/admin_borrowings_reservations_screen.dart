import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book_model.dart';
import '../models/borrowing_model.dart';
import '../models/reservation_model.dart';
import '../services/borrowing_service.dart';
import '../services/reservation_service.dart';

class AdminBorrowingsReservationsScreen extends StatefulWidget {
  const AdminBorrowingsReservationsScreen({super.key});

  @override
  State<AdminBorrowingsReservationsScreen> createState() =>
      _AdminBorrowingsReservationsScreenState();
}

class _AdminBorrowingsReservationsScreenState
    extends State<AdminBorrowingsReservationsScreen> {
  List<BorrowingModel> borrowings = [];
  List<ReservationModel> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final allBorrowings = await BorrowingService.fetchAllBorrowings();
      final allReservations = await ReservationService.fetchAllReservations();

      setState(() {
        borrowings = allBorrowings
            .where((b) => b.status.toLowerCase() == 'active')
            .toList();
        reservations = allReservations
            .where((r) =>
        r.status.toLowerCase() == 'active' ||
            r.status.toLowerCase() == 'pending')
            .toList();
      });
    } catch (e) {
      _showPopup("Error", "Failed to load data: $e", isSuccess: false);
    }
    setState(() => isLoading = false);
  }

  Future<void> returnBook(String borrowingId) async {
    final confirm = await _confirmDialog(
      "Mark as Returned",
      "Are you sure this book was returned?",
    );
    if (!confirm) return;

    try {
      final success = await BorrowingService.returnBook(borrowingId);
      if (!success) {
        _showPopup("Error", "Failed to mark book as returned.", isSuccess: false);
        return;
      }

      final returnedBorrowing =
      borrowings.firstWhere((b) => b.id == borrowingId);

      // Remove returned borrowing from the list
      setState(() {
        borrowings.removeWhere((b) => b.id == borrowingId);
      });

      final nextReservations = reservations
          .where((r) =>
      r.book.id == returnedBorrowing.book.id &&
          (r.status.toLowerCase() == 'active' ||
              r.status.toLowerCase() == 'pending'))
          .toList();

      nextReservations.sort((a, b) => a.reservedAt.compareTo(b.reservedAt));

      if (nextReservations.isNotEmpty) {
        final reservationToFulfill = nextReservations.first;
        final bookId = reservationToFulfill.book.id;
        if (bookId == null) {
          _showPopup("Error", "Book ID is missing for reservation.", isSuccess: false);
          return;
        }

        final borrowSuccess = await BorrowingService.borrowBook(
          bookId,
          reservationToFulfill.user.id,
        );

        if (borrowSuccess) {
          final fulfillSuccess =
          await ReservationService.fulfillReservation(reservationToFulfill.id);

          if (fulfillSuccess) {
            _showPopup(
              "Reservation Fulfilled",
              "The book was assigned to ${reservationToFulfill.user.name} from the reservation queue.",
              isSuccess: true,
            );

            // Remove fulfilled reservation
            setState(() {
              reservations.removeWhere((r) => r.id == reservationToFulfill.id);
            });
          } else {
            _showPopup("Error", "Failed to fulfill reservation.", isSuccess: false);
          }
        } else {
          _showPopup("Error", "Failed to create borrowing from reservation.", isSuccess: false);
        }
      } else {
        _showPopup("Returned", "✅ Book marked as returned.", isSuccess: true);
      }
    } catch (e) {
      _showPopup("Error", "❌ Failed to mark as returned: $e", isSuccess: false);
    }
  }

  Future<void> fulfillReservation(String id) async {
    final confirm = await _confirmDialog(
      "Fulfill Reservation",
      "Mark this reservation as fulfilled?",
    );
    if (confirm) {
      try {
        await ReservationService.fulfillReservation(id);

        // Remove the fulfilled reservation from list
        setState(() {
          reservations.removeWhere((r) => r.id == id);
        });

        _showPopup("Reservation Fulfilled", "✅ Reservation marked as fulfilled.",
            isSuccess: true);
      } catch (e) {
        _showPopup("Error", "❌ Failed to fulfill reservation: $e", isSuccess: false);
      }
    }
  }

  Future<bool> _confirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showPopup(String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Borrowings & Reservations"),
        backgroundColor: Colors.blueGrey.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _sectionTitle("📘 Borrowings"),
            if (borrowings.isEmpty) const Text("No borrowings found."),
            ...borrowings.map(
                  (b) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(b.book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Borrowed by: ${b.user.name}"),
                      Text("Due: ${DateFormat.yMMMd().format(b.dueDate)}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.assignment_turned_in),
                    tooltip: "Mark as Returned",
                    onPressed: () => returnBook(b.id!),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle("📌 Reservations"),
            if (reservations.isEmpty) const Text("No reservations found."),
            ...reservations.map(
                  (r) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(r.book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reserved by: ${r.user.name}"),
                      Text("Reserved on: ${DateFormat.yMMMd().format(r.reservedAt)}"),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          r.status.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                        r.status.toLowerCase() == 'fulfilled'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),
                  trailing: (r.status.toLowerCase() == "active" ||
                      r.status.toLowerCase() == "pending")
                      ? IconButton(
                    icon: const Icon(Icons.check),
                    tooltip: "Fulfill Reservation",
                    onPressed: () => fulfillReservation(r.id!),
                  )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
