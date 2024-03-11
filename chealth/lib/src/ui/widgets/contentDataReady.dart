import 'package:flutter/material.dart';
import 'package:health/health.dart';


class contentDataReady extends StatelessWidget {
  final List<HealthDataPoint> _healthDataList;
  contentDataReady(this._healthDataList);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _healthDataList.length,
        itemBuilder: (_, index) {
          HealthDataPoint p = _healthDataList[index];

          return ListTile(
            title: Text("${p.typeString}: ${p.value}"),
            trailing: Text(p.unitString),
            subtitle: Text('${p.dateFrom} - ${p.dateTo}'),
          );
        });
  }
}


