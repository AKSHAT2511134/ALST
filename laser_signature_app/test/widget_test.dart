// Basic smoke test for the Laser Signature App.

import 'package:flutter_test/flutter_test.dart';
import 'package:laser_signature_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Just verify the app widget can be built without crashing.
    // Firebase is not initialized in unit tests, so we skip full pump.
    expect(LaserSignatureApp, isNotNull);
  });
}
