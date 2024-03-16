import 'dart:math';

import 'package:chealth/src/infra/health_repository.dart';
import 'package:chealth/src/ui/pages/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
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
  HomeController controller = HomeController();
  DateTime lastPull = DateTime(1999, 1, 1);

  @override
  Widget build(BuildContext context) {
    controller.initialize();

    return Scaffold(
        appBar: AppBar(title: const Text('Home Page')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() async {
              await controller.fetchData(lastPull);
            });
          },
          child: const Icon(Icons.refresh),
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      await controller.fetchData(lastPull);

                      setState(() {});
                    },
                    child: const Text('Getdata')),
                ElevatedButton(
                    onPressed: () async {
                      await controller.addData();
                      await controller.fetchData(lastPull);

                      setState(() {
                        lastPull = controller.returnCurrentLastPUll();
                      });
                    },
                    child: const Text('Add data')),
                ElevatedButton(
                    onPressed: () async {
                      await controller.insertData();
                      setState(() {
                        lastPull = controller.returnCurrentLastPUll();
                      });
                    },
                    child: const Text('Insert data'))
              ],
            ),
                   SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: controller.returnCurrentLastPUll(),
                
                onDateTimeChanged: (DateTime newDateTime) {
                  controller.overideLastPull(newDateTime);

                  setState(() {
                    lastPull = newDateTime;
                  });

                  // Do something
                },
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: controller.healthDataList.length,
                itemBuilder: (_, index) {
                  HealthDataPoint p = controller.healthDataList[index];

                  return ListTile(
                    title: Text("${p.typeString}: ${p.value}"),
                    trailing: Text(p.unitString),
                    subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
                  );
                })
          ]),
        ));
  }
}
