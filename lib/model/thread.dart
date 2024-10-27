class Thread {
  final String id; // Unique identifier for the thread
  final String title;
  final String text;
  final String userId;
  final List<String> images; // For image URLs
  final int nbLikes; // Number of likes

  Thread({
    required this.id, // Make sure id is included in the constructor
    required this.title,
    required this.text,
    required this.userId,
    required this.images,
    this.nbLikes = 0, // Default to 0 if not specified
  });

  // Convert Firestore data to a Thread instance
  factory Thread.fromMap(Map<String, dynamic> data, String id) {
    return Thread(
      id: id,
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      userId: data['userId'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      nbLikes: data['nbLikes'] ?? 0,
    );
  }

  // Convert a Thread instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'userId': userId,
      'images': images,
      'nbLikes': nbLikes, // Add nbLikes here
    };
  }
}
