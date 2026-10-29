import 'package:flutter_test/flutter_test.dart';
import 'package:iinicia/main.dart';

void main() {
  testWidgets('Inicia app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IniciaApp());

    // Verify that Welcome screen is shown
    expect(find.text('Comenzar'), findsOneWidget);
  });
}
