import 'package:client/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:client/globals.dart';

class TaskReminder extends StatelessWidget {
  const TaskReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(top: 15),
        decoration: _containerDecoration(context),
        child: const Text('Please login to view tasks'),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 15),
            decoration: _containerDecoration(context),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final families =
            List<String>.from(userSnapshot.data!['families'] ?? []);
        if (families.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 15),
            decoration: _containerDecoration(context),
            child: const Text('No family assigned'),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('familyId', isEqualTo: families.first)
              .where('dueDate',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
              .snapshots(),
          builder: (context, taskSnapshot) {
            if (!taskSnapshot.hasData) {
              return Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 15),
                decoration: _containerDecoration(context),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final tasks = taskSnapshot.data!.docs;

            return Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 15),
              decoration: _containerDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's Tasks",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleSmall!.color,
                        ),
                      ),
                      Chip(
                        label: Text('${tasks.length} tasks'),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (tasks.isEmpty)
                    _buildEmptyState()
                  else
                    ...tasks.map((doc) => _buildTaskItem(doc)),
                  const SizedBox(height: 10),
                  _buildAddTaskButton(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  BoxDecoration _containerDecoration(context) => BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  Widget _buildEmptyState() => Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'No tasks for today',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );

  Widget _buildTaskItem(DocumentSnapshot doc) {
    final task = doc.data() as Map<String, dynamic>;
    final dueDate = (task['dueDate'] as Timestamp).toDate();
    final status = task['status'] as String;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.task,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task['title'],
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          DateFormat('hh:mm a').format(dueDate),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Chip(
          label: Text(status),
          backgroundColor: _getStatusColor(status).withOpacity(0.2),
          labelStyle: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      case 'overdue':
        return Colors.red;
      default:
        return primaryGreen;
    }
  }

  Widget _buildAddTaskButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showAddTaskDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Task',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

  void _showAddTaskDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
  }
}
