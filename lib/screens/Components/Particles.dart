import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_engine.dart';

class Particle {
  final Color color;
  final double size;
  final Offset velocity;
  Offset position;

  Particle({
    required this.color,
    required this.size,
    required this.velocity,
    required this.position,
  });
}



List<Particle> generateParticles(int count, Size screenSize) {
  final random = Random();
  return List.generate(count, (_) {
    return Particle(
      color: Colors.white.withAlpha(150),
      size: random.nextDouble() * 2 + 1, // Size between 1 and 3
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2, // X velocity between -1 and 1
        (random.nextDouble() - 0.5) * 2, // Y velocity between -1 and 1
      ),
      position: Offset(
        random.nextDouble() * screenSize.width,
        random.nextDouble() * screenSize.height,
      ),
    );
  });
}

