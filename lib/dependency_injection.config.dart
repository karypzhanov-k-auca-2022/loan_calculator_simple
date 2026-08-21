// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:loan_calculator_simple/config/api_config.dart' as _i882;
import 'package:loan_calculator_simple/di/app_module.dart' as _i788;
import 'package:loan_calculator_simple/features/loan/data/repositories/loan_repository_impl.dart'
    as _i984;
import 'package:loan_calculator_simple/features/loan/domain/repositories/loan_repository.dart'
    as _i98;
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart'
    as _i943;
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_bloc.dart'
    as _i1042;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true,
    );
    gh.factory<_i943.CalculateLoanQuoteUseCase>(
      () => _i943.CalculateLoanQuoteUseCase(),
    );
    gh.lazySingleton<_i882.ApiConfig>(() => appModule.apiConfig);
    gh.lazySingleton<_i361.Dio>(() => appModule.dio(gh<_i882.ApiConfig>()));
    gh.lazySingleton<_i98.LoanRepository>(
      () => _i984.LoanRepositoryImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        dio: gh<_i361.Dio>(),
        apiConfig: gh<_i882.ApiConfig>(),
      ),
    );
    gh.factory<_i1042.LoanBloc>(
      () => _i1042.LoanBloc(
        repository: gh<_i98.LoanRepository>(),
        calculator: gh<_i943.CalculateLoanQuoteUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i788.AppModule {}
