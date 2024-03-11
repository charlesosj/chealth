import 'package:chealth/src/infra/health_repository.dart';
import 'package:chealth/src/ui/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:chealth/src/ui/widgets/contentDataReady.dart';
import 'package:chealth/src/infra/health_repository.dart';
import 'package:health/health.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppState state = AppState.DATA_NOT_FETCHED;
  HealthRepository repository = HealthRepository();
  List<HealthDataPoint> healthDataList = [];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Home Page $state')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
          state = await   repository.fetchData();

            setState(() {
              healthDataList = repository.healthDataList;
              
            });
          },
          child: const Icon(Icons.refresh),
        ),
        body: ListView.builder(
        itemCount: healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = healthDataList[index];

          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text(p.unitString),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        })
     
       








    );
  }
}
