import '../../utils/api.dart';
import '../../utils/hive_utils.dart';

class SystemRepository {
  Future<Map> fetchSystemSettings({required bool isAnonymouse}) async {
    Map<String, dynamic> parameters = {};

    ///Passing user id here because we will hide sensitive details if there is no user id,
    ///With user id we will get user subscription package details
    if (!isAnonymouse) {
      if (HiveUtils.getUserId() != null) {
        print("UID IS ${HiveUtils.getUserId()}");
        parameters['user_id'] = HiveUtils.getUserId();
      }
    }
    // Stopwatch time = Stopwatch();
    // time.start();
    Map<String, dynamic> response = await Api.post(
        url: Api.apiGetSystemSettings,
        parameter: parameters,
        useAuthToken: !isAnonymouse);
    // time.stop();
    // print("SYSTEM SETTING TAKES ${time.elapsed.inSeconds}");
    return response;
  }
}
