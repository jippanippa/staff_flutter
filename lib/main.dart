import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:staff_flutter/bloc_base.dart';
import 'package:staff_flutter/blocs.dart';

import 'employees_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сотрудники',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ru', 'RU'),
      ],
      home: BlocProvider<EmployeeBloc>(
        bloc: EmployeeBloc(),
        child: EmployeesRoute(),
      ),
    );
  }
}
