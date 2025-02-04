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
      profilePic: "assets/profile1.jpg", // Replace with your image path
    ),
    Worker(
      name: "Jane Smith",
      email: "jane.smith@example.com",
      workerType: "Conductor",
      busAssigned: "Bus 102",
      profilePic: "assets/profile2.jpg", // Replace with your image path
    ),
    Worker(
      name: "Alan Walker",
      email: "alan.walker@example.com",
      workerType: "Helper",
      busAssigned: "Bus 103",
      profilePic: "assets/profile3.jpg", // Replace with your image path
    ),
    // Add more worker data as needed
  ];

  // To hold filtered workers
  List<Worker> filteredWorkers = [];

  // Controller for the search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, the filtered workers list will be the same as the full list
    filteredWorkers = workers;
  }

  // Method to filter workers based on search query
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
      appBar: AppBar(
        title: Text('All Workers'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Workers',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) => _filterWorkers(query),
            ),
            SizedBox(height: 16),

            // Worker List
            Expanded(
              child: ListView.builder(
                itemCount: filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = filteredWorkers[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(worker.profilePic),
                        radius: 30,
                      ),
                      title: Text(worker.name),
                      subtitle: Text('Bus Assigned: ${worker.busAssigned}'),
                      trailing: Text(worker.workerType),
                      onTap: () {
                        // Handle worker tap (e.g., show worker details)
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
