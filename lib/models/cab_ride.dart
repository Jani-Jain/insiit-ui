class CabRide {
  final String id;
  final String from;
  final String to;
  final String date;
  final String time;
  final int totalSeats;
  final int availableSeats;
  final int? costPerPerson;
  final String creatorEmail;
  final List<String> riders;
  final bool isClosed;

  CabRide.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        from = json['from'],
        to = json['to'],
        date = json['date'],
        time = json['time'],
        totalSeats = json['totalSeats'],
        availableSeats = json['availableSeats'],
        costPerPerson = json['costPerPerson'],
        creatorEmail = json['creatorEmail'],
        riders = List<String>.from(json['riders']),
        isClosed = json['isClosed'];
}
