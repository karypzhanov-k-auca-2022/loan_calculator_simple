import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:loan_calculator_simple/features/loan/domain/repositories/loan_repository.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';

import 'loan_event.dart';
import 'loan_state.dart';

@injectable
final class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository repository;
  final CalculateLoanQuoteUseCase calculator;

  LoanBloc({required this.repository, required this.calculator})
    : super(
        LoanIdle(
          quote: calculator(
            amount: 10000,
            periodDays: 14,
            today: DateTime.now(),
          ),
        ),
      ) {
    on<LoanStarted>(_onStarted);
    on<LoanAmountChanged>(_onAmountChanged);
    on<LoanPeriodChanged>(_onPeriodChanged);
    on<LoanSubmitted>(_onSubmitted);
  }

  Future<void> _onStarted(LoanStarted event, Emitter<LoanState> emit) async {
    try {
      final selection = await repository.loadSelection();

      if (selection == null) return;

      final quote = calculator(
        amount: selection.amount,
        periodDays: selection.periodDays,
        today: DateTime.now(),
      );
      emit(LoanIdle(quote: quote));
    } catch (error, stackTrace) {
      debugPrint('Failed to restore previous selection: $error\n$stackTrace');

      emit(
        LoanFailure(
          quote: state.quote,
          errorMessage: 'Failed to restore previous selection.',
        ),
      );
    }
  }

  Future<void> _onAmountChanged(
    LoanAmountChanged event,
    Emitter<LoanState> emit,
  ) async {
    final quote = calculator(
      amount: event.amount,
      periodDays: state.quote.periodDays,
      today: DateTime.now(),
    );
    emit(LoanIdle(quote: quote));

    await _saveSelection();
  }

  Future<void> _onPeriodChanged(
    LoanPeriodChanged event,
    Emitter<LoanState> emit,
  ) async {
    final quote = calculator(
      amount: state.quote.amount,
      periodDays: event.periodDays,
      today: DateTime.now(),
    );
    emit(LoanIdle(quote: quote));

    await _saveSelection();
  }

  Future<void> _onSubmitted(
    LoanSubmitted event,
    Emitter<LoanState> emit,
  ) async {
    if (state is LoanLoading) return;

    try {
      final validateQuote = calculator(
        amount: state.quote.amount,
        periodDays: state.quote.periodDays,
        today: DateTime.now(),
      );

      emit(LoanLoading(quote: validateQuote));

      await _saveSelection();
      await repository.submitApplication(validateQuote);
      emit(LoanSuccess(quote: validateQuote));
    } catch (error, stackTrace) {
      debugPrint('Failed to submit application: $error\n$stackTrace');

      emit(
        LoanFailure(
          quote: state.quote,
          errorMessage: 'Failed to submit application.',
        ),
      );
    }
  }

  Future<void> _saveSelection() async {
    try {
      await repository.saveSelection(
        amount: state.quote.amount,
        periodDays: state.quote.periodDays,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('Failed to save selection: $error\n$stackTrace');
    }
  }
}
