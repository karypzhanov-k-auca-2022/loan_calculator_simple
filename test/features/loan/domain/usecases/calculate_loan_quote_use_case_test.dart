import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';

void main() {
  late CalculateLoanQuoteUseCase calculator;

  setUp(() {
    calculator = CalculateLoanQuoteUseCase();
  });

  test('calculates loan correctly', () {
    final today = DateTime(2026, 8, 15);

    final quote = calculator(amount: 10000, periodDays: 14, today: today);

    expect(quote.amount, equals(10000));
    expect(quote.periodDays, equals(14));
    expect(quote.interestRate, equals(0.15));
    expect(quote.totalRepayment, equals(11500));
    expect(quote.repaymentDate, equals(DateTime(2026, 8, 29))); // after 14 days
  });

  test('throws error when amount is outside allowed range', () {
    expect(
      () => calculator(
        amount: 4000,
        periodDays: 14,
        today: DateTime(2026, 8, 14),
      ),
      throwsArgumentError,
    );
  });

  test('throws error when amount has invalid step', () {
    expect(
      () => calculator(
        amount: 5500,
        periodDays: 14,
        today: DateTime(2026, 8, 14),
      ),
      throwsArgumentError,
    );
  });

  test('throws error when period is unsupported', () {
    expect(
      () => calculator(
        amount: 10000,
        periodDays: 10,
        today: DateTime(2026, 8, 14),
      ),
      throwsArgumentError,
    );
  });
}
