import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/constant.dart';
import '../lib/login_status.dart';
import '../lib/login_system.dart';
import '../lib/payloads.dart';

class PhoneLogin extends LoginSystem {
  String? verificationId;

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      // (state);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId ?? "",
          smsCode: (payload as PhoneLoginPayload).getOTP()!);

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      emit(MSuccess());

      return userCredential;
    } catch (e) {
      emit(MFail(e));
    }
  }

  @override
  Future<void> requestVerification() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(
        seconds: Constant.otpTimeOutSecond,
      ),
      phoneNumber:
          "+${(payload as PhoneLoginPayload).countryCode}${(payload as PhoneLoginPayload).phoneNumber}",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        emit(MFail(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        super.requestVerification();
        PhoneLoginPayload.forceResendingtoken = resendToken;
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: PhoneLoginPayload.forceResendingtoken,
    );
  }

  @override
  void onEvent(MLoginState state) {}
}
