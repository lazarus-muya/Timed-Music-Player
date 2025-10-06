import 'package:equatable/equatable.dart';
import 'package:path/path.dart';
import 'package:timed_app/data/models/track.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final List<Track>? tracks;
  final DateTime? dateCreated;

  const Playlist({
    required this.id,
    required this.name,
    this.tracks,
    this.dateCreated,
  });

  Playlist copyWith({
    String? id,
    String? name,
    List<Track>? tracks,
    DateTime? dateCreated,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      tracks: tracks ?? this.tracks,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tracks': tracks == null || tracks!.isEmpty
          ? []
          : tracks?.map((e) => e.toMap()).toList(),
      'dateCreated': dateCreated ?? DateTime.now(),
    };
  }

  // fromMap
  factory Playlist.fromMap(Map<String, dynamic> map) {
    List<Track>? tracks;
    if (map['tracks'] != null && map['tracks'].isNotEmpty) {
      final trackList = <Track>[];
      for (final e in map['tracks']) {
        // Handle both Map and String cases
        if (e is Map) {
          // Convert to Map<String, dynamic> to ensure proper typing
          final trackMap = Map<String, dynamic>.from(e);
          
          // Validate that the map has required fields
          final id = trackMap['id']?.toString() ?? '';
          final path = trackMap['path']?.toString() ?? '';
          
          // Only create track if we have valid data
          if (id.isNotEmpty && path.isNotEmpty) {
            try {
              trackList.add(Track.fromMap(trackMap));
            } catch (error) {
              //
            }
          }
        } else if (e is String) {
          // If it's just a string path, create a basic Track
          trackList.add(Track(
            id: e.hashCode.toString(),
            title: basename(e), // Extract filename using cross-platform basename
            path: e,
          ));
        }
      }
      tracks = trackList;
    }
    
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      tracks: tracks,
      dateCreated: map['dateCreated'] as DateTime?,
    );
  }

  @override
  List<Object?> get props => [id, name, tracks, dateCreated];
}
