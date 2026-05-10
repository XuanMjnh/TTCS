import 'package:firebase_auth/firebase_auth.dart';
import 'user_repository.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, UserRepository? userRepository})
      : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = cred.user;
    if (user != null) await _userRepository.upsertProfile(user);
    return cred;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required RegistrationProfile profile,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = cred.user;
    if (user != null) {
      await user.updateDisplayName(profile.fullName.trim());
      await _userRepository.upsertProfile(user, registrationProfile: profile);
    }
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
