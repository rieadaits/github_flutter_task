class Repository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String ownerAvatarUrl;
  final String ownerName;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final String updatedAt;
  final String htmlUrl;

  const Repository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.ownerAvatarUrl,
    required this.ownerName,
    required this.stargazersCount,
    required this.forksCount,
    required this.watchersCount,
    required this.updatedAt,
    required this.htmlUrl,
  });
} 