class Thread {
  final String id;
  final String title;
  final String text;
  final String userId;
  final List<String> images;
  final int nbLikes;
  final List<String> likedUsers;

  Thread({
    required this.id,
    required this.title,
    required this.text,
    required this.userId,
    required this.images,
    this.nbLikes = 0,
    this.likedUsers = const [], // Default to an empty list if not specified
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
      likedUsers: List<String>.from(data['likedUsers'] ?? []),
    );
  }

  // Convert a Thread instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'userId': userId,
      'images': images,
      'nbLikes': nbLikes,
      'likedUsers': likedUsers,
    };
  }
}
