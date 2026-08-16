import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loan_calculator_simple/features/loan/data/repositories/loan_repository_impl.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
  });

  test('saves and restores the latest selection', () async {
    final repository = LoanRepositoryImpl(
      sharedPreferences: preferences,
      client: MockClient((_) async => http.Response('{}', 201)),
    );

    await repository.saveSelection(amount: 24000, periodDays: 21);
    final selection = await repository.loadSelection();

    expect(selection?.amount, 24000);
    expect(selection?.periodDays, 21);
  });

  test('submits the API payload required by the assignment', () async {
    final client = MockClient((request) async {
      expect(
        request.url,
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );
      expect(request.headers['content-type'], 'application/json');
      expect(jsonDecode(request.body), {
        'amount': 10000,
        'period': 14,
        'totalRepayment': 11500,
      });

      return http.Response('{}', 201);
    });
    final repository = LoanRepositoryImpl(
      sharedPreferences: preferences,
      client: client,
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
