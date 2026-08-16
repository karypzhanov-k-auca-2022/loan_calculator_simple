import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_selection.dart';
import 'package:loan_calculator_simple/features/loan/domain/repositories/loan_repository.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_event.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_state.dart';

void main() {
  late FakeLoanRepository repository;
  late LoanBloc bloc;

  setUp(() {
    repository = FakeLoanRepository();
    bloc = LoanBloc(repository: repository, calculator: CalculateLoanQuote());
  });

  tearDown(() => bloc.close());

  test('changes amount, recalculates quote and saves selection', () async {
    bloc.add(const LoanAmountChanged(20000));

    final state = await bloc.stream.firstWhere(
      (state) => state.quote.amount == 20000,
    );

    expect(state.quote.totalRepayment, 23000);
    expect(repository.savedAmount, 20000);
    expect(repository.savedPeriod, 14);
  });

  test('emits loading and success when submission succeeds', () async {
    final statuses = <LoanStatus>[];
    final subscription = bloc.stream.listen(
      (state) => statuses.add(state.status),
    );

    bloc.add(const LoanSubmitted());
    await bloc.stream.firstWhere((state) => state.status == LoanStatus.success);

    expect(statuses, [LoanStatus.loading, LoanStatus.success]);
    expect(repository.submittedQuote?.amount, 10000);

    await subscription.cancel();
  });

  test('emits loading and error when submission fails', () async {
    repository.submitShouldFail = true;
    final statuses = <LoanStatus>[];
    final subscription = bloc.stream.listen(
      (state) => statuses.add(state.status),
    );

    bloc.add(const LoanSubmitted());
    await bloc.stream.firstWhere((state) => state.status == LoanStatus.error);

    expect(statuses, [LoanStatus.loading, LoanStatus.error]);
    expect(bloc.state.errorMessage, 'Failed to submit application.');

    await subscription.cancel();
  });
}

class FakeLoanRepository implements LoanRepository {
  LoanSelection? cachedSelection;
  int? savedAmount;
  int? savedPeriod;
  LoanQuote? submittedQuote;
  bool submitShouldFail = false;

  @override
  Future<LoanSelection?> loadSelection() async => cachedSelection;

  @override
  Future<void> saveSelection({
    required int amount,
    required int periodDays,
  }) async {
    savedAmount = amount;
    savedPeriod = periodDays;
  }

  @override
  Future<void> submitApplication(LoanQuote quote) async {
    if (submitShouldFail) {
      throw Exception('Network error');
    }

    submittedQuote = quote;
  }
}
