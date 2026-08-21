import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_selection.dart';

abstract interface class LoanRepository {
  Future<LoanSelection?> loadSelection();

  Future<void> saveSelection({required int amount, required int periodDays});

  Future<void> submitApplication(LoanQuote quote);
}
