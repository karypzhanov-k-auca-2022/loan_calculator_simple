import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loan_calculator_simple/features/loan/data/dtos/loan_application_request_dto.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/loan_repository.dart';

class LoanRepositoryImpl implements LoanRepository {
  final SharedPreferences _sharedPreferences;
  final http.Client _client;

  LoanRepositoryImpl({
    required SharedPreferences sharedPreferences,
    required http.Client client,
  }) : _sharedPreferences = sharedPreferences,
       _client = client;

  static const _amountKey = 'loan_amount';
  static const _periodKey = 'loan_period';
  static final Uri _endpoint = Uri.parse(
    'https://jsonplaceholder.typicode.com/posts',
  );

  @override
  Future<LoanSelection?> loadSelection() async {
    final amount = _sharedPreferences.getInt(_amountKey);
    final period = _sharedPreferences.getInt(_periodKey);

    if (amount == null || period == null) {
      return null;
    }

    return LoanSelection(amount: amount, periodDays: period);
  }

  @override
  Future<void> saveSelection({
    required int amount,
    required int periodDays,
  }) async {
    await _sharedPreferences.setInt(_amountKey, amount);
    await _sharedPreferences.setInt(_periodKey, periodDays);
  }

  @override
  Future<void> submitApplication(LoanQuote quote) async {
    final request = LoanApplicationRequestDto.fromDomain(quote);

    final response = await _client
        .post(
          _endpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to submit application');
    }
  }
}
