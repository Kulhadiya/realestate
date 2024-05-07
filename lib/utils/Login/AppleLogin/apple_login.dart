import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../lib/login_status.dart';
import '../lib/login_system.dart';

class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  @override
  void init() async {
    final AuthorizationCredentialAppleID appleIdCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );
  }

  Future<UserCredential?> login() async {
    if (credential != null) {
      final userCredential =
          await firebaseAuth.signInWithCredential(credential!);

      return userCredential;
    }
    return null;
  }

  @override
  void onEvent(MLoginState state) {}
}
