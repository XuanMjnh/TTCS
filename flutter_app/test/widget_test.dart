import 'package:flutter_test/flutter_test.dart';
import 'package:plant_disease_ai/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const PlantDiseaseApp(firebaseReady: false));
    expect(find.text('Firebase chưa sẵn sàng'), findsOneWidget);
  });
}
