import 'package:flutter_test/flutter_test.dart';
import 'package:railway_tracker/app.dart';

void main() {
  testWidgets('RailwayTrackerApp smoke test renders Home/Dashboard screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RailwayTrackerApp());
    await tester.pumpAndSettle();

    // Verify that the initial screen (HomeScreen) renders correctly.
    expect(find.text('Home/Dashboard'), findsOneWidget);
  });
}
