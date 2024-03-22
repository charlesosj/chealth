import 'dart:convert';

import 'package:health/health.dart';
import 'package:mysql1/mysql1.dart';

class My_DB {

  final settings =  ConnectionSettings(
  host: '192.168.1.3', 
  port: 32768,
  user: 'flutter',
  password: "lUZrU1@y\$XT4uHc*",
  db: 'myschema'
);
//
 late MySqlConnection conn;
var isConnected = false;
//set  last pull to yesterday
DateTime lastPull =  DateTime.now().subtract( const Duration(days: 1));


Future<void> connect() async{

  if(isConnected == true) return;

    try {
      conn = await MySqlConnection.connect(settings);
      isConnected = true;
       getLastPull();
    
    } catch (e) {
      print('Error: $e');
    }

    
 

}
// convert List<HealthDataPoint> to List<Map<String, dynamic>> with string being healthdata.hash and data being the entire healthdata converted to josn
List<Map<String, Object>> convert(List<HealthDataPoint> healthDataList) {
  //nvanterTipiClass.fromJson(json.decode(response.body));
  
  return healthDataList.map((e) => {'hash': e.hashCode, 'data': json.encode(e ) ,'device_id':e.deviceId ,'data_type':e.typeString,'unit':e.unitString,'date_to':e.dateTo.toUtc(),'date_from':e.dateFrom.toUtc(), 'source_name': e.sourceName , 'value': json.encode(e.value) }).toList();
}



// upsert multiple records from a list into dbo_incoming with fields hash and data, if hash exists update the record hash is the primary key
Future<void> upsert(List<Map<String, dynamic>> data) async
{
  var sql = 'INSERT INTO dbo_incoming (hash, data,device_id,data_type,unit,date_to,date_from,source_name,value) VALUES (?, ?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE hash = hash';

  try {
    await conn.queryMulti(sql, data.map((e) => [e['hash'], e['data'],e['device_id'],e['data_type'],e['unit'],e['date_to'],e['date_from'],e['source_name'],e['value']]).toList());
  } catch (e) {
    print('Error: $e');
  }
   await setLastPull();

}

//get lastPull date from dbo_settings where id = 1 in value varchar field and convert it to DateTime
Future<DateTime> getLastPull() async
{
  var sql = 'SELECT value FROM dbo_settings WHERE id = 1';
  var result = await conn.query(sql);
  lastPull = DateTime.parse(result.first[0]);

  return lastPull;

}

//upsert current date to dbo_settings where id = 1 in value varchar field
Future<void> setLastPull() async
{
  var sql = 'UPDATE dbo_settings SET value = ? WHERE id = 1';
  var now = DateTime.now();
  await conn.query(sql, [now.toIso8601String()]);
}




}