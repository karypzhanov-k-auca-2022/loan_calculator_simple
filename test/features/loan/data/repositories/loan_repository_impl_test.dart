import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator_simple/config/api_config.dart';
import 'package:loan_calculator_simple/features/loan/data/repositories/loan_repository_impl.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  const apiConfig = ApiConfig(
    baseUrl: 'https://api.example.test',
    loanApplicationPath: '/loan-applications',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('saves and restores the latest selection', () async {
    final repository = LoanRepositoryImpl(
      sharedPreferences: preferences,
      dio: Dio(),
      apiConfig: apiConfig,
    );

    await repository.saveSelection(amount: 24000, periodDays: 21);

    final selection = await repository.loadSelection();

    expect(selection?.amount, 24000);
    expect(selection?.periodDays, 21);
  });

  test('submits the API payload required by the assignment', () async {
    final dio = Dio(BaseOptions(baseUrl: apiConfig.baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(
            options.uri.toString(),
            'https://api.example.test/loan-applications',
          );

          expect(options.data, {
            'amount': 10000,
            'period': 14,
            'totalRepayment': 11500,
          });

          handler.resolve(
            Response<void>(requestOptions: options, statusCode: 201),
          );
        },
      ),
    );

    final repository = LoanRepositoryImpl(
      sharedPreferences: preferences,
      dio: dio,
      apiConfig: apiConfig,
    );

    await repository.submitApplication(
      LoanQuote(
        amount: 10000,
        periodDays: 14,
        interestRate: 0.15,
        totalRepayment: 11500,
        repaymentDate: DateTime(2026, 8, 30),
      ),
    );
  });
}
