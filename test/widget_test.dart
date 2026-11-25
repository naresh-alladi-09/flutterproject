import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_task_manager/core/services/storage_service.dart';
import 'package:student_task_manager/main.dart';

void main() {
  testWidgets('StudyFlow App launches and displays dashboard', (WidgetTester tester) async {
    // Mock SharedPreferences values
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(StudyFlowApp(storageService: storageService));
    await tester.pumpAndSettle();

    // Verify Dashboard navigation item is present
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Timetable'), findsWidgets);
    expect(find.text('Focus'), findsWidgets);
  });
}

