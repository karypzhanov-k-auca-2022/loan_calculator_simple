class LoanQuote {
  final int amount;
  final int periodDays;
  final double interestRate;
  final int totalRepayment;
  final DateTime repaymentDate;

  const LoanQuote({
    required this.amount,
    required this.periodDays,
    required this.interestRate,
    required this.totalRepayment,
    required this.repaymentDate,
  });
}
