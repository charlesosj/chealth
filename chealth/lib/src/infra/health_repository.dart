// ignore_for_file: constant_identifier_names, avoid_print

import 'package:chealth/src/infra/my_db.dart';
import 'package:chealth/src/util.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthRepository {
  AppState _state = AppState.DATA_NOT_FETCHED;
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  List<HealthDataPoint> healthDataList = [];
  bool authorized = false;

  final types = dataTypesAndroid;

  //default constructor

  Future authorize() async {
   // final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();
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

  Future fetchData(DateTime from , DateTime to ) async {
    if (!authorized) {
      authorize();
    }

    // get data within the last 24 hours


    // Clear old data points
    healthDataList.clear();

    try {
      // fetch health data
      _state = AppState.FETCHING_DATA;
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(from, to, types);
      // save all the new data points (only the first 100)
      //healthDataList.addAll((healthData.length < 100) ? healthData : healthData.sublist(0, 100));
      healthDataList.addAll(healthData);
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    // filter out duplicates
    healthDataList = HealthFactory.removeDuplicates(healthDataList);
    _state = AppState.DATA_READY;

    return healthDataList;
  }

  Future revokeAccess() async {
    try {
      await health.revokePermissions();
     return _state = AppState.AUTH_NOT_GRANTED;
    } catch (error) {
      print("Caught exception in revokeAccess: $error");
    }
  }

    Future addData() async {
    final now = DateTime.now();
    final earlier = now.subtract( const Duration(minutes: 20));

    // Add data for supported types
    // NOTE: These are only the ones supported on Androids new API Health Connect.
    // Both Android's Google Fit and iOS' HealthKit have more types that we support in the enum list [HealthDataType]
    // Add more - like AUDIOGRAM, HEADACHE_SEVERE etc. to try them.
    bool success = true;
    success &= await health.writeHealthData(
        1.925, HealthDataType.HEIGHT, earlier, now);
    success &=
        await health.writeHealthData(90, HealthDataType.WEIGHT, earlier, now);
    success &= await health.writeHealthData(
        90, HealthDataType.HEART_RATE, earlier, now);
    success &=
        await health.writeHealthData(90, HealthDataType.STEPS, earlier, now);
    success &= await health.writeHealthData(
        200, HealthDataType.ACTIVE_ENERGY_BURNED, earlier, now);
    success &= await health.writeHealthData(
        70, HealthDataType.HEART_RATE, earlier, now);
    success &= await health.writeHealthData(
        37, HealthDataType.BODY_TEMPERATURE, earlier, now);
    success &= await health.writeBloodOxygen(98, earlier, now, flowRate: 1.0);
    success &= await health.writeHealthData(
        105, HealthDataType.BLOOD_GLUCOSE, earlier, now);
    success &=
        await health.writeHealthData(1.8, HealthDataType.WATER, earlier, now);
    success &= await health.writeWorkoutData(
        HealthWorkoutActivityType.AMERICAN_FOOTBALL,
        now.subtract(Duration(minutes: 15)),
        now,
        totalDistance: 2430,
        totalEnergyBurned: 400);
    success &= await health.writeBloodPressure(90, 80, earlier, now);
    success &= await health.writeHealthData(
        0.0, HealthDataType.SLEEP_DEEP, earlier, now);
    success &= await health.writeMeal(
        earlier, now, 1000, 50, 25, 50, "Banana", MealType.SNACK);
    // Store an Audiogram
    // Uncomment these on iOS - only available on iOS
    // const frequencies = [125.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0];
    // const leftEarSensitivities = [49.0, 54.0, 89.0, 52.0, 77.0, 35.0];
    // const rightEarSensitivities = [76.0, 66.0, 90.0, 22.0, 85.0, 44.5];

    // success &= await health.writeAudiogram(
    //   frequencies,
    //   leftEarSensitivities,
    //   rightEarSensitivities,
    //   now,
    //   now,
    //   metadata: {
    //     "HKExternalUUID": "uniqueID",
    //     "HKDeviceName": "bluetooth headphone",
    //   },
    // );


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
