import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/loan/data/repositories/loan_repository_impl.dart';
import 'features/loan/domain/repositories/loan_repository.dart';
import 'features/loan/presentation/bloc/loan_bloc.dart';
import 'features/loan/presentation/bloc/loan_event.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(preferences);

  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<LoanRepository>(
    () => LoanRepositoryImpl(
      sharedPreferences: getIt<SharedPreferences>(),
      client: getIt<http.Client>(),
    ),
  );

  getIt.registerFactory<CalculateLoanQuoteUseCase>(
    () => CalculateLoanQuoteUseCase(),
  );

  getIt.registerFactory<LoanBloc>(
    () => LoanBloc(
      repository: getIt<LoanRepository>(),
      calculator: getIt<CalculateLoanQuoteUseCase>(),
    )..add(const LoanStarted()),
  );
}
