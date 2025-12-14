import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cab_ride.dart';
import '../services/cab_api_service.dart';

class CabScreen extends StatefulWidget {
  const CabScreen({super.key});

  @override
  State<CabScreen> createState() => _CabScreenState();
}

class _CabScreenState extends State<CabScreen> {
  final CabApiService api = CabApiService();

  late String userEmail;
  late Future<List<CabRide>> _allRidesFuture;
  late Future<List<CabRide>> _myRidesFuture;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    _load();
  }

  void _load() {
    _allRidesFuture = api.getAll();
    _myRidesFuture = api.getMine(userEmail);
  }

  Future<void> _refresh() async {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cab Sharing"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Rides"),
              Tab(text: "My Rides"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openCreateRideDialog(),
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _buildAllRides(),
            _buildMyRides(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRides() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<CabRide>>(
        future: _allRidesFuture,
        builder: (c, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = s.data!;
          if (rides.isEmpty) {
            return const Center(child: Text("No cab rides available."));
          }

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (_, i) => _buildRideCard(rides[i]),
          );
        },
      ),
    );
  }

  Widget _buildMyRides() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<CabRide>>(
        future: _myRidesFuture,
        builder: (c, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = s.data!;
          if (rides.isEmpty) {
            return const Center(child: Text("You have no rides."));
          }

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (_, i) => _buildRideCard(rides[i]),
          );
        },
      ),
    );
  }

  Widget _buildRideCard(CabRide ride) {
    final isCreator = ride.creatorEmail == userEmail;
    final isJoined = ride.riders.contains(userEmail);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${ride.from} → ${ride.to}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 6),
            Text("Date: ${ride.date}   Time: ${ride.time}"),
            Text("Seats: ${ride.availableSeats}/${ride.totalSeats}"),
            if (ride.costPerPerson != null)
              Text("Cost: ₹${ride.costPerPerson} per person"),

            const Divider(),

            Text("Creator: ${ride.creatorEmail}",
                style: const TextStyle(fontSize: 12)),

            if (ride.riders.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Text("Joined Users:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...ride.riders.map((e) => Text("• $e")),
            ],

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                if (!ride.isClosed && !isJoined && ride.availableSeats > 0)
                  ElevatedButton(
                    onPressed: () async {
                      await api.join(ride.id, userEmail);
                      _refresh();
                    },
                    child: const Text("Join"),
                  ),

                if (isJoined)
                  OutlinedButton(
                    onPressed: () async {
                      await api.leave(ride.id, userEmail);
                      _refresh();
                    },
                    child: const Text("Leave"),
                  ),

                if (isCreator && !ride.isClosed)
                  OutlinedButton(
                    onPressed: () async {
                      await api.close(ride.id, userEmail);
                      _refresh();
                    },
                    child: const Text("Close Ride"),
                  ),

                if (isCreator)
                  TextButton(
                    onPressed: () async {
                      await api.delete(ride.id, userEmail);
                      _refresh();
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),

            if (ride.isClosed)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "Ride Closed",
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // CREATE RIDE DIALOG
  void _openCreateRideDialog() {
    final from = TextEditingController();
    final to = TextEditingController();
    final date = TextEditingController();
    final time = TextEditingController();
    final seats = TextEditingController();
    final cost = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Cab Ride"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: from, decoration: const InputDecoration(labelText: "From")),
              TextField(controller: to, decoration: const InputDecoration(labelText: "To")),
              TextField(controller: date, decoration: const InputDecoration(labelText: "Date")),
              TextField(controller: time, decoration: const InputDecoration(labelText: "Time")),
              TextField(controller: seats, decoration: const InputDecoration(labelText: "Total Seats"), keyboardType: TextInputType.number),
              TextField(controller: cost, decoration: const InputDecoration(labelText: "Cost per person (optional)"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
                final DateTime rideDateTime =
                    DateTime.parse("${date.text} ${time.text}");

              await api.create({
                "from": from.text,
                "to": to.text,
                "rideDateTime": rideDateTime.toIso8601String(),
                "date": date.text,
                "time": time.text,
                "totalSeats": int.parse(seats.text),
                "costPerPerson": cost.text.isEmpty ? null : int.parse(cost.text),
                "creatorEmail": userEmail,
              });
              Navigator.pop(context);
              _refresh();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
