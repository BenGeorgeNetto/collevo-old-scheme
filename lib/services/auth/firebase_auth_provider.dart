import 'package:collevo/firebase_options.dart';
import 'package:collevo/services/auth/auth_exceptions.dart';
import 'package:collevo/services/auth/auth_provider.dart';
import 'package:collevo/services/auth/auth_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Failed to create user',
        information: ['email: $email'],
      );
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e, s) {
      if (e.code == 'user-not-found') {
        await FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: 'User not found',
          information: ['email: $email'],
        );
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        await FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: 'Wrong password',
          information: ['email: $email'],
        );
        throw WrongPasswordAuthException();
      } else {
        await FirebaseCrashlytics.instance.recordError(
          e,
          s,
          reason: 'Failed to log in',
          information: ['email: $email'],
        );
        throw GenericAuthException();
      }
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Failed to log in',
        information: ['email: $email'],
      );
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'firebase_auth/user-not-found':
          throw UserNotFoundAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e, s) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Failed to send password reset email',
        information: ['email: $toEmail'],
      );
      throw GenericAuthException();
    }
  }
}
