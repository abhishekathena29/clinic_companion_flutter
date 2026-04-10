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
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  UserType _selectedType = UserType.doctor;
  UserType? _userType;
  String _profileName = '';
  String _profileClinic = '';
  String _profileSpecialty = '';

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
  bool get isAuthenticated => _user != null;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

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

  void updateEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void updatePassword(String value) {
    _password = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    _confirmPassword = value;
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
    if (_email.isEmpty || _password.isEmpty) {
      _error = 'Email and password are required.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      await _loadUserProfile(result.user);
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Unable to sign in. Please try again.';
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
    if (_email.isEmpty || _password.isEmpty) {
      _error = 'Email and password are required.';
      notifyListeners();
      return;
    }
    if (_password.length < 6) {
      _error = 'Password must be at least 6 characters.';
      notifyListeners();
      return;
    }
    if (_password != _confirmPassword) {
      _error = 'Passwords do not match.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      await result.user?.updateDisplayName(_name.trim());
      final userId = result.user?.uid;
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'name': _name.trim(),
        'email': _email,
        'userType': _selectedType.value,
        'specialty': _selectedType == UserType.doctor
            ? 'General Medicine'
            : null,
        'clinic': _selectedType == UserType.doctor ? 'Clinic Companion' : null,
        'location': 'Bengaluru',
        'fee': _selectedType == UserType.doctor ? 500 : null,
        'experienceYears': _selectedType == UserType.doctor ? 5 : null,
        'rating': _selectedType == UserType.doctor ? 4.8 : null,
        'nextAvailable': _selectedType == UserType.doctor
            ? 'Today, 5:00 PM'
            : null,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (_selectedType == UserType.patient && userId != null) {
        await _firestore.collection('patients').doc(userId).set({
          'userId': userId,
          'patientCode':
              'SV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          'name': _name.trim(),
          'email': _email,
          'phone': '',
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
      _error = e.message ?? 'Unable to create account. Please try again.';
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
    notifyListeners();
  }

  Future<void> updateDoctorProfile({
    required String name,
    required String clinic,
    String? specialty,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final trimmedName = name.trim();
    final trimmedClinic = clinic.trim();
    final trimmedSpecialty = specialty?.trim();

    _setLoading(true);
    _error = null;
    try {
      if (trimmedName.isNotEmpty && trimmedName != user.displayName) {
        await user.updateDisplayName(trimmedName);
      }

      await _firestore.collection('users').doc(user.uid).set({
        'name': trimmedName.isEmpty
            ? (_profileName.isEmpty ? 'Doctor' : _profileName)
            : trimmedName,
        'clinic': trimmedClinic,
        if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty)
          'specialty': trimmedSpecialty,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (trimmedName.isNotEmpty) {
        _profileName = trimmedName;
      }
      _profileClinic = trimmedClinic;
      if (trimmedSpecialty != null && trimmedSpecialty.isNotEmpty) {
        _profileSpecialty = trimmedSpecialty;
      }
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
        _userType = UserTypeX.tryParse(typeValue) ?? _selectedType;
        _selectedType = _userType ?? _selectedType;
      } else {
        _profileName = user.displayName ?? '';
        _profileClinic = '';
        _profileSpecialty = '';
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
