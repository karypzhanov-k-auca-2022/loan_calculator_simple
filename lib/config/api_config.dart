final class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.loanApplicationPath,
  });

  factory ApiConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment('API_BASE_URL');
    const loanApplicationPath = String.fromEnvironment(
      'LOAN_APPLICATION_PATH',
    );

    if (baseUrl.isEmpty) {
      throw StateError('API_BASE_URL is not configured');
    }

    if (loanApplicationPath.isEmpty) {
      throw StateError('LOAN_APPLICATION_PATH is not configured');
    }

    return const ApiConfig(
      baseUrl: baseUrl,
      loanApplicationPath: loanApplicationPath,
    );
  }

  final String baseUrl;
  final String loanApplicationPath;
}
