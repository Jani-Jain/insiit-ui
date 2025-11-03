// lib/services/lost_found_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lostfound.dart'; 

class LostFoundApiService {
  static const String BASE_URL = 'http://192.168.56.1:3000/api';

  
  // --- GET all "lost" (active) items ---
  Future<List<LostFoundItem>> getLostItems() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/lostfound'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((itemJson) => LostFoundItem.fromJson(itemJson)).toList();
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load lost items (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching lost items: $e');
    }
  }

  Future<List<LostFoundItem>> getResolvedItems() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/lostfound/resolved'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((itemJson) => LostFoundItem.fromJson(itemJson)).toList();
      } else {
        throw Exception('Failed to load resolved items (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching resolved items: $e');
    }
  }

  // --- POST a new item ---
  Future<bool> postNewItem({
    required String title,
    String? description,
    required DateTime lostDate,
    required String lostLocation,
    required String uploaderEmail,
    String? uploaderContact,
    List<String>? imageUrls,
  }) async {
    
    final Map<String, dynamic> body = {
      'title': title,
      'description': description,
      'lost_date': lostDate.toIso8601String(),
      'lost_location': lostLocation,
      'uploader_email': uploaderEmail,
      'uploader_contact': uploaderContact,
      'image_urls': imageUrls ?? [],
    };

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/lostfound'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(body),
      );
      
      return response.statusCode == 201; 
    } catch (e) {
      return false;
    }
  }

  // PUT to mark an item as "found"
  Future<bool> markItemAsFound(String itemId, String finderEmail) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/lostfound/$itemId/resolve'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'finder_email': finderEmail,
        }),
      );
      
      return response.statusCode == 200; 
    } catch (e) {
      return false;
    }
  }

  // --- DELETE an item ---
  Future<bool> deleteItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/lostfound/$itemId'),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
