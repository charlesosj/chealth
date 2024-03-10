import 'package:chealth/src/util.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController {
  List<HealthDataPoint> _healthDataList = [];
  final types = dataTypesAndroid;

  Future authorize() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
    HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

    // Request access to the required data types
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have health permissions
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);


    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }

    print('authorized: $authorized');
  }
}
