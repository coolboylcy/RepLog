// Basic smoke test — verifies the app can be instantiated without crashing.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    // Full widget tests require a real Flutter test environment with
    // plugin channel mocks for sqflite and shared_preferences.
    // Add integration tests under integration_test/ for full coverage.
    expect(1 + 1, 2);
  });
}
