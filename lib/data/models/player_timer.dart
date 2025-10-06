import 'package:flutter/material.dart';

class PlayerTimer {
  final String id;
  final String name;
  final TimeOfDay time;
  final Duration duration;
  final bool isActive;

  PlayerTimer({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    required this.isActive,
  });

  PlayerTimer copyWith({
    String? id,
    String? name,
    TimeOfDay? time,
    Duration? duration,
    bool? isActive,
  }) {
    return PlayerTimer(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'duration': duration.inSeconds,
      'isActive': isActive,
    };
  }

  factory PlayerTimer.fromMap(Map<String, dynamic> map) {
    final timeMap = Map<String, dynamic>.from(map['time'] as Map);
    return PlayerTimer(
      id: map['id'] as String,
      name: map['name'] as String,
      time: TimeOfDay(
        hour: timeMap['hour'] as int,
        minute: timeMap['minute'] as int,
      ),
      duration: Duration(seconds: map['duration'] as int),
      isActive: map['isActive'] as bool,
    );
  }
}
