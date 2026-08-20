import 'package:json_annotation/json_annotation.dart';
import 'package:loan_calculator_simple/features/loan/domain/entities/loan_quote.dart';

part 'loan_application_request_dto.g.dart';

@JsonSerializable(createFactory: false)
final class LoanApplicationRequestDto {
  const LoanApplicationRequestDto({
    required this.amount,
    required this.period,
    required this.totalRepayment,
  });

  factory LoanApplicationRequestDto.fromDomain(LoanQuote quote) {
    return LoanApplicationRequestDto(
      amount: quote.amount,
      period: quote.periodDays,
      totalRepayment: quote.totalRepayment,
    );
  }

  final int amount;
  final int period;
  final int totalRepayment;

  Map<String, dynamic> toJson() {
    return _$LoanApplicationRequestDtoToJson(this);
  }
}
