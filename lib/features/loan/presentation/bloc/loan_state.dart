import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';

enum LoanStatus { idle, loading, success, error }

class LoanState {
  final LoanQuote quote;
  final LoanStatus status;
  final String? errorMessage;

  const LoanState({
    required this.quote,
    this.status = LoanStatus.idle,
    this.errorMessage,
  });

  LoanState copyWith({
    LoanQuote? quote,
    LoanStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoanState(
      quote: quote ?? this.quote,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
