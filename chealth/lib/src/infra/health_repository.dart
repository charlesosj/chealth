// ignore_for_file: constant_identifier_names, avoid_print

import 'package:chealth/src/util.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthRepository {
  AppState _state = AppState.DATA_NOT_FETCHED;
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> healthDataList = [];
  bool authorized = false;
  final types = dataTypesAndroid;

  //default constructor

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

    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
        _state = AppState.AUTHORIZED;
      } catch (error) {
        print("Exception in authorize: $error");
        _state = AppState.AUTH_NOT_GRANTED;
      }
    }

    print('authorized: $authorized');
  }

  Future fetchData({int days = 24}) async {
    if (!authorized) {
      authorize();
    }

    // get data within the last 24 hours
    final now = DateTime.now();
    final fetchDate = now.subtract(Duration(days: days));

    // Clear old data points
    healthDataList.clear();

    try {
      // fetch health data
      _state = AppState.FETCHING_DATA;
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(fetchDate, now, types);
      // save all the new data points (only the first 100)
      healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    healthDataList = HealthFactory.removeDuplicates(healthDataList);
    _state = AppState.DATA_READY;

    return _state;
  }

  Future revokeAccess() async {
    try {
      await health.revokePermissions();
     return _state = AppState.AUTH_NOT_GRANTED;
    } catch (error) {
      print("Caught exception in revokeAccess: $error");
    }
  }

}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
}
