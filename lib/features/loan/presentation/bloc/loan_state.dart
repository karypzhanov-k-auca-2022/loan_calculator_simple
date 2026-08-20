import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';

sealed class LoanState {
  const LoanState({required this.quote});

  final LoanQuote quote;
}

final class LoanIdle extends LoanState {
  const LoanIdle({required super.quote});
}

final class LoanLoading extends LoanState {
  const LoanLoading({required super.quote});
}

final class LoanSuccess extends LoanState {
  const LoanSuccess({required super.quote});
}

final class LoanFailure extends LoanState {
  const LoanFailure({required super.quote, required this.errorMessage});

  final String errorMessage;
}
