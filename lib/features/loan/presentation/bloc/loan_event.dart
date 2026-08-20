sealed class LoanEvent {
  const LoanEvent();
}

final class LoanStarted extends LoanEvent {
  const LoanStarted();
}

final class LoanAmountChanged extends LoanEvent {
  const LoanAmountChanged(this.amount);

  final int amount;
}

final class LoanPeriodChanged extends LoanEvent {
  const LoanPeriodChanged(this.periodDays);

  final int periodDays;
}

final class LoanSubmitted extends LoanEvent {
  const LoanSubmitted();
}
