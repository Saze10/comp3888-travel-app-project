import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/firebase_services/database_service.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  AuthenticationService(this._auth);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future signIn({required String email, required String password}) async{
      try {
        UserCredential result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        User? user = result.user;
        return user;
      } on FirebaseAuthException catch (e) {
        print(e.toString());
        return e.toString();
      }
  }

  Future signUp({required String email, required String password}) async{
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      await DatabaseService().setupUserData();
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future logout() async {
    await _auth.signOut();
  }

}