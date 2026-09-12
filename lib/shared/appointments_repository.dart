import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cloudinary_service.dart';

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

const String kConsultationInPerson = 'inPerson';
const String kConsultationVideo = 'video';

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
    this.consultationMode = kConsultationInPerson,
    this.meetingLink = '',
    this.prescription = '',
    this.doctorNotes = '',
    this.prescriptionDate,
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
      clinic: data['clinic']?.toString() ?? 'MentiFit Clinic',
      consultationMode:
          data['consultationMode']?.toString() ?? kConsultationInPerson,
      meetingLink: data['meetingLink']?.toString() ?? '',
      prescription: data['prescription']?.toString() ?? '',
      doctorNotes: data['doctorNotes']?.toString() ?? '',
      prescriptionDate: _parseFirestoreDate(data['prescriptionDate']),
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
  final String consultationMode;
  final String meetingLink;
  final String prescription;
  final String doctorNotes;
  final DateTime? prescriptionDate;

  bool get isVideoConsultation => consultationMode == kConsultationVideo;
  bool get hasPrescription => prescription.isNotEmpty || doctorNotes.isNotEmpty;

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
      'consultationMode': consultationMode,
      'meetingLink': meetingLink,
      'prescription': prescription,
      'doctorNotes': doctorNotes,
      if (prescriptionDate != null)
        'prescriptionDate': Timestamp.fromDate(prescriptionDate!),
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
    this.phone = '',
    this.qualifications = '',
    this.bio = '',
    this.reviewCount = 0,
    this.profileCompleted = false,
  });

  factory DoctorProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return DoctorProfile(
      id: doc.id,
      name: data['name']?.toString() ?? 'Doctor',
      specialty: data['specialty']?.toString() ?? 'General Medicine',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      clinic: data['clinic']?.toString() ?? 'MentiFit Clinic',
      location: data['location']?.toString() ?? '',
      fee: (data['fee'] as num?)?.toInt() ?? 0,
      nextAvailable: data['nextAvailable']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      qualifications: data['qualifications']?.toString() ?? '',
      bio: data['bio']?.toString() ?? '',
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      profileCompleted: data['profileCompleted'] == true,
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
  final String phone;
  final String qualifications;
  final String bio;
  final int reviewCount;
  final bool profileCompleted;
}

class DoctorReview {
  const DoctorReview({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.appointmentId = '',
  });

