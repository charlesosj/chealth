

import 'package:chealth/src/ui/pages/home/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

var loading = false;
int recordCount = 0;
DateTime lastPull = DateTime(1999, 1, 1);

class _HomePageState extends State<HomePage> {
  HomeController controller = HomeController();

  @override
  Widget build(BuildContext context) {
    controller.initialize();

    return Scaffold(
        appBar: AppBar(title: const Text('Home Page')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() async {
              await controller.fetchData(lastPull);
              lastPull =  await controller.returnCurrentLastPUll();
            });
          },
          child: const Icon(Icons.refresh),
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        await controller.fetchData(lastPull);
                     
                        setState(() {

                          recordCount = controller.healthDataList.length;
                           lastPull = controller.returnCurrentLastPUll();


                        });
                      },
                      child: const Text('Getdata')),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });

                        await controller.addData();
                        await controller.fetchData(lastPull);

                        setState(() {
                          lastPull = controller.returnCurrentLastPUll();
                          loading = false;
                          recordCount = controller.healthDataList.length;
                        });
                      },
                      child: const Text('Add data')),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await controller.insertData();
                        setState(() {
                          lastPull = controller.returnCurrentLastPUll();
                          loading = false;
                        });
                      },
                      child: const Text('Insert data')),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await controller.fetchAndUpsertData();
                        setState(() {
                          loading = false;
                        });
                      },
                      child: const Text('Bulk insert data'))
                ],
              ),
            ),
            Text('Record count $recordCount', textAlign: TextAlign.left),
            Text('Last pull $lastPull', textAlign: TextAlign.left),
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
            loading == false
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.healthDataList.length > 0 ? 5 : 0,
                    itemBuilder: (_, index) {
                      HealthDataPoint p = controller.healthDataList[index];

                      return ListTile(
                        title: Text("${p.typeString}: ${p.value}"),
                        trailing: Text(p.unitString),
                        subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
                      );
                    })
                : const LoadingIndicator(
                    indicatorType: Indicator.ballPulse,

                    /// Required, The loading type of the widget
                    colors: [Colors.white],

                    /// Optional, The color collections
                    strokeWidth: 2,

                    /// Optional, The stroke of the line, only applicable to widget which contains line
                    backgroundColor: Colors.black,

                    /// Optional, Background of the widget
                    pathBackgroundColor: Colors.black

                    /// Optional, the stroke backgroundColor
                    )
          ]),
        ));
  }
}
