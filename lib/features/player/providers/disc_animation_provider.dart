import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timed_app/commons/logic/player_state.dart';
import 'package:timed_app/features/player/providers/player_provider.dart';

class DiscAnimationNotifier extends Notifier<AnimationController?> {
  @override
  AnimationController? build() {
    return null;
  }

  void initialize(TickerProvider vsync) {
    if (state != null) return; // Already initialized
    
    final controller = AnimationController(
      duration: const Duration(seconds: 3), // 3 seconds per full rotation
      vsync: vsync,
    );

    state = controller;
    
    // Listen to player state changes
    ref.listen(playerStateProvider, (previous, next) {
      next.when(
        data: (playerState) => _updateRotation(playerState),
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  void _updateRotation(PlayerState playerState) {
    if (state == null) return;
    
    if (playerState == PlayerState.playing) {
      state!.repeat(); // This will continuously repeat the 0 to 2π animation
    } else {
      state!.stop();
    }
  }

  void dispose() {
    state?.dispose();
    state = null;
  }
}

final discAnimationProvider = NotifierProvider<DiscAnimationNotifier, AnimationController?>(DiscAnimationNotifier.new);
