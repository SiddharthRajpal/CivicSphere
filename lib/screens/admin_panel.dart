import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  final List<String> statuses = const ['open', 'in progress', 'resolved'];

  void _updateStatus(BuildContext context, String docId, String currentStatus) {
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Update Issue Status', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButton<String>(
              value: selectedStatus,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedStatus = val;
                  });
                }
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('issues')
                  .doc(docId)
                  .update({'status': selectedStatus});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status updated to $selectedStatus')),
              );
            },
            child: const Text('Update', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.greenAccent;
      case 'in progress':
        return Colors.amber;
      case 'open':
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser?.email != 'admin@gmail.com') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('You do not have permission to access this page.', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.black,
      );
    }

    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('issues')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final issues = snapshot.data!.docs;

            if (issues.isEmpty) {
              return const Center(child: Text('No issues reported yet.', style: TextStyle(color: Colors.white)));
            }

            return ListView.builder(
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final doc = issues[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Untitled';
                final status = data['status'] ?? 'open';
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: const Icon(CupertinoIcons.pencil_circle, color: Colors.white),
                    title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Reported on: ${timestamp?.toLocal().toString().split('.')[0] ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                          backgroundColor: _getStatusColor(status),
                        ),
                      ],
                    ),
                    onTap: () => _updateStatus(context, doc.id, status),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
