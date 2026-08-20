import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loan_calculator_simple/features/loan/domain/repositories/loan_repository.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';

import 'loan_event.dart';
import 'loan_state.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository repository;
  final CalculateLoanQuoteUseCase calculator;

  LoanBloc({required this.repository, required this.calculator})
    : super(
        LoanState(
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
      emit(state.copyWith(quote: quote));
    } catch (_) {
      emit(state.copyWith(status: LoanStatus.error));
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
    emit(
      state.copyWith(quote: quote, status: LoanStatus.idle, clearError: true),
    );

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
    emit(
      state.copyWith(quote: quote, status: LoanStatus.idle, clearError: true),
    );

    await _saveSelection();
  }

  Future<void> _onSubmitted(
    LoanSubmitted event,
    Emitter<LoanState> emit,
  ) async {
    if (state.status == LoanStatus.loading) return;

    try {
      final validateQuote = calculator(
        amount: state.quote.amount,
        periodDays: state.quote.periodDays,
        today: DateTime.now(),
      );

      emit(
        state.copyWith(
          quote: validateQuote,
          status: LoanStatus.loading,
          clearError: true,
        ),
      );

      await _saveSelection();
      await repository.submitApplication(validateQuote);
      emit(state.copyWith(status: LoanStatus.success));
    } catch (_) {
      emit(
        state.copyWith(
          status: LoanStatus.error,
          errorMessage: "Failed to submit application.",
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
