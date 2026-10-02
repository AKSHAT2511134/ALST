import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Reference to Firebase Realtime Database
  static final _db = FirebaseDatabase.instance;

  // Current job ID
  static String? currentJobId;

  /// Upload a new signing job to Firebase
  static Future<void> submitJob(String gcode) async {
    // Create unique job ID using timestamp
    currentJobId = 'job_${DateTime.now().millisecondsSinceEpoch}';

    // Write job data to Firebase path /jobs/{jobId}
    await _db.ref('jobs/$currentJobId').set({
      'gcode':     gcode,
      'status':    'pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'machineId': 'machine_001',
    });

    // Update machine status
    await _db.ref('machines/machine_001/lastJob').set(currentJobId);

    debugPrint('Job submitted: $currentJobId');
  }

  /// Listen for status changes on current job
  static void listenToStatus(void Function(String) onStatusChange) {
    if (currentJobId == null) return;

    // Firebase listener — fires every time status field changes
    _db.ref('jobs/$currentJobId/status').onValue.listen((event) {
      final status = event.snapshot.value as String? ?? 'unknown';
      onStatusChange(status);
    });
  }

  /// Check if machine is currently online
  static Future<bool> isMachineOnline() async {
    final snapshot = await _db.ref('machines/machine_001/online').get();
    return snapshot.value as bool? ?? false;
  }
}