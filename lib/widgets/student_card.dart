import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String lastName;
  final String studentClass;
  final String email;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.name,
    required this.lastName,
    required this.studentClass,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text("$name $lastName"),
        subtitle: Text("$email\nClass: $studentClass"),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
