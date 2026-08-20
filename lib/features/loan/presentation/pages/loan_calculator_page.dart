import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loan_calculator_simple/features/loan/domain/usecases/calculate_loan_quote_use_case.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_event.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_state.dart';

import '../bloc/loan_bloc.dart';

class LoanCalculatorPage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoanCalculatorPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanBloc, LoanState>(
      listener: (context, state) {
        switch (state) {
          case LoanSuccess():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application submitted successfully'),
              ),
            );

          case LoanFailure(:final errorMessage):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));

          case LoanIdle() || LoanLoading():
            break;
        }
      },

      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Loan Calculator'),
            actions: [
              IconButton(
                tooltip: isDarkMode
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                onPressed: onToggleTheme,
                icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _LoanControls(state: state)),
                                const SizedBox(width: 24),
                                Expanded(child: _LoanSummary(state: state)),
                              ],
                            )
                          : Column(
                              children: [
                                _LoanControls(state: state),
                                const SizedBox(height: 24),
                                _LoanSummary(state: state),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _LoanControls extends StatelessWidget {
  final LoanState state;

  const _LoanControls({required this.state});

  @override
  Widget build(BuildContext context) {
    final periods = CalculateLoanQuoteUseCase.availablePeriods;
    final periodIndex = periods.indexOf(state.quote.periodDays);
    final selectedPeriodIndex = periodIndex != -1 ? periodIndex : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose loan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            _ValueRow(label: 'How much?', value: _money(state.quote.amount)),

            Slider.adaptive(
              value: state.quote.amount.toDouble(),
              min: CalculateLoanQuoteUseCase.minimumAmount.toDouble(),
              max: CalculateLoanQuoteUseCase.maximumAmount.toDouble(),
              divisions:
                  (CalculateLoanQuoteUseCase.maximumAmount -
                      CalculateLoanQuoteUseCase.minimumAmount) ~/
                  CalculateLoanQuoteUseCase.amountStep,
              label: _money(state.quote.amount),
              onChanged: state is LoanLoading
                  ? null
                  : (value) {
                      context.read<LoanBloc>().add(
                        LoanAmountChanged(value.round()),
                      );
                    },
            ),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(r'$5,000'), Text(r'$50,000')],
            ),
            const SizedBox(height: 32),

            _ValueRow(
              label: 'How long?',
              value: '${state.quote.periodDays} days',
            ),

            Slider.adaptive(
              value: selectedPeriodIndex.toDouble(),
              min: 0,
              max: (periods.length - 1).toDouble(),
              divisions: periods.length - 1,
              activeColor: Colors.orange,
              inactiveColor: Colors.orange.shade100,
              thumbColor: Colors.deepOrange,
              overlayColor: WidgetStatePropertyAll(
                Colors.orange.withValues(alpha: 0.18),
              ),

              onChanged: state is LoanLoading
                  ? null
                  : (value) {
                      final period = periods[value.round()];

                      context.read<LoanBloc>().add(LoanPeriodChanged(period));
                    },
            ),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('7 days'), Text('28 days')],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _ValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _LoanSummary extends StatelessWidget {
  final LoanState state;

  const _LoanSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final quote = state.quote;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your quote', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 24),
            const Text('Total repayment'),
            const SizedBox(height: 4),
            TweenAnimationBuilder<double>(
              tween: Tween(end: quote.totalRepayment.toDouble()),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Text(
                  _money(value.round()),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            _SummaryRow(label: 'You receive', value: _money(quote.amount)),
            const SizedBox(height: 16),

            _SummaryRow(
              label: 'Interest rate',
              value: '${(quote.interestRate * 100).round()}%',
            ),
            const SizedBox(height: 16),

            _SummaryRow(
              label: 'Repayment date',
              value: DateFormat('MMM d, yyyy').format(quote.repaymentDate),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: state is LoanLoading
                  ? null
                  : () {
                      context.read<LoanBloc>().add(const LoanSubmitted());
                    },
              child: state is LoanLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Text('Submit application'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

String _money(int value) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  ).format(value);
}
