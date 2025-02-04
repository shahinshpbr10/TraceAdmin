import 'package:flutter/material.dart';

class Worker {
  final String name;
  final String email;
  final String workerType;
  final String busAssigned;
  final String profilePic;

  Worker({
    required this.name,
    required this.email,
    required this.workerType,
    required this.busAssigned,
    required this.profilePic,
  });
}

class WorkerListingPage extends StatefulWidget {
  const WorkerListingPage({super.key});

  @override
  State<WorkerListingPage> createState() => _WorkerListingPageState();
}

class _WorkerListingPageState extends State<WorkerListingPage> {
  // Sample data for workers
  List<Worker> workers = [
    Worker(
      name: "John Doe",
      email: "john.doe@example.com",
      workerType: "Driver",
      busAssigned: "Bus 101",
      profilePic: "assets/profile1.jpg",
    ),
    Worker(
      name: "Jane Smith",
      email: "jane.smith@example.com",
      workerType: "Conductor",
      busAssigned: "Bus 102",
      profilePic: "assets/profile2.jpg",
    ),
    Worker(
      name: "Alan Walker",
      email: "alan.walker@example.com",
      workerType: "Helper",
      busAssigned: "Bus 103",
      profilePic: "assets/profile3.jpg",
    ),
  ];

  // Filtered list for search
  List<Worker> filteredWorkers = [];

  // Controller for search input
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredWorkers = workers;
  }

  // Search filter method
  void _filterWorkers(String query) {
    setState(() {
      filteredWorkers = workers.where((worker) {
        return worker.name.toLowerCase().contains(query.toLowerCase()) ||
            worker.workerType.toLowerCase().contains(query.toLowerCase()) ||
            worker.busAssigned.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Workers'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search workers...",
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onChanged: (query) => _filterWorkers(query),
              ),
            ),
            const SizedBox(height: 16),

            // Worker List
            Expanded(
              child: filteredWorkers.isEmpty
                  ? const Center(
                child: Text(
                  "No workers found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = filteredWorkers[index];
                  return _buildWorkerCard(worker);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Worker Card UI
  Widget _buildWorkerCard(Worker worker) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundImage: AssetImage(worker.profilePic),
          radius: 30,
        ),
        title: Text(
          worker.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Bus Assigned: ${worker.busAssigned}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Chip(
          label: Text(worker.workerType),
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
        ),
        onTap: () {
          // Handle worker tap (e.g., show worker details)
          print('Tapped on: ${worker.name}');
        },
      ),
    );
  }
}
