import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lostfound.dart';
import '../services/lost_found_api_service.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final LostFoundApiService apiService = LostFoundApiService();

  late String userEmail;
  late Future<List<LostFoundItem>> _lostItemsFuture;
  late Future<List<LostFoundItem>> _myItemsFuture;
  late Future<List<LostFoundItem>> _foundItemsFuture;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    _loadAll();
  }

  void _loadAll() {
    _lostItemsFuture = apiService.getLostItems();
    _myItemsFuture = apiService.getUserItems(userEmail);
    _foundItemsFuture = apiService.getResolvedItems();
  }

  Future<void> _refreshData() async {
    setState(() {
      _loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Lost, My, Found
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lost & Found"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Lost Items"),
              Tab(text: "My Items"),
              Tab(text: "Found Items"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLostItemsTab(),
            _buildMyItemsTab(),
            _buildFoundItemsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLostItemsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<LostFoundItem>>(
        future: _lostItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No lost items."));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (c, i) =>
                _buildItemCard(items[i], showMyButtons: false),
          );
        },
      ),
    );
  }

  Widget _buildMyItemsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<LostFoundItem>>(
        future: _myItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("You haven't posted anything."));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (c, i) =>
                _buildItemCard(items[i], showMyButtons: true),
          );
        },
      ),
    );
  }

  Widget _buildFoundItemsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<LostFoundItem>>(
        future: _foundItemsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No items marked as found yet."));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (c, i) =>
                _buildItemCard(items[i], showMyButtons: false),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(LostFoundItem item, {required bool showMyButtons}) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text("Location: ${item.lostLocation}"),
        trailing: showMyButtons
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _openMarkFoundDialog(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(item),
                  ),
                ],
              )
            : const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  // Delete for My Items
  void _confirmDelete(LostFoundItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete this item?"),
        content: const Text("You cannot undo this."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await apiService.deleteItem(item.id, userEmail);
      _refreshData();
    }
  }

  // Mark as found
  void _openMarkFoundDialog(LostFoundItem item) {
    final emailController =
        TextEditingController(text: userEmail); 

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mark as Found"),
        content: TextField(
          controller: emailController,
          decoration:
              const InputDecoration(labelText: "Finder's email"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            child: const Text("Submit"),
            onPressed: () async {
              await apiService.markItemAsFound(
                item.id,
                emailController.text.trim(),
              );
              Navigator.pop(context);
              _refreshData();
            },
          ),
        ],
      ),
    );
  }
}
