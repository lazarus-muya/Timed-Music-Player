import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TrackTimer extends Equatable {
  final String id;
  final String name;
  final TimeOfDay startTime; // in 24hr format
  final TimeOfDay endTime; // in 24hr format
  final String playlistId;

  const TrackTimer({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.playlistId,
  });

  TrackTimer copyWith({
    String? id,
    String? name,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? playlistId,
  }) {
    return TrackTimer(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      playlistId: playlistId ?? this.playlistId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'playlistId': playlistId,
    };
  }

  factory TrackTimer.fromMap(Map<String, dynamic> map) {
    final startTimeMap = Map<String, dynamic>.from(map['startTime'] as Map);
    final endTimeMap = Map<String, dynamic>.from(map['endTime'] as Map);
    
    return TrackTimer(
      id: map['id'] as String,
      name: map['name'] as String,
      startTime: TimeOfDay(
        hour: startTimeMap['hour'] as int,
        minute: startTimeMap['minute'] as int,
      ),
      endTime: TimeOfDay(
        hour: endTimeMap['hour'] as int,
        minute: endTimeMap['minute'] as int,
      ),
      playlistId: map['playlistId'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name, startTime, endTime, playlistId];
}
