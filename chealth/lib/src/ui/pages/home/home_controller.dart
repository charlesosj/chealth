import 'package:chealth/src/util.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController {
  List<HealthDataPoint> _healthDataList = [];
  final types = dataTypesAndroid;
  late HealthFactory health ;
  Future authorize() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
     health = HealthFactory(useHealthConnectIfAvailable: true);

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

    if (authorized) {
      fetchData();
    }
  }

    Future fetchData() async {
 

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(hours: 24));

    // Clear old data points
    _healthDataList.clear();

    try {
      // fetch health data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(yesterday, now, types);
      // save all the new data points (only the first 100)
      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

    // print the results
    _healthDataList.forEach((x) => print(x));

    // update the UI to display the results
   
  }


}
