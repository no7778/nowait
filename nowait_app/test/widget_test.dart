import 'package:flutter_test/flutter_test.dart';
import 'package:nowait_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NoWaitApp());
    expect(find.text('NOWAIT'), findsWidgets);
  });
}
