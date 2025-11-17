import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfilePage extends StatelessWidget {
  final String studentId;
  final String name;
  final String lastName;

  const StudentProfilePage({
    super.key,
    required this.studentId,
    required this.name,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text("$name $lastName"),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Infos"),
              Tab(text: "Grades"),
              Tab(text: "Attendance"),
              Tab(text: "Projects"),
              Tab(text: "Skills"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(),
            _buildSubCollectionTab("grades"),
            _buildSubCollectionTab("attendance"),
            _buildSubCollectionTab("projects"),
            _buildSubCollectionTab("skills"),
          ],
        ),
      ),
    );
  }

  /// MAIN INFO FROM student document
  Widget _buildInfoTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snap.data!.data() as Map<String, dynamic>;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Name: ${data['name']} ${data['lastName']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Email: ${data['email']}"),
            const SizedBox(height: 8),
            Text("Class: ${data['class']}"),
          ],
        );
      },
    );
  }

  /// FOR grades, attendance, projects, skills subcollections
  Widget _buildSubCollectionTab(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("students")
          .doc(studentId)
          .collection(collectionName)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final map = docs[i].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(map.keys.join(", ")),
                subtitle: Text(map.values.join("\n")),
              ),
            );
          },
        );
      },
    );
  }
}
