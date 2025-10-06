import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

class Track extends Equatable {
  final String id;
  final String title;
  final String path;
  final String? artist;
  final int? duration;

  const Track({
    required this.id,
    required this.title,
    required this.path,
    this.artist,
    this.duration,
  });

  Track copyWith({
    String? id,
    String? title,
    String? path,
    String? artist,
    int? duration,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'artist': artist,
      'duration': duration,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ?? '';
    final title = map['title']?.toString() ?? '';
    final path = map['path']?.toString() ?? '';
    
    // Validate required fields
    if (id.isEmpty || path.isEmpty) {
      throw ArgumentError('Track must have non-empty id and path. Got: id="$id", path="$path"');
    }
    
    return Track(
      id: id,
      title: title.isEmpty ? basename(path) : title, // Use filename if title is empty
      path: path,
      artist: map['artist']?.toString(),
      duration: map['duration'] is int ? map['duration'] : null,
    );
  }

  @override
  List<Object?> get props => [id, title, path, artist, duration];
}



// Track {
//   id: String/UUID,
//   title: String,
//   artist: String,
//   path: String,   // local or URL
//   duration: int   // optional metadata
// }
