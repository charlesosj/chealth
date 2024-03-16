import 'package:chealth/src/infra/health_repository.dart';
import 'package:chealth/src/infra/my_db.dart';
import 'package:chealth/src/util.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController {
  List<HealthDataPoint> healthDataList = [];
  final My_DB myDB = My_DB() ; 
  HealthRepository repository = HealthRepository();
  bool overideLastPullDateTrigger = false;
 
  

 

    //code to insert healthdata into the database
  Future<DateTime> insertData() async {
    if  (!myDB.isConnected) {
      await myDB.connect();
    }
 
    final data = myDB.convert(healthDataList);
    await myDB.upsert(data);


    return myDB.lastPull;
  }

  Future<void> initialize() async {
          await myDB.connect();
          await getLastPull();
    
  }

  Future fetchData( DateTime inputDate) async {
    await repository.fetchData( overideLastPullDateTrigger? inputDate:returnCurrentLastPUll());
    healthDataList = repository.healthDataList;
    overideLastPullDateTrigger = false;
  }

  // add data
  Future<void> addData() async {
    await repository.addData();
    healthDataList = repository.healthDataList;
  }

//insert data and return last pull date
  Future<void> getLastPull() async {
    await myDB.getLastPull();
  }

  DateTime  returnCurrentLastPUll(){

    return myDB.lastPull;
  }

  // overide last pull date
  void overideLastPull( DateTime _dt)  {
     myDB.lastPull = _dt; 
     overideLastPullDateTrigger = true;
  }
  



}


