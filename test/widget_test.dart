import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:stardew_companion/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const StardewCompanionApp());
    expect(find.byType(StardewCompanionApp), findsOneWidget);
  });
}
