import 'package:flutter/material.dart';
import 'package:loan_calculator_simple/app/app.dart';
import 'package:loan_calculator_simple/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const LoanCalculatorApp());
}
