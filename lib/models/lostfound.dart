class LostFoundItem {
  final String id;
  final String title;
  final String? description;
  final List<String> imageUrls;
  final DateTime lostDate;
  final String lostLocation;
  final String uploaderEmail;
  final String? uploaderContact;
  final String status;
  final String? finderEmail;
  final DateTime? foundDate;
  final DateTime datePosted;

  LostFoundItem({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrls,
    required this.lostDate,
    required this.lostLocation,
    required this.uploaderEmail,
    this.uploaderContact,
    required this.status,
    this.finderEmail,
    this.foundDate,
    required this.datePosted,
  });

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    return LostFoundItem(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrls: List<String>.from(json['image_urls']),
      lostDate: DateTime.parse(json['lost_date']),
      lostLocation: json['lost_location'],
      uploaderEmail: json['uploader_email'],
      uploaderContact: json['uploader_contact'],
      status: json['status'],
      finderEmail: json['finder_email'],
      foundDate: json['found_date'] != null
          ? DateTime.parse(json['found_date'])
          : null,
      datePosted: DateTime.parse(json['date_posted']),
    );
  }
}
