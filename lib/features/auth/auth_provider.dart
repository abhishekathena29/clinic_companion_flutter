import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_type.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _subscription = _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _loadUserProfile(user);
      } else {
        _userType = null;
        _profileName = '';
      }
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
  String? _error;

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  UserType _selectedType = UserType.doctor;
  UserType? _userType;
  String _profileName = '';

  User? _user;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  UserType get selectedType => _selectedType;
  UserType? get userType => _userType;
  String get profileName => _profileName.isEmpty ? (_user?.displayName ?? '') : _profileName;
  bool get isAuthenticated => _user != null;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  UserType get effectiveUserType => _userType ?? _selectedType;
  String get homeRoute => effectiveUserType == UserType.doctor ? '/doctor' : '/patient';

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
      final result = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
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
      final result = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      await result.user?.updateDisplayName(_name.trim());
      await _firestore.collection('users').doc(result.user?.uid).set(
        {
          'uid': result.user?.uid,
          'name': _name.trim(),
          'email': _email,
          'userType': _selectedType.value,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
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
        _userType = UserTypeX.tryParse(typeValue) ?? _selectedType;
        _selectedType = _userType ?? _selectedType;
      } else {
        _profileName = user.displayName ?? '';
        _userType = _selectedType;
      }

      if (_userType != null && (doc.data()?['userType'] == null)) {
        await _firestore.collection('users').doc(user.uid).set(
          {'userType': _userType!.value},
          SetOptions(merge: true),
        );
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
