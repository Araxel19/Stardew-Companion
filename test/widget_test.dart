import 'package:flutter_test/flutter_test.dart';
import 'package:stardew_companion/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const StardewCompanionApp());
    expect(find.byType(StardewCompanionApp), findsOneWidget);
  });
}
