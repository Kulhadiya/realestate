abstract class MLoginState {}

class MProgress extends MLoginState {}

class MVerificationPending extends MLoginState {
  // final String target;

  MVerificationPending();
}

class MSuccess extends MLoginState {}

class MFail extends MLoginState {
  final dynamic error;

  MFail(this.error);
}