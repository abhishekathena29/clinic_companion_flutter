import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum QueueStatus { waiting, inConsultation, completed, noShow }

enum QueuePriority { normal, urgent }

class QueueEntry {
  const QueueEntry({
    required this.id,
    required this.tokenNumber,
    required this.patientName,
    required this.patientId,
    required this.phone,
    required this.checkInTime,
    required this.waitTime,
    required this.status,
    required this.reason,
    required this.priority,
  });

  final String id;
  final int tokenNumber;
  final String patientName;
  final String patientId;
  final String phone;
  final String checkInTime;
  final int waitTime;
  final QueueStatus status;
  final String reason;
  final QueuePriority priority;
}

class QueueProvider extends ChangeNotifier {
  final List<QueueEntry> _queue = [
    const QueueEntry(
      id: '1',
      tokenNumber: 1,
      patientName: 'Priya Sharma',
      patientId: 'SV-2024-001',
      phone: '+91 98765 43210',
      checkInTime: '09:15 AM',
      waitTime: 45,
      status: QueueStatus.inConsultation,
      reason: 'Follow-up - Diabetes',
      priority: QueuePriority.normal,
    ),
    const QueueEntry(
      id: '2',
      tokenNumber: 2,
      patientName: 'Amit Patel',
      patientId: 'SV-2024-042',
      phone: '+91 87654 32109',
      checkInTime: '09:30 AM',
      waitTime: 30,
      status: QueueStatus.waiting,
      reason: 'Fever & Cold',
      priority: QueuePriority.urgent,
    ),
    const QueueEntry(
      id: '3',
      tokenNumber: 3,
      patientName: 'Sunita Devi',
      patientId: 'SV-2024-089',
      phone: '+91 76543 21098',
      checkInTime: '09:45 AM',
      waitTime: 15,
      status: QueueStatus.waiting,
      reason: 'BP Check',
      priority: QueuePriority.normal,
    ),
    const QueueEntry(
      id: '4',
      tokenNumber: 4,
      patientName: 'Rahul Singh',
      patientId: 'SV-2024-156',
      phone: '+91 65432 10987',
      checkInTime: '10:00 AM',
      waitTime: 5,
      status: QueueStatus.waiting,
      reason: 'New Patient Registration',
      priority: QueuePriority.normal,
    ),
    const QueueEntry(
      id: '5',
      tokenNumber: 5,
      patientName: 'Meera Joshi',
      patientId: 'SV-2024-203',
      phone: '+91 54321 09876',
      checkInTime: '10:05 AM',
      waitTime: 0,
      status: QueueStatus.waiting,
      reason: 'Lab Results',
      priority: QueuePriority.normal,
    ),
  ];

  List<QueueEntry> get queue => List.unmodifiable(_queue);

  int get waitingCount => _queue.where((p) => p.status == QueueStatus.waiting).length;
  int get inConsultationCount => _queue.where((p) => p.status == QueueStatus.inConsultation).length;
  int get completedCount => _queue.where((p) => p.status == QueueStatus.completed).length;

  int get averageWait {
    final waiting = _queue.where((p) => p.status == QueueStatus.waiting).toList();
    if (waiting.isEmpty) return 0;
    final total = waiting.fold<int>(0, (sum, p) => sum + p.waitTime);
    return (total / waiting.length).round();
  }

  void addToQueue({
    required String patientName,
    required String patientId,
    required String phone,
    required String reason,
    QueuePriority priority = QueuePriority.normal,
    int? waitTime,
  }) {
    final now = DateTime.now();
    final checkInTime = DateFormat('hh:mm a').format(now);
    final nextToken = _queue.isEmpty ? 1 : _queue.map((e) => e.tokenNumber).reduce((a, b) => a > b ? a : b) + 1;
    final computedWait = waitTime ?? (_queue.where((p) => p.status == QueueStatus.waiting).length * 8);

    _queue.add(
      QueueEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tokenNumber: nextToken,
        patientName: patientName,
        patientId: patientId,
        phone: phone,
        checkInTime: checkInTime,
        waitTime: computedWait,
        status: QueueStatus.waiting,
        reason: reason,
        priority: priority,
      ),
    );
    notifyListeners();
  }
}
