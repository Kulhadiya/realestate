import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

import '../lib/login_status.dart';
import '../lib/login_system.dart';
import '../lib/payloads.dart';

class EmailLogin extends LoginSystem {
  @override
  Future<UserCredential?> login() async {
    UserCredential? userCredential;
    if (payload is EmailLoginPayload) {
      var _payload = (payload as EmailLoginPayload);
      if (_payload.type == EmailLoginType.signup) {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _payload.email,
          password: _payload.password,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _payload.email,
          password: _payload.password,
        );
      }
    }
    return userCredential;
  }

  @override
  void onEvent(MLoginState state) {
    log("MLOGIN STATE IS $state");
  }
}
