import 'package:injectable/injectable.dart';

import '../constants/loan_rules.dart';
import '../entities/loan_quote.dart';

@injectable
final class CalculateLoanQuoteUseCase {
  LoanQuote call({
    required int amount,
    required int periodDays,
    required DateTime today,
  }) {
    _validateAmount(amount);
    _validatePeriod(periodDays);

    final totalRepayment = (amount * (1 + LoanRules.interestRate)).round();
    final currentDate = DateTime(today.year, today.month, today.day);
    final repaymentDate = currentDate.add(Duration(days: periodDays));

    return LoanQuote(
      amount: amount,
      periodDays: periodDays,
      interestRate: LoanRules.interestRate,
      totalRepayment: totalRepayment,
      repaymentDate: repaymentDate,
    );
  }

  void _validateAmount(int amount) {
    if (amount < LoanRules.minimumAmount || amount > LoanRules.maximumAmount) {
      throw ArgumentError(
        'Amount must be between '
        '${LoanRules.minimumAmount} and ${LoanRules.maximumAmount}',
      );
    }

    if ((amount - LoanRules.minimumAmount) % LoanRules.amountStep != 0) {
      throw ArgumentError('Amount must have a step of ${LoanRules.amountStep}');
    }
  }

  void _validatePeriod(int periodDays) {
    if (!LoanRules.availablePeriods.contains(periodDays)) {
      throw ArgumentError(
        'Period must be one of: ${LoanRules.availablePeriods.join(', ')} days',
      );
    }
  }
}
