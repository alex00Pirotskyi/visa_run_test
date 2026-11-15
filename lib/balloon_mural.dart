import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Vectorized from the user-supplied visual reference, using only a tiny set
/// of points and no image assets. Black stencil girl, red heart-shaped balloon.
/// Both are painted once per size by a static CustomPainter.
class BalloonGirlPainter extends CustomPainter {
  const BalloonGirlPainter({this.mobile = false});
  final bool mobile;

  static const String _girl = '''
pAFdAaIBYQGlAWgBqAFoAagBZAH/////nQH5AJkB/ACcAf8AngH+AP////+dAewAlwHuAJcB8ACYAfEAnQHvAP/////1AeAA8QHiAOsB6wDlAe0A2QH8ANABAgHIAQUBwwEJAcEBCQGtARUBqwEVAZ8BHgGQASEBiQEmAYoBKwGUATMBnQFAAaIBSgGiAVQBpAFXAaYBVQGmAU0BpAFLAZ0BOQGfATUBpwEtAcEBHgHHARgB4gEEAeQBBQHnAQMB7QEDAfMBBgHzAQIB7QH8AO0B+AD9AeYA+gHmAPcB6QD0AekA8wHmAPUB5AD2AeEA/////2oBugBdAcAAVAHGAEoBzwBDAdsAQAHjAEAB6gA/AesAQAH8AEUBBQFNAQ8BVAEUAVkBFAFbARYBYgEVAWgBGQFjASYBXgEtAVcBMwFTATsBUwE9AVoBSAFaAVMBVAFjAVUBZQFTAWkBUgFwAVMBlwFRAZoBUQGdAU4BpAFOAakBTAGsAUwBwAFOAcgBTgHcAU0B3QFOAd8BTAHkAUwB6gFIAfIBRwH4AUMB/gFDAQQCSwEKAlUBDAJcAQ8CYgEPAmQBEQJhASQCXwEmAl8BMQKOATECkgETApUBDwKlAQ8CpgEOArsBDQK8AQwC1AEMAukBCALsAQYC7AEEAucB+wHgAfQB2QHoAdAB3QHNAdUBxQHQAc8B4wHLAeQBygHoAccB6wHDAecBvwHgAb0B1gG7AdMBuwHJAb4BwwG9Ab0BswGsAbMBngGvAZYBrAGHAaQBeQGjAXMBoQFxAZ0BdAGbAW8BkgF1AZQBeAGWAXgBmQF7AZwBhQGgAYsBpgGQAasBmAGuAagBrgGvAbABsQG0AbwBswHDAa8BwAGsAboBrAG3AaYBrAGmAacBoQGXAZ8BlgGcAZEBnQGZAaIBpQGhAagBnwGnAZgBlwGXAZABlQGOAZUBiwGRAYUBkAF/AYwBeAGMAXUBjwFyAY0BcAGKAXABgwFtAX0BZQF9AWMBfwFhAYMBYwGCAV8BgwFcAYUBXgGGAV0BhgFbAYMBWgGAAVcBgAFVAYMBUQGDAU8BhwFLAXsBRAF4AUQBdAFKAXMBTgFxAU8BbQFbAWgBZAFoAWsBZQFzAWUBhgFoAY0BaAGQAWwBlgF1AZsBeAGfAXgBoQF2AaIBcwGeAXEBngFxAaEBdgGoAXUBqwFwAagBbAGfAV4BiwFcAXQBYAFuAWIBcQFkAW0BZAFnAWcBXgFnAVQBaQFPAWkBRgFuAToBcAE4AXYBOQGAAUMBgwFEAYUBQgGFATsBgwE4AX4BNQF6ATUBdQEzAWwBLAFsAScBbwEmAXUBKgF6ASMBggEmAYUBIwGFASABggEdAYIBGwGIARgBigESAY0BDwGQAQ4BlgEIAZsBBgGbAQQBmAEEAZYBAgGVAf0AkQH5AJMB9gCNAfIAjQHuAIsB7ACGAe4AhAHrAH0B6wB3AeYAdAHmAHEB6QBwAegAcAHmAHIB5ABxAeIAaQHkAGUB4ABqAdwAbgHcAHAB3gB4Ad8AegHjAIEB4wCEAegAigHpAI0B5wCRAecAkQHlAJQB4QCYAeMAngHfAKgB3gCrAdwAqgHZAKcB2wCfAdsAngHaAJ4B2ACiAdUApQHVAKkB0QCpAc8ApAHPAKEB0QCWAdEAkwHNAJEBzACOAc4AjAHMAJEByQCRAccAkwHFAKABxQCkAcMAowHBAJsBwgCaAb8AlgG/AJEBvQCEAb0AgwG8AHcBvgD/////zgHkAdAB4wHTAeYB0wHoAdEB6QH/////cwG+AHsBvgCBAcQAfQHJAH8BzACMAcwAjQHNAI8B1gCSAdsAkgHgAJAB4gCNAeIAiwHkAIIB5ACBAeMAggHgAH8B3wB+Ad0AgQHcAIMB2QB2AdcAdwHVAHwB0wB9Ac8AfAHNAHYByQB4AcYAcwHFAHABwgD/////
''';