  factory DoctorReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final created = _parseFirestoreDate(data['createdAt']) ?? DateTime.now();
    return DoctorReview(
      id: doc.id,
      doctorId: data['doctorId']?.toString() ?? '',
      doctorName: data['doctorName']?.toString() ?? 'Doctor',
      patientId: data['patientId']?.toString() ?? '',
      patientName: data['patientName']?.toString() ?? 'Patient',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment']?.toString() ?? '',
      createdAt: created,
      appointmentId: data['appointmentId']?.toString() ?? '',
    );
  }

  final String id;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String appointmentId;

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'appointmentId': appointmentId,
    };
  }
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
    this.bloodGroup = '',
    this.address = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.allergies = const [],
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
      bloodGroup: data['bloodGroup']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      emergencyContactName: data['emergencyContactName']?.toString() ?? '',
      emergencyContactPhone: data['emergencyContactPhone']?.toString() ?? '',
      allergies: ((data['allergies'] as List?) ?? const [])
          .map((value) => value.toString())
          .toList(),
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
  final String bloodGroup;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final List<String> allergies;

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
      'bloodGroup': bloodGroup,
      'address': address,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'allergies': allergies,
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
          _allDoctors = snapshot.docs.map(DoctorProfile.fromFirestore).toList();
          _doctors = _allDoctors
              .where((doc) => doc.experienceYears > 0 || doc.profileCompleted)
              .toList()
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

    _reviewsSubscription = _firestore
        .collection('doctor_reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _reviews = snapshot.docs.map(DoctorReview.fromFirestore).toList();
          notifyListeners();
        });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _doctorSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _patientSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _appointmentSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _queueSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _documentSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _reviewsSubscription;

  List<DoctorProfile> _allDoctors = const [];
  List<DoctorProfile> _doctors = const [];
  List<Patient> _patients = const [];
  List<Appointment> _appointments = const [];
  List<QueueEntry> _queue = const [];
  List<HealthDocument> _documents = const [];
  List<DoctorReview> _reviews = const [];

  List<DoctorProfile> get doctors => List.unmodifiable(_doctors);
  List<DoctorProfile> get allDoctors => List.unmodifiable(_allDoctors);
  List<Patient> get patients => List.unmodifiable(_patients);
  List<Appointment> get all => List.unmodifiable(_appointments);
  List<QueueEntry> get queue => List.unmodifiable(_queue);
  List<HealthDocument> get documents => List.unmodifiable(_documents);
  List<DoctorReview> get reviews => List.unmodifiable(_reviews);

  List<DoctorReview> reviewsForDoctor(String doctorId) {
    return _reviews.where((r) => r.doctorId == doctorId).toList();
  }

  bool isAppointmentReviewed(String appointmentId) {
    if (appointmentId.isEmpty) return false;
    return _reviews.any((r) => r.appointmentId == appointmentId);
  }

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

  Patient? patientById(String? patientId) {
    if (patientId == null || patientId.isEmpty) return null;
    for (final patient in _patients) {
      if (patient.id == patientId || patient.userId == patientId) {
        return patient;
      }
    }
    return null;
  }

  DoctorProfile? doctorById(String? doctorId) {
    if (doctorId == null || doctorId.isEmpty) return null;
    for (final doctor in _allDoctors) {
      if (doctor.id == doctorId) return doctor;
    }
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
    String bloodGroup = '',
    String address = '',
    String emergencyContactName = '',
    String emergencyContactPhone = '',
    List<String> allergies = const [],
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
      bloodGroup: bloodGroup,
      address: address,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      allergies: allergies,
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
    String consultationMode = kConsultationInPerson,
    String meetingLink = '',
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
      'consultationMode': consultationMode,
      'meetingLink': meetingLink,
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

  Future<void> updateAppointmentMeetingLink(
    String appointmentId,
    String meetingLink,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).set({
      'meetingLink': meetingLink,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await _firestore.collection('appointments').doc(appointmentId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveAppointmentPrescription({
    required String appointmentId,
    required String prescription,
    required String doctorNotes,
    bool markCompleted = true,
  }) async {
    final updateData = <String, dynamic>{
      'prescription': prescription.trim(),
      'doctorNotes': doctorNotes.trim(),
      'prescriptionDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (markCompleted) {
      updateData['status'] = 'Completed';
    }
    await _firestore.collection('appointments').doc(appointmentId).set(
      updateData,
      SetOptions(merge: true),
    );
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
    final downloadUrl = await CloudinaryService.uploadBytes(
      fileBytes,
      fileName,
    );

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

  // Cloudinary's unsigned upload preset has no matching unsigned delete API,
  // so removing a document only clears the Firestore record; the file
  // itself remains on Cloudinary.
  Future<void> deleteDocument(String documentId, String fileUrl) async {
    await _firestore.collection('health_documents').doc(documentId).delete();
  }

  Future<void> addDoctorReview({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required double rating,
    required String comment,
    String? appointmentId,
  }) async {
    final newReview = DoctorReview(
      id: '',
      doctorId: doctorId,
      doctorName: doctorName,
      patientId: patientId,
      patientName: patientName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      appointmentId: appointmentId ?? '',
    );
    await _firestore.collection('doctor_reviews').add(newReview.toMap());

    // Calculate new aggregate rating for doctor
    final existingReviews = _reviews.where((r) => r.doctorId == doctorId).toList();
    final allRatings = [...existingReviews.map((r) => r.rating), rating];
    final avgRating = (allRatings.reduce((a, b) => a + b) / allRatings.length);
    final count = allRatings.length;

    await _firestore.collection('users').doc(doctorId).set({
      'rating': double.parse(avgRating.toStringAsFixed(1)),
      'reviewCount': count,
    }, SetOptions(merge: true));

    // If an appointment ID was provided, mark it as reviewed
    if (appointmentId != null && appointmentId.isNotEmpty) {
      await _firestore.collection('appointments').doc(appointmentId).set({
        'reviewed': true,
        'rating': rating,
      }, SetOptions(merge: true));
    }
  }

  @override
  void dispose() {
    _doctorSubscription?.cancel();
    _patientSubscription?.cancel();
    _appointmentSubscription?.cancel();
    _queueSubscription?.cancel();
    _documentSubscription?.cancel();
    _reviewsSubscription?.cancel();
    super.dispose();
  }
}

int mathMax(int a, int b) => a > b ? a : b;
