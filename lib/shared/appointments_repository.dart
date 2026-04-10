import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime? _parseFirestoreDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) return parsed;

    for (final pattern in const ['dd/MM/yyyy', 'd/M/yyyy', 'dd-MM-yyyy']) {
      try {
        return DateFormat(pattern).parseStrict(trimmed);
      } catch (_) {
        continue;
      }
    }
  }
  return null;
}

class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.patient,
    required this.doctorId,
    required this.doctor,
    required this.time,
    required this.type,
    required this.duration,
    required this.status,
    required this.date,
    required this.specialty,
    required this.clinic,
  });

  factory Appointment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final date = _parseFirestoreDate(data['date']) ?? DateTime.now();

    return Appointment(
      id: doc.id,
      patientId: data['patientId']?.toString() ?? '',
      patient: data['patientName']?.toString() ?? 'Unknown Patient',
      doctorId: data['doctorId']?.toString() ?? '',
      doctor: data['doctorName']?.toString() ?? 'Unknown Doctor',
      time: data['time']?.toString() ?? DateFormat('hh:mm a').format(date),
      type: data['type']?.toString() ?? 'Consultation',
      duration: data['duration']?.toString() ?? '20 min',
      status: data['status']?.toString() ?? 'Pending',
      date: date,
      specialty: data['specialty']?.toString() ?? 'General Medicine',
      clinic: data['clinic']?.toString() ?? 'Clinic Companion',
    );
  }

  final String id;
  final String patientId;
  final String patient;
  final String doctorId;
  final String doctor;
  final String time;
  final String type;
  final String duration;
  final String status;
  final DateTime date;
  final String specialty;
  final String clinic;

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patient,
      'doctorId': doctorId,
      'doctorName': doctor,
      'time': time,
      'type': type,
      'duration': duration,
      'status': status,
      'date': Timestamp.fromDate(date),
      'specialty': specialty,
      'clinic': clinic,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.clinic,
    required this.location,
    required this.fee,
    required this.nextAvailable,
    required this.email,
  });

  factory DoctorProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return DoctorProfile(
      id: doc.id,
      name: data['name']?.toString() ?? 'Doctor',
      specialty: data['specialty']?.toString() ?? 'General Medicine',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 5,
      clinic: data['clinic']?.toString() ?? 'Clinic Companion',
      location: data['location']?.toString() ?? 'Bengaluru',
      fee: (data['fee'] as num?)?.toInt() ?? 500,
      nextAvailable: data['nextAvailable']?.toString() ?? 'Next available',
      email: data['email']?.toString() ?? '',
    );
  }

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int experienceYears;
  final String clinic;
  final String location;
  final int fee;
  final String nextAvailable;
  final String email;
}

class Patient {
  const Patient({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.lastVisit,
    required this.totalVisits,
    required this.conditions,
    required this.status,
    required this.userId,
    required this.email,
  });

  factory Patient.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final lastVisit = _parseFirestoreDate(data['lastVisit']);
    return Patient(
      id: doc.id,
      patientId: data['patientCode']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? 'Patient',
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender']?.toString() ?? 'O',
      phone: data['phone']?.toString() ?? '',
      lastVisit: lastVisit == null
          ? data['lastVisit']?.toString() ?? ''
          : DateFormat('yyyy-MM-dd').format(lastVisit),
      totalVisits: (data['totalVisits'] as num?)?.toInt() ?? 0,
      conditions: ((data['conditions'] as List?) ?? const [])
          .map((value) => value.toString())
          .toList(),
      status: data['status']?.toString() ?? 'active',
      userId: data['userId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
    );
  }

  final String id;
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String lastVisit;
  final int totalVisits;
  final List<String> conditions;
  final String status;
  final String userId;
  final String email;

  Map<String, dynamic> toMap() {
    return {
      'patientCode': patientId,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'lastVisit': lastVisit,
      'totalVisits': totalVisits,
      'conditions': conditions,
      'status': status,
      'userId': userId,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

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
    required this.doctorId,
  });

  factory QueueEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final checkedInAt = (data['checkInAt'] as Timestamp?)?.toDate();
    return QueueEntry(
      id: doc.id,
      tokenNumber: (data['tokenNumber'] as num?)?.toInt() ?? 0,
      patientName: data['patientName']?.toString() ?? 'Patient',
      patientId: data['patientCode']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      checkInTime: checkedInAt == null
          ? '--'
          : DateFormat('hh:mm a').format(checkedInAt),
      waitTime: (data['waitTime'] as num?)?.toInt() ?? 0,
      status: _queueStatusFromString(data['status']?.toString()),
      reason: data['reason']?.toString() ?? 'Consultation',
      priority: _queuePriorityFromString(data['priority']?.toString()),
      doctorId: data['doctorId']?.toString() ?? '',
    );
  }

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
  final String doctorId;
}

