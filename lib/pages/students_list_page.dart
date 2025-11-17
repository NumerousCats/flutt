import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/student_card.dart';
import '../widgets/debouncer.dart';
import 'student_profile_page.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  final TextEditingController searchController = TextEditingController();
  final Debouncer debouncer = Debouncer(milliseconds: 400);

  String query = '';
  String classFilter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students List"),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("students")
                    .orderBy("name")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading students."));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final filtered = docs.where((doc) {
                    final fullName =
                    "${doc['name']} ${doc['lastName']}".toLowerCase();

                    final matchesQuery =
                    fullName.contains(query.toLowerCase());

                    final matchesClass =
                        classFilter.isEmpty || doc["class"] == classFilter;

                    return matchesQuery && matchesClass;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text("No students found."));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final s = filtered[i];
                      return StudentCard(
                        name: s['name'],
                        lastName: s['lastName'],
                        studentClass: s['class'],
                        email: s['email'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentProfilePage(
                                studentId: s.id,
                                name: s['name'],
                                lastName: s['lastName'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          debouncer.run(() {
            setState(() => query = value);
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search by name...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text("Class 1A"),
            selected: classFilter == "1A",
            onSelected: (_) =>
                setState(() => classFilter = classFilter == "1A" ? "" : "1A"),
          ),
          FilterChip(
            label: const Text("Class 2A"),
            selected: classFilter == "2A",
            onSelected: (_) =>
                setState(() => classFilter = classFilter == "2A" ? "" : "2A"),
          ),
          FilterChip(
            label: const Text("Class 3A"),
            selected: classFilter == "3A",
            onSelected: (_) =>
                setState(() => classFilter = classFilter == "3A" ? "" : "3A"),
          ),
        ],
      ),
    );
  }
}
