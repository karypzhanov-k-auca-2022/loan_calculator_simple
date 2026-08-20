import 'package:flutter_test/flutter_test.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_selection.dart';
import 'package:loan_calculator_simple/features/loan/domain/repositories/loan_repository.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_event.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_state.dart';

void main() {
  late FakeLoanRepository repository;
  late LoanBloc bloc;

  setUp(() {
    repository = FakeLoanRepository();
    bloc = LoanBloc(
      repository: repository,
      calculator: CalculateLoanQuoteUseCase(),
    );
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
    final emittedTypes = <LoanState>[];
    final subscription = bloc.stream.listen((state) => emittedTypes.add);

    bloc.add(const LoanSubmitted());
    await bloc.stream.firstWhere((state) => state is LoanSuccess);

    expect(emittedTypes, hasLength(2));
    expect(emittedTypes[0], isA<LoanLoading>());
    expect(emittedTypes[1], isA<LoanSuccess>());

    await subscription.cancel();
  });

  test('emits loading and error when submission fails', () async {
    repository.submitShouldFail = true;
    final emittedTypes = <LoanState>[];
    final subscription = bloc.stream.listen((state) => emittedTypes.add);

    bloc.add(const LoanSubmitted());
    await bloc.stream.firstWhere((state) => state is LoanFailure);

    expect(emittedTypes, hasLength(2));
    expect(emittedTypes[0], isA<LoanLoading>());
    expect(emittedTypes[1], isA<LoanFailure>());

    final failure = emittedTypes.whereType<LoanFailure>().single;
    expect(failure.errorMessage, 'Failed to submit application.');

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