QueueStatus _queueStatusFromString(String? value) {
  switch (value) {
    case 'inConsultation':
      return QueueStatus.inConsultation;
    case 'completed':
      return QueueStatus.completed;
    case 'noShow':
      return QueueStatus.noShow;
    case 'waiting':
    default:
      return QueueStatus.waiting;
  }
}

QueuePriority _queuePriorityFromString(String? value) {
  switch (value) {
    case 'urgent':
      return QueuePriority.urgent;
    case 'normal':
    default:
      return QueuePriority.normal;
  }
}

String queueStatusValue(QueueStatus status) {
  switch (status) {
    case QueueStatus.waiting:
      return 'waiting';
    case QueueStatus.inConsultation:
      return 'inConsultation';
    case QueueStatus.completed:
      return 'completed';
    case QueueStatus.noShow:
      return 'noShow';
  }
}

String queuePriorityValue(QueuePriority priority) {
  switch (priority) {
    case QueuePriority.normal:
      return 'normal';
    case QueuePriority.urgent:
      return 'urgent';
  }
}

class HealthDocument {
  const HealthDocument({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.uploadedById,
    required this.uploadedByName,
    required this.uploadedByRole,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.category,
    required this.notes,
    required this.uploadedAt,
  });

  factory HealthDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return HealthDocument(
      id: doc.id,
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? '',
      uploadedById: data['uploadedById']?.toString() ?? '',
      uploadedByName: data['uploadedByName']?.toString() ?? '',
      uploadedByRole: data['uploadedByRole']?.toString() ?? 'patient',
      fileName: data['fileName']?.toString() ?? '',
      fileUrl: data['fileUrl']?.toString() ?? '',
      fileType: data['fileType']?.toString() ?? '',
      category: data['category']?.toString() ?? 'General',
      notes: data['notes']?.toString() ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  final String id;
  final String patientId;
  final String patientName;
  final String uploadedById;
  final String uploadedByName;
  final String uploadedByRole;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String category;
  final String notes;
  final DateTime uploadedAt;
}

class AppointmentsRepository extends ChangeNotifier {
  AppointmentsRepository() {
    _doctorSubscription = _firestore
        .collection('users')
        .where('userType', isEqualTo: 'doctor')
        .snapshots()
        .listen((snapshot) {
          _doctors = snapshot.docs.map(DoctorProfile.fromFirestore).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          notifyListeners();
        });

    _patientSubscription = _firestore.collection('patients').snapshots().listen(
      (snapshot) {
        _patients = snapshot.docs.map(Patient.fromFirestore).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      },
    );

    _appointmentSubscription = _firestore
        .collection('appointments')
        .snapshots()
        .listen((snapshot) {
          _appointments = snapshot.docs.map(Appointment.fromFirestore).toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          notifyListeners();
        });

    _queueSubscription = _firestore.collection('queue').snapshots().listen((
      snapshot,
    ) {
      _queue = snapshot.docs.map(QueueEntry.fromFirestore).toList()
        ..sort((a, b) => a.tokenNumber.compareTo(b.tokenNumber));
      notifyListeners();
    });

    _documentSubscription = _firestore
        .collection('health_documents')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _documents =
              snapshot.docs.map(HealthDocument.fromFirestore).toList();
          notifyListeners();
        });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _doctorSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _patientSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _appointmentSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _queueSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _documentSubscription;

  List<DoctorProfile> _doctors = const [];
  List<Patient> _patients = const [];
  List<Appointment> _appointments = const [];
  List<QueueEntry> _queue = const [];
  List<HealthDocument> _documents = const [];

  List<DoctorProfile> get doctors => List.unmodifiable(_doctors);
  List<Patient> get patients => List.unmodifiable(_patients);
  List<Appointment> get all => List.unmodifiable(_appointments);
  List<QueueEntry> get queue => List.unmodifiable(_queue);
  List<HealthDocument> get documents => List.unmodifiable(_documents);

  List<HealthDocument> documentsForPatient(String patientId) {
    return _documents
        .where((doc) => doc.patientId == patientId)
        .toList();
  }

