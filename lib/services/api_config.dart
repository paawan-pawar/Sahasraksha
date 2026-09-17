abstract final class ApiConfig {
  static const aiTrailingBaseUrl = String.fromEnvironment(
    'IBVAP_AI_TRAILING_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const sceneSearchBaseUrl = String.fromEnvironment(
    'IBVAP_SCENE_SEARCH_API_URL',
    defaultValue: 'http://127.0.0.1:8001',
  );
}
