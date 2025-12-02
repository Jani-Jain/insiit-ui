import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lostfound.dart';

class LostFoundApiService {
  static const String BASE_URL = 'http://192.168.56.1:3000/api';

  // Fetch all lost items
  Future<List<LostFoundItem>> getLostItems() async {
    final response = await http.get(Uri.parse('$BASE_URL/lostfound'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => LostFoundItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load lost items');
    }
  }

  // Fetch resolved items
  Future<List<LostFoundItem>> getResolvedItems() async {
    final response =
        await http.get(Uri.parse('$BASE_URL/lostfound/resolved'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => LostFoundItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load resolved items');
    }
  }

  // Fetch items uploaded by user
  Future<List<LostFoundItem>> getUserItems(String email) async {
    final response =
        await http.get(Uri.parse('$BASE_URL/lostfound/user/$email'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => LostFoundItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load user items');
    }
  }

  // Delete item
  Future<bool> deleteItem(String id, String email) async {
    final response = await http.delete(
      Uri.parse('$BASE_URL/lostfound/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'uploader_email': email}),
    );

    return response.statusCode == 200;
  }

  // Mark as found
  Future<bool> markItemAsFound(String id, String finderEmail) async {
    final response = await http.put(
      Uri.parse('$BASE_URL/lostfound/$id/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'finder_email': finderEmail}),
    );

    return response.statusCode == 200;
  }
}
