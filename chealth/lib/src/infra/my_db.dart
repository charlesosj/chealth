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


Future<void> connect() async{

  if(isConnected == true) return;

    try {
      conn = await MySqlConnection.connect(settings);
      isConnected = true;
    } catch (e) {
      print('Error: $e');
    }

    
  
    

}
// convert List<HealthDataPoint> to List<Map<String, dynamic>> with string being healthdata.hash and data being the entire healthdata converted to josn
List<Map<String, Object>> convert(List<HealthDataPoint> healthDataList) {
  //nvanterTipiClass.fromJson(json.decode(response.body));
  
  return healthDataList.map((e) => {'hash': e.hashCode, 'data': json.encode(e )}).toList();
}



// upsert multiple records from a list into dbo_incoming with fields hash and data, if hash exists update the record hash is the primary key
Future<void> upsert(List<Map<String, dynamic>> data) async
{
  var sql = 'INSERT INTO dbo_incoming (hash, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE data = ?';

  try {
    await conn.queryMulti(sql, data.map((e) => [e['hash'], e['data'], e['data']]).toList());
  } catch (e) {
    print('Error: $e');
  }
  //await conn.queryMulti(sql, data as Iterable<List<Object?>>);

}

}