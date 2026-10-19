/*
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://localhost:8080';
}
*/
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}