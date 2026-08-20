import 'package:injectable/injectable.dart';

import '../entities/loan_quote.dart';

@injectable
final class CalculateLoanQuoteUseCase {
  static const int minimumAmount = 5000;
  static const int maximumAmount = 50000;
  static const int amountStep = 1000;
  static const double interestRate = 0.15;
  static const List<int> availablePeriods = [7, 14, 21, 28];

  LoanQuote call({
    required int amount,
    required int periodDays,
    required DateTime today,
  }) {
    _validateAmount(amount);
    _validatePeriod(periodDays);

    final totalRepayment = (amount * (1 + interestRate)).round();
    final currentDate = DateTime(today.year, today.month, today.day);
    final repaymentDate = currentDate.add(Duration(days: periodDays));

    return LoanQuote(
      amount: amount,
      periodDays: periodDays,
      interestRate: interestRate,
      totalRepayment: totalRepayment,
      repaymentDate: repaymentDate,
    );
  }

  void _validateAmount(int amount) {
    if (amount < minimumAmount || amount > maximumAmount) {
      throw ArgumentError('Amount must be between 5000 and 50000');
    }

    if ((amount - minimumAmount) % amountStep != 0) {
      throw ArgumentError('Amount must have a step of 1000');
    }
  }

  void _validatePeriod(int periodDays) {
    if (!availablePeriods.contains(periodDays)) {
      throw ArgumentError('Period must be 7, 14, 21 or 28 days');
    }
  }
}