  static const String _balloon = '''
pgIeAKECHACUAhwAjAIfAIgCIgCBAiMAfgIgAHoCHwBzAhoAawIaAGYCHABlAh4AYQIgAFoCLABYAjMAWgJHAGECVQBzAmUAdAJnAHMCawB3AmwAeQJuAIwCZACbAlUAqAJDAK0CNwCtAi4ArgItAK0CJgD/////aAIjAGgCIQBqAh8AcQIgAHECIgBvAiQA/////w==
''';

  static Path _decode(String packed) {
    final bytes = base64Decode(packed.replaceAll(RegExp(r'\s+'), ''));
    final data = ByteData.sublistView(bytes);
    final path = Path()..fillType = PathFillType.evenOdd;
    var started = false;
    for (var i = 0; i + 3 < bytes.length; i += 4) {
      final x = data.getUint16(i, Endian.little);
      final y = data.getUint16(i + 2, Endian.little);
      if (x == 65535) {
        if (started) path.close();
        started = false;
      } else if (!started) {
        path.moveTo(x.toDouble(), y.toDouble());
        started = true;
      } else {
        path.lineTo(x.toDouble(), y.toDouble());
      }
    }
    return path;
  }

  static final Path _girlPath = _decode(_girl);
  static final Path _balloonPath = _decode(_balloon);
  static final Paint _ink = Paint()..color = const Color(0xff141516);
  static final Paint _red = Paint()..color = const Color(0xffb41820);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (mobile) {
      // Show both the girl and the balloon on a narrow vertical viewport.
      final scale = size.width / 540;
      canvas.translate(-155 * scale, (size.height - 562 * scale) * .5);
      canvas.scale(scale);
    } else {
      final scale = math.min(size.width / 1000, size.height / 562);
      canvas.translate(
        (size.width - 1000 * scale) * .5,
        size.height - 562 * scale,
      );
      canvas.scale(scale);
    }
    canvas.drawPath(_girlPath, _ink);
    canvas.drawPath(_balloonPath, _red);

    // The light, broken string swings left of the heart. It remains static.
    final stringPaint = Paint()
      ..color = const Color(0xff393c3b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.85
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(632, 108)
        ..cubicTo(618, 113, 621, 115, 605, 119)
        ..cubicTo(588, 128, 585, 147, 578, 163)
        ..quadraticBezierTo(564, 184, 549, 186),
      stringPaint,
    );
    // A couple of tiny red flecks on the spray-painted balloon.
    final spatter = Paint()..color = const Color(0x93b41820);
    for (final p in const [
      Offset(604, 45),
      Offset(690, 70),
      Offset(646, 22),
    ]) {
      canvas.drawCircle(p, .9, spatter);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BalloonGirlPainter oldDelegate) =>
      oldDelegate.mobile != mobile;
}
