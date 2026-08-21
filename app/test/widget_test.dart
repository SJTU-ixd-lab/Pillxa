import 'package:flutter_test/flutter_test.dart';
import 'package:pillxa_app/main.dart';

void main() {
  testWidgets('PillxaApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PillxaApp());

    // Verify that the app title is displayed in the AppBar.
    expect(find.text('Pillxa 智能药盒'), findsWidgets);
  });
}

