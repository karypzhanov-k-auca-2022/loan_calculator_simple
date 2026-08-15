abstract class LoanEvent {
  const LoanEvent();
}

class LoanStarted extends LoanEvent {
  const LoanStarted();
}

class LoanAmountChanged extends LoanEvent {
  final int amount;

  const LoanAmountChanged(this.amount);
}

class LoanPeriodChanged extends LoanEvent {
  final int periodDays;

  const LoanPeriodChanged(this.periodDays);
}

class LoanSubmitted extends LoanEvent {
  const LoanSubmitted();
}
