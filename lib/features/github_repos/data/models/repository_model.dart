import '../../domain/entities/repository.dart';

class RepositoryModel extends Repository {
  const RepositoryModel({
    required super.id,
    required super.name,
    required super.fullName,
    super.description,
    required super.ownerAvatarUrl,
    required super.ownerName,
    required super.stargazersCount,
    required super.forksCount,
    required super.watchersCount,
    required super.updatedAt,
    required super.htmlUrl,
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'] ?? json['name'],
      description: json['description'],
      ownerAvatarUrl: json['owner']?['avatar_url'] ?? json['owner_avatar_url'],
      ownerName: json['owner']?['login'] ?? json['owner_name'],
      stargazersCount: json['stargazers_count'],
      forksCount: json['forks_count'] ?? json['forks'] ?? 0,
      watchersCount: json['watchers_count'],
      updatedAt: json['updated_at'],
      htmlUrl: json['html_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'owner_avatar_url': ownerAvatarUrl,
      'owner_name': ownerName,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'watchers_count': watchersCount,
      'updated_at': updatedAt,
      'html_url': htmlUrl,
    };
  }
} 