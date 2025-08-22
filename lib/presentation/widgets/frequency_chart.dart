import 'package:flutter/material.dart';

class GraphPoint {
  final double t; // seconds
  final double f; // Hz
  const GraphPoint(this.t, this.f);
}

class FrequencyGraph extends StatelessWidget {
  final List<GraphPoint> points;
  final double minHz;
  final double maxHz;
  final double? durationHint; // optional: helps scale x when few points

  const FrequencyGraph({
    super.key,
    required this.points,
    this.minHz = 240,
    this.maxHz = 720,
    this.durationHint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        return CustomPaint(
          size: Size(c.maxWidth, 220),
          painter: _FrequencyGraphPainter(
            points: points,
            minHz: minHz,
            maxHz: maxHz,
            durationHint: durationHint,
            fg: Colors.white,
            grid: Colors.white.withOpacity(0.2),
          ),
        );
      },
    );
  }
}

class _FrequencyGraphPainter extends CustomPainter {
  final List<GraphPoint> points;
  final double minHz;
  final double maxHz;
  final double? durationHint;
  final Color fg;
  final Color grid;

  _FrequencyGraphPainter({
    required this.points,
    required this.minHz,
    required this.maxHz,
    required this.durationHint,
    required this.fg,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()..color = const Color(0xFF0f111a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(12)),
      bg,
    );

    // Axes/grid
    final axis = Paint()
      ..color = grid
      ..strokeWidth = 1;

    // Horizontal grid lines (min/mid/max)
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axis);
    }

    if (points.isEmpty) return;

    // X scaling
    final minT = points.first.t;
    final maxT = points.last.t;
    final spanT = (maxT - minT).clamp(0.0001, double.infinity);
    final totalT = durationHint != null && durationHint! > spanT
        ? durationHint!
        : spanT;

    // Line path
    final line = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = size.width * ((p.t - minT) / totalT).clamp(0.0, 1.0);
      final yNorm = ((p.f - minHz) / (maxHz - minHz)).clamp(0.0, 1.0);
      final y = size.height * (1 - yNorm);
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = fg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(line, linePaint);
  }

  @override
  bool shouldRepaint(covariant _FrequencyGraphPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.minHz != minHz ||
        oldDelegate.maxHz != maxHz;
  }
}