  Patient? patientForUser(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final patient in _patients) {
      if (patient.userId == userId) return patient;
    }
    return null;
  }

  DoctorProfile? doctorById(String? doctorId) {
    if (doctorId == null || doctorId.isEmpty) return null;
    for (final doctor in _doctors) {
      if (doctor.id == doctorId) return doctor;
    }
    return null;
  }

  List<Appointment> forDate(DateTime date, {String? doctorId}) {
    return _appointments.where((appointment) {
      final matchesDate =
          appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
      final matchesDoctor =
          doctorId == null ||
          doctorId.isEmpty ||
          appointment.doctorId == doctorId;
      return matchesDate && matchesDoctor;
    }).toList();
  }

  List<Appointment> forPatient(String patientId) {
    return _appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  List<Appointment> forDoctor(String doctorId) {
    return _appointments
        .where((appointment) => appointment.doctorId == doctorId)
        .toList();
  }

  List<QueueEntry> queueForDoctor(String doctorId) {
    return _queue.where((entry) => entry.doctorId == doctorId).toList();
  }

  Future<void> addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    required List<String> conditions,
    String status = 'active',
    String userId = '',
    String email = '',
  }) async {
    final doc = _firestore.collection('patients').doc();
    final nextIndex = (_patients.length + 1).toString().padLeft(3, '0');
    final now = DateTime.now();

    final patient = Patient(
      id: doc.id,
      patientId: 'SV-${now.year}-$nextIndex',
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      lastVisit: DateFormat('yyyy-MM-dd').format(now),
      totalVisits: 1,
      conditions: conditions,
      status: status,
      userId: userId,
      email: email,
    );

    await doc.set({
      ...patient.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> upsertPatientProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final existing = patientForUser(userId);
    final now = DateTime.now();
    final patientId =
        existing?.patientId ??
        'SV-${now.year}-${(_patients.length + 1).toString().padLeft(3, '0')}';

    await _firestore.collection('patients').doc(userId).set({
      'patientCode': patientId,
      'name': name,
      'email': email,
      'phone': phone,
      'age': existing?.age ?? 0,
      'gender': existing?.gender ?? 'O',
      'conditions': existing?.conditions ?? const <String>[],
      'status': existing?.status ?? 'active',
      'totalVisits': existing?.totalVisits ?? 0,
      'lastVisit': existing?.lastVisit ?? '',
      'userId': userId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addAppointment({
    required String patientId,
    required String patient,
    required String doctorId,
    required String doctor,
    required String specialty,
    required String clinic,
    required DateTime date,
    required String time,
    required String type,
    required String duration,
    String status = 'Pending',
  }) async {
    await _firestore.collection('appointments').add({
      'patientId': patientId,
      'patientName': patient,
      'doctorId': doctorId,
      'doctorName': doctor,
      'specialty': specialty,
      'clinic': clinic,
      'date': Timestamp.fromDate(date),
      'time': time,
      'type': type,
      'duration': duration,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final linkedPatient = _patients.cast<Patient?>().firstWhere(
      (item) => item?.id == patientId || item?.userId == patientId,
      orElse: () => null,
    );
    if (linkedPatient != null) {
      await _firestore.collection('patients').doc(linkedPatient.id).set({
        'lastVisit': DateFormat('yyyy-MM-dd').format(date),
        'totalVisits': linkedPatient.totalVisits + 1,
      }, SetOptions(merge: true));
    }
  }

  Future<void> addToQueue({
    required String doctorId,
    required String patientName,
    required String patientId,
    required String phone,
    required String reason,
    QueuePriority priority = QueuePriority.normal,
    int? waitTime,
  }) async {
    final entries = queueForDoctor(doctorId);
    final nextToken = entries.isEmpty
        ? 1
        : entries.map((entry) => entry.tokenNumber).reduce(mathMax) + 1;
    final estimatedWait =
        waitTime ??
        entries.where((entry) => entry.status == QueueStatus.waiting).length *
            8;

    await _firestore.collection('queue').add({
      'doctorId': doctorId,
      'patientName': patientName,
      'patientCode': patientId,
      'phone': phone,
      'reason': reason,
      'priority': queuePriorityValue(priority),
      'status': queueStatusValue(QueueStatus.waiting),
      'tokenNumber': nextToken,
      'waitTime': estimatedWait,
      'checkInAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQueueStatus(String entryId, QueueStatus status) async {
    await _firestore.collection('queue').doc(entryId).set({
      'status': queueStatusValue(status),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> uploadDocument({
    required String patientId,
    required String patientName,
    required String uploadedById,
    required String uploadedByName,
    required String uploadedByRole,
    required String fileName,
    required Uint8List fileBytes,
    required String category,
    String notes = '',
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last : 'pdf';
    final storagePath =
        'health_documents/$patientId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final ref = _storage.ref(storagePath);
    final metadata = SettableMetadata(
      contentType: _mimeType(ext),
    );
    await ref.putData(fileBytes, metadata);
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('health_documents').add({
      'patientId': patientId,
      'patientName': patientName,
      'uploadedById': uploadedById,
      'uploadedByName': uploadedByName,
      'uploadedByRole': uploadedByRole,
      'fileName': fileName,
      'fileUrl': downloadUrl,
      'fileType': ext,
      'category': category,
      'notes': notes,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDocument(String documentId, String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (_) {
      // File may already be deleted from storage
    }
    await _firestore.collection('health_documents').doc(documentId).delete();
  }

  static String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void dispose() {
    _doctorSubscription?.cancel();
    _patientSubscription?.cancel();
    _appointmentSubscription?.cancel();
    _queueSubscription?.cancel();
    _documentSubscription?.cancel();
    super.dispose();
  }
}

int mathMax(int a, int b) => a > b ? a : b;
