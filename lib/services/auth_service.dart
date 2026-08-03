import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current Firebase user
  User? get currentUser => _auth.currentUser;


  // Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }


  
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }


  
  Future<void> logout() async {
    await _auth.signOut();
  }


  
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}