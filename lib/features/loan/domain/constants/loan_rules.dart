abstract final class LoanRules {
  static const int minimumAmount = 5000;
  static const int maximumAmount = 50000;
  static const int amountStep = 1000;
  static const double interestRate = 0.15;
  static const List<int> availablePeriods = [7, 14, 21, 28];
}
