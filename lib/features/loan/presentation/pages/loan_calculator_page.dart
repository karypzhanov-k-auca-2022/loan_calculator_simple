import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loan_calculator_simple/features/loan/domain/constants/loan_rules.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_bloc.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_event.dart';
import 'package:loan_calculator_simple/features/loan/presentation/bloc/loan_state.dart';

class LoanCalculatorPage extends StatelessWidget {
  const LoanCalculatorPage({
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

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
                              crossAxisAlignment: .start,
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
  const _LoanControls({required this.state});
  final LoanState state;

  @override
  Widget build(BuildContext context) {
    const periods = LoanRules.availablePeriods;
    final periodIndex = periods.indexOf(state.quote.periodDays);
    final selectedPeriodIndex = periodIndex != -1 ? periodIndex : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(
              'Choose loan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            _ValueRow(label: 'How much?', value: _money(state.quote.amount)),

            Slider.adaptive(
              value: state.quote.amount.toDouble(),
              min: LoanRules.minimumAmount.toDouble(),
              max: LoanRules.maximumAmount.toDouble(),
              divisions:
                  (LoanRules.maximumAmount - LoanRules.minimumAmount) ~/
                  LoanRules.amountStep,
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
              mainAxisAlignment: .spaceBetween,
              children: [Text(r'$5,000'), Text(r'$50,000')],
            ),
            const SizedBox(height: 32),

            _ValueRow(
              label: 'How long?',
              value: '${state.quote.periodDays} days',
            ),

            Slider.adaptive(
              value: selectedPeriodIndex.toDouble(),
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
              mainAxisAlignment: .spaceBetween,
              children: [Text('7 days'), Text('28 days')],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({required this.label, required this.value});
  final String label;
  final String value;

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
  const _LoanSummary({required this.state});
  final LoanState state;

  @override
  Widget build(BuildContext context) {
    final quote = state.quote;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: .stretch,
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
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(fontWeight: .bold),
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
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 16),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
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
