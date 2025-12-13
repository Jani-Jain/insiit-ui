import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cab_ride.dart';

class CabApiService {
  static const base = "http://192.168.56.1:3000/api";

  Future<List<CabRide>> getAll() async {
    final r = await http.get(Uri.parse("$base/cab"));
    return (json.decode(r.body) as List)
        .map((e) => CabRide.fromJson(e))
        .toList();
  }

  Future<List<CabRide>> getMine(String email) async {
    final r = await http.get(Uri.parse("$base/cab/user/$email"));
    return (json.decode(r.body) as List)
        .map((e) => CabRide.fromJson(e))
        .toList();
  }

  Future<void> create(Map body) async {
    await http.post(Uri.parse("$base/cab"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));
  }

  Future<void> join(String id, String email) async {
    await http.put(Uri.parse("$base/cab/$id/join"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}));
  }

  Future<void> leave(String id, String email) async {
    await http.put(Uri.parse("$base/cab/$id/leave"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}));
  }

  Future<void> close(String id, String email) async {
    await http.put(Uri.parse("$base/cab/$id/close"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}));
  }

  Future<void> delete(String id, String email) async {
    await http.delete(Uri.parse("$base/cab/$id"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}));
  }
}
