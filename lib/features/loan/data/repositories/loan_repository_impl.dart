import 'package:dio/dio.dart';
import 'package:loan_calculator_simple/features/loan/data/dtos/loan_application_request_dto.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/loan_repository.dart';

final class LoanRepositoryImpl implements LoanRepository {
  final SharedPreferences _sharedPreferences;
  final Dio _dio;

  LoanRepositoryImpl({
    required SharedPreferences sharedPreferences,
    required Dio dio,
  }) : _sharedPreferences = sharedPreferences,
       _dio = dio;

  static const _amountKey = 'loan_amount';
  static const _periodKey = 'loan_period';
  static const _endpoint = 'https://jsonplaceholder.typicode.com/posts';

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

    await _dio.post<void>(_endpoint, data: request.toJson());
  }
}
