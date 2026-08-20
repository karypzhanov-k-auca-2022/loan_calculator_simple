import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loan_calculator_simple/app/theme/app_theme.dart';
import 'package:loan_calculator_simple/dependency_injection.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:loan_calculator_simple/features/loan/presentation/pages/loan_calculator_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoanCalculatorApp extends StatefulWidget {
  const LoanCalculatorApp({super.key});

  @override
  State<LoanCalculatorApp> createState() => _LoanCalculatorAppState();
}

class _LoanCalculatorAppState extends State<LoanCalculatorApp> {
  static const String _themeKey = 'is_dark_theme';

  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();

    final savedDarkTheme = getIt<SharedPreferences>().getBool(_themeKey);
    _themeMode = switch (savedDarkTheme) {
      true => .dark,
      false => .light,
      null => .system,
    };
  }

  bool get _isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  Future<void> _toggleTheme() async {
    final nextTheme = _isDarkMode ? ThemeMode.light : ThemeMode.dark;

    setState(() {
      _themeMode = nextTheme;
    });

    await getIt<SharedPreferences>().setBool(
      _themeKey,
      nextTheme == ThemeMode.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoanBloc>(),
      child: MaterialApp(
        title: 'Loan Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: LoanCalculatorPage(
          isDarkMode: _isDarkMode,
          onToggleTheme: _toggleTheme,
        ),
      ),
    );
  }
}
