import 'package:flutter/material.dart';

import '../../../shared/appointments_repository.dart';

export '../../../shared/appointments_repository.dart'
    show QueueEntry, QueuePriority, QueueStatus;

class QueueProvider extends ChangeNotifier {
  QueueProvider(this._repository) {
    _repository.addListener(_handleRepositoryUpdate);
  }

  final AppointmentsRepository _repository;

  List<QueueEntry> queueForDoctor(String doctorId) {
    return _repository.queueForDoctor(doctorId);
  }

  int waitingCountFor(String doctorId) {
    return queueForDoctor(
      doctorId,
    ).where((item) => item.status == QueueStatus.waiting).length;
  }

  int inConsultationCountFor(String doctorId) {
    return queueForDoctor(
      doctorId,
    ).where((item) => item.status == QueueStatus.inConsultation).length;
  }

  int completedCountFor(String doctorId) {
    return queueForDoctor(
      doctorId,
    ).where((item) => item.status == QueueStatus.completed).length;
  }

  int averageWaitFor(String doctorId) {
    final waiting = queueForDoctor(
      doctorId,
    ).where((item) => item.status == QueueStatus.waiting);
    if (waiting.isEmpty) return 0;
    final total = waiting.fold<int>(0, (sum, item) => sum + item.waitTime);
    return (total / waiting.length).round();
  }

  Future<void> addToQueue({
    required String doctorId,
    required String patientName,
    required String patientId,
    required String phone,
    required String reason,
    QueuePriority priority = QueuePriority.normal,
    int? waitTime,
  }) {
    return _repository.addToQueue(
      doctorId: doctorId,
      patientName: patientName,
      patientId: patientId,
      phone: phone,
      reason: reason,
      priority: priority,
      waitTime: waitTime,
    );
  }

  Future<void> startConsultation(String entryId) {
    return _repository.updateQueueStatus(entryId, QueueStatus.inConsultation);
  }

  Future<void> completeConsultation(String entryId) {
    return _repository.updateQueueStatus(entryId, QueueStatus.completed);
  }

  void _handleRepositoryUpdate() {
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_handleRepositoryUpdate);
    super.dispose();
  }
}
