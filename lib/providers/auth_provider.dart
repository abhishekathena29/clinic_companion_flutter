import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _subscription = _auth.authStateChanges().listen((user) {
      _user = user;
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

  User? _user;

  bool get isLogin => _isLogin;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

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
      await _auth.signInWithEmailAndPassword(email: _email, password: _password);
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
      await _firestore.collection('users').doc(result.user?.uid).set({
        'uid': result.user?.uid,
        'name': _name.trim(),
        'email': _email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Unable to create account. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
