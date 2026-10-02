import 'package:flutter/material.dart';
import 'gcode_converter.dart';
import 'firebase_service.dart';

// ── SignaturePage ─────────────────────────────
class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});
  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  // Stores all strokes. Each stroke = list of points
  List<List<Offset>> strokes = [];
  List<Offset> currentStroke = [];
  String statusMessage = 'Draw your signature below';
  Color statusColor = const Color(0xFF4A7AB5);
  bool isSending = false;

  // Called every time finger moves on screen
  void onPanUpdate(DragUpdateDetails details, Size size) {
    final Offset point = details.localPosition;
    // Only capture if inside canvas boundary
    if (point.dx >= 0 && point.dy >= 0 &&
        point.dx <= size.width && point.dy <= size.height) {
      setState(() { currentStroke.add(point); });
    }
  }

  // Called when finger lifts — end of one stroke
  void onPanEnd() {
    if (currentStroke.isNotEmpty) {
      setState(() {
        strokes.add(List.from(currentStroke));
        currentStroke.clear();
      });
    }
  }

  // Clear canvas
  void clearSignature() {
    setState(() {
      strokes.clear();
      currentStroke.clear();
      statusMessage = 'Draw your signature below';
      statusColor = const Color(0xFF4A7AB5);
    });
  }

  // Send signature to machine
  Future<void> sendToMachine() async {
    if (strokes.isEmpty) {
      setState(() { statusMessage = 'Please draw your signature first!'; });
      return;
    }

    setState(() { isSending = true; statusMessage = 'Converting to G-code...'; });

    try {
      // 1. Get canvas size for normalization
      const Size canvasSize = Size(300, 200); // logical canvas size

      // 2. Convert signature strokes to G-code
      final String gcode = GcodeConverter.convert(strokes, canvasSize);

      setState(() { statusMessage = 'Uploading to Firebase...'; });

      // 3. Upload G-code to Firebase
      await FirebaseService.submitJob(gcode);

      setState(() {
        statusMessage = '✔ Sent! Machine is signing...';
        statusColor = const Color(0xFF06D6A0);
        isSending = false;
      });

      // 4. Listen for status updates
      FirebaseService.listenToStatus((status) {
        setState(() {
          statusMessage = 'Machine status: $status';
          if (status == 'done') {
            statusMessage = '🎉 Signature engraved successfully!';
            statusColor = const Color(0xFF06D6A0);
          }
        });
      });

    } catch (e) {
      setState(() {
        statusMessage = 'Error: $e';
        statusColor = const Color(0xFFE63946);
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laser Signature Machine',
            style: TextStyle(color: Color(0xFF00F5FF), fontSize: 16)),
        backgroundColor: const Color(0xFF0A1628),
      ),
      body: Column(children: [
        // Status bar
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF0F2240),
          child: Row(children: [
            if (isSending) const SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: Color(0xFF00B4D8))),
            if (isSending) const SizedBox(width: 8),
            Expanded(child: Text(statusMessage,
                style: TextStyle(color: statusColor, fontSize: 13))),
          ]),
        ),

        // Signature Canvas
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final Size size = constraints.biggest;
            return GestureDetector(
              onPanUpdate: (d) => onPanUpdate(d, size),
              onPanEnd: (_) => onPanEnd(),
              child: CustomPaint(
                size: size,
                painter: SignaturePainter(strokes, currentStroke),
              ),
            );
          }),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: clearSignature,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4A7AB5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('CLEAR', style: TextStyle(color: Color(0xFF4A7AB5))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSending ? null : sendToMachine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('🔴 SEND TO MACHINE',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Signature Painter — draws strokes on canvas ──
class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  SignaturePainter(this.strokes, this.currentStroke);

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFF040D1A));

    // Grid lines (faint)
    final gridPaint = Paint()
      ..color = const Color(0xFF0F2240)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Signature strokes paint
    final sigPaint = Paint()
      ..color = const Color(0xFF00F5FF)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      drawStroke(canvas, stroke, sigPaint);
    }
    // Draw current stroke being drawn
    drawStroke(canvas, currentStroke, sigPaint);

    // Instruction text if empty
    if (strokes.isEmpty && currentStroke.isEmpty) {
      final tp = TextPainter(
        text: const TextSpan(text: 'Sign here with your finger',
            style: TextStyle(color: Color(0xFF2A4070), fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height / 2));
    }
  }

  void drawStroke(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}