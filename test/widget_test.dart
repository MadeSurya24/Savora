import 'package:flutter_test/flutter_test.dart';

import 'package:tubes_savora/main.dart';

void main() {
  testWidgets('Savora app test', (WidgetTester tester) async {

    await tester.pumpWidget(const SavoraApp());

    expect(find.text('Savora 🌿'), findsOneWidget);
  });
}
