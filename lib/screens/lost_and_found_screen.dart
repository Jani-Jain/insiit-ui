
import 'package:flutter/material.dart';
import '../models/lostfound.dart';
import '../services/lost_found_api_service.dart';


class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final LostFoundApiService apiService = LostFoundApiService();
  
  late Future<List<LostFoundItem>> _lostItemsFuture;

  @override
  void initState() {
    super.initState();
    _lostItemsFuture = apiService.getLostItems();
  }

  Future<void> _refreshData() async {
    setState(() {
      _lostItemsFuture = apiService.getLostItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found'),
        backgroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<LostFoundItem>>(
          future: _lostItemsFuture,
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: ${snapshot.error}\n\n'
                    '(Is your backend server running? Is the IP address in api_service.dart correct?)',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No lost items found.'));
            }

            final items = snapshot.data!;
            
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text('Lost at: ${item.lostLocation}'),
                    trailing: const Text('View Details'),
                    onTap: () {
                      // Todo : Navigate to a detail screen for this item
                    },
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
