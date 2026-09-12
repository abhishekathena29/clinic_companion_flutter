import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_type.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _subscription = _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _loadUserProfile(user);
      } else {
        _userType = null;
        _profileName = '';
        _profileClinic = '';
        _profileSpecialty = '';
      }
      _isInitializing = false;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _subscription;

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  String _name = '';
  String _phone = '';
  String _pin = '';
  String _confirmPin = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  UserType _selectedType = UserType.doctor;
  UserType? _userType;
  String _profileName = '';
  String _profileClinic = '';
  String _profileSpecialty = '';
  String _profilePhone = '';
  int _profileExperienceYears = 0;
  String _profileQualifications = '';
  int _profileFee = 0;
  String _profileBio = '';
  bool _profileCompleted = false;

  User? _user;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  User? get user => _user;
  UserType get selectedType => _selectedType;
  UserType? get userType => _userType;
  String get profileName =>
      _profileName.isEmpty ? (_user?.displayName ?? '') : _profileName;
  String get profileClinic => _profileClinic;
  String get profileSpecialty => _profileSpecialty;
  String get profilePhone => _profilePhone.isNotEmpty ? _profilePhone : _phone;
  int get profileExperienceYears => _profileExperienceYears;
  String get profileQualifications => _profileQualifications;
  int get profileFee => _profileFee;
  String get profileBio => _profileBio;
  bool get isProfileCompleted =>
      _profileCompleted || (_profileExperienceYears > 0 && _profileSpecialty.isNotEmpty);
  bool get isAuthenticated => _user != null;

  String get name => _name;
  String get phone => _phone;
  String get pin => _pin;
  String get confirmPin => _confirmPin;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  static String cleanPhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String phoneToEmail(String raw) {
    final cleaned = cleanPhone(raw);
    return '$cleaned@mentifit.com';
  }

  UserType get effectiveUserType => _userType ?? _selectedType;
  String get homeRoute =>
      effectiveUserType == UserType.doctor ? '/doctor' : '/patient';

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void toggleMode() {
    _isLogin = !_isLogin;
    _error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value.trim();
    _email = phoneToEmail(_phone);
    notifyListeners();
  }

  void updatePin(String value) {
    _pin = value.trim();
    _password = _pin;
    notifyListeners();
  }

  void updateConfirmPin(String value) {
    _confirmPin = value.trim();
    _confirmPassword = _confirmPin;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    _pin = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPin = value;
    notifyListeners();
  }

  void updateUserType(UserType value) {
    _selectedType = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_isLogin) {
      await signIn();
    } else {
      await signUp();
    }
  }

  Future<void> signIn() async {
    _error = null;
    final cleaned = cleanPhone(_phone);
    if (cleaned.isEmpty) {
      _error = 'Phone number is required.';
      notifyListeners();
      return;
    }
    if (cleaned.length < 10) {
      _error = 'Please enter a valid phone number (at least 10 digits).';
      notifyListeners();
      return;
    }
    if (_pin.isEmpty) {
      _error = '6-digit PIN is required.';
      notifyListeners();
      return;
    }
    if (_pin.length != 6) {
      _error = 'PIN must be exactly 6 digits.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final emailAddress = phoneToEmail(_phone);
      final result = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: _pin,
      );
      await _loadUserProfile(result.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _error = 'Invalid phone number or 6-digit PIN.';
      } else {
        _error = e.message ?? 'Unable to sign in. Please try again.';
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp() async {
    _error = null;
    if (_name.trim().isEmpty) {
      _error = 'Full name is required.';
      notifyListeners();
      return;
    }
    final cleaned = cleanPhone(_phone);
    if (cleaned.isEmpty) {
      _error = 'Phone number is required.';
      notifyListeners();
      return;
    }
    if (cleaned.length < 10) {
      _error = 'Please enter a valid phone number (at least 10 digits).';
      notifyListeners();
      return;
    }
    if (_pin.isEmpty) {
      _error = '6-digit PIN is required.';
      notifyListeners();
      return;
    }
    if (_pin.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(_pin)) {
      _error = 'PIN must be exactly 6 digits (numbers only).';
      notifyListeners();
      return;
    }
    if (_pin != _confirmPin) {
      _error = 'PINs do not match.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final emailAddress = phoneToEmail(_phone);
      final result = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: _pin,
      );
      await result.user?.updateDisplayName(_name.trim());
      final userId = result.user?.uid;
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': _name.trim(),
        'email': emailAddress,
        'phone': cleaned,
        'userType': _selectedType.value,
        'specialty': _selectedType == UserType.doctor
            ? 'General Medicine'
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (_selectedType == UserType.patient && userId != null) {
        await _firestore.collection('patients').doc(userId).set({
          'userId': userId,
          'patientCode':
              'SV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          'name': _name.trim(),
          'email': emailAddress,
          'phone': cleaned,
          'age': 0,
          'gender': 'O',
          'conditions': const <String>[],
          'status': 'active',
          'totalVisits': 0,
          'lastVisit': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await _loadUserProfile(result.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _error = 'An account with this phone number already exists.';
      } else {
        _error = e.message ?? 'Unable to create account. Please try again.';
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userType = null;
    _profileName = '';
    _profileClinic = '';
    _profileSpecialty = '';
    _profilePhone = '';
    _profileExperienceYears = 0;
    _profileQualifications = '';
    _profileFee = 0;
    _profileBio = '';
    _profileCompleted = false;
    notifyListeners();
  }

  Future<void> updateDoctorProfile({
    required String name,
    required String clinic,
    String? specialty,
    String? phone,
    int? experienceYears,
    String? qualifications,
    int? fee,
    String? bio,
    bool? profileCompleted,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmedName = name.trim();
    final trimmedClinic = clinic.trim();
    final trimmedSpecialty = specialty?.trim();
    final trimmedPhone = phone?.trim();
    final trimmedQualifications = qualifications?.trim();
    final trimmedBio = bio?.trim();

    _setLoading(true);
    _error = null;
    try {
      if (trimmedName.isNotEmpty && trimmedName != user.displayName) {
        await user.updateDisplayName(trimmedName);
      }

      final isCompleted = profileCompleted ??
          ((experienceYears ?? _profileExperienceYears) > 0);

      await _firestore.collection('users').doc(user.uid).set({
        'name': trimmedName.isEmpty
            ? (_profileName.isEmpty ? 'Doctor' : _profileName)
            : trimmedName,
        'clinic': trimmedClinic,
        if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty)
          'specialty': trimmedSpecialty,
        if (trimmedPhone != null) 'phone': trimmedPhone,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (trimmedQualifications != null)
          'qualifications': trimmedQualifications,
        if (fee != null) 'fee': fee,
        if (trimmedBio != null) 'bio': trimmedBio,
        'profileCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (trimmedName.isNotEmpty) {
        _profileName = trimmedName;
      }
      _profileClinic = trimmedClinic;
      if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty) {
        _profileSpecialty = trimmedSpecialty;
      }
      if (trimmedPhone != null) {
        _profilePhone = trimmedPhone;
      }
      if (experienceYears != null) {
        _profileExperienceYears = experienceYears;
      }
      if (trimmedQualifications != null) {
        _profileQualifications = trimmedQualifications;
      }
      if (fee != null) {
        _profileFee = fee;
      }
      if (trimmedBio != null) {
        _profileBio = trimmedBio;
      }
      _profileCompleted = isCompleted;
      notifyListeners();
    } on FirebaseException catch (e) {
      _error = e.message ?? 'Unable to update profile.';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> sendPasswordReset() async {
    _error = null;
    if (_email.isEmpty) {
      _error = 'Enter your email address first.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: _email);
      return 'Password reset email sent to $_email.';
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Unable to send password reset email.';
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile(User? user) async {
    if (user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final name = data?['name']?.toString() ?? user.displayName ?? '';
        final typeValue = data?['userType']?.toString();
        _profileName = name;
        _profileClinic = data?['clinic']?.toString() ?? '';
        _profileSpecialty = data?['specialty']?.toString() ?? '';
        _profilePhone = data?['phone']?.toString() ?? '';
        _profileExperienceYears =
            (data?['experienceYears'] as num?)?.toInt() ?? 0;
        _profileQualifications = data?['qualifications']?.toString() ?? '';
        _profileFee = (data?['fee'] as num?)?.toInt() ?? 0;
        _profileBio = data?['bio']?.toString() ?? '';
        _profileCompleted = data?['profileCompleted'] == true ||
            _profileExperienceYears > 0;
        _userType = UserTypeX.tryParse(typeValue) ?? _selectedType;
        _selectedType = _userType ?? _selectedType;
      } else {
        _profileName = user.displayName ?? '';
        _profileClinic = '';
        _profileSpecialty = '';
        _profilePhone = '';
        _profileExperienceYears = 0;
        _profileQualifications = '';
        _profileFee = 0;
        _profileBio = '';
        _profileCompleted = false;
        _userType = _selectedType;
      }

      if (_userType != null && (doc.data()?['userType'] == null)) {
        await _firestore.collection('users').doc(user.uid).set({
          'userType': _userType!.value,
        }, SetOptions(merge: true));
      }
    } catch (_) {
      _userType = _selectedType;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
