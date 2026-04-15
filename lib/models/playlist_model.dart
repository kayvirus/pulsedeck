import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> songIds; // Song IDs

  @HiveField(4)
  String? coverArt;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    List<String>? songIds,
    this.coverArt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Playlist.create(String name, {String? description}) {
    return Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
    );
  }

  int get songCount => songIds.length;
}
