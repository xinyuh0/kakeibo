import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kkb/model/budget.dart';
import 'package:kkb/model/category.dart';
import 'package:kkb/widgets/budget_status.dart';
import 'package:kkb/widgets/category_budget_list_item.dart';
import 'package:kkb/widgets/category_picker.dart';
import 'package:kkb/widgets/date_picker.dart';
import 'package:kkb/widgets/dialog_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:kkb/widgets/popup_dialog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
/*  group('RecordListItem Tests', () {
    for (var category in CategoryController.getCategories()) {
      testWidgets('List item displays correctly for ${category.name} category', (WidgetTester tester) async {

        final testRecord = SpendingRecord(
          id: 1,
          name: 'Test Item for ${category.name}',
          amount: 1000,
          category: category,
          date: DateTime.now(),
        );

        await tester.pumpWidget(MaterialApp(home: RecordListItem(record: testRecord)));

        expect(find.byIcon(testRecord.iconData), findsOneWidget);

        expect(find.text('¥${testRecord.amountStr}'), findsOneWidget);

        expect(find.text(testRecord.name), findsOneWidget);
      });
    }

    testWidgets('Tapping on the list item shows correct modal dialog info', (WidgetTester tester) async {

      final testCategory = CategoryController.getCategory(1);  // Example food.

      final testRecord = SpendingRecord(
        id: 1,
        name: 'Test Item',
        amount: 1000, 
        category: testCategory,
        date: DateTime.now(),
      );
      await tester.pumpWidget(MaterialApp(home: RecordListItem(record: testRecord)));

      await tester.tap(find.byType(RecordListItem));
      await tester.pumpAndSettle();

      expect(find.text('Record Info'), findsOneWidget);

    });


  });

    group('HomePageListItem Tests', () {

    testWidgets('List item displays the correct icon, title, and subtitle', (WidgetTester tester) async {
      final testCategory = CategoryController.getCategory(1);
      final testRecord = SpendingRecord(
        id: 1,
        name: 'Test Item',
        amount: 1000,
        category: testCategory,
        date: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(home: HomePageListItem(record: testRecord)));

      expect(find.byIcon(testRecord.iconData), findsOneWidget);

      expect(find.text('¥${testRecord.amountStr}'), findsOneWidget);

      expect(find.text('${testRecord.name}, ${testRecord.dateStr('yyyy-MM-dd')}'), findsOneWidget);
    });

    testWidgets('Tapping on the list item shows correct modal dialog info', (WidgetTester tester) async {
      final testCategory = CategoryController.getCategory(1); 
      final testRecord = SpendingRecord(
        id: 1,
        name: 'Test Item',
        amount: 1000,
        category: testCategory,
        date: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(home: HomePageListItem(record: testRecord)));

      await tester.tap(find.byType(HomePageListItem));
      await tester.pumpAndSettle();

      expect(find.text('Record Info'), findsOneWidget);
    });
  });

  group('BudgetStatus Tests', () {
    testWidgets('Budget and usage are displayed correctly', (WidgetTester tester) async {

      const budget = 1000;
      const total = 500;
      final budgetStatus = BudgetStatus(budget: budget, total: total);

      await tester.pumpWidget(MaterialApp(home: budgetStatus));

      expect(find.text('$budget'), findsOneWidget);

      expect(find.text('$total'), findsOneWidget);

      final percent = (total / budget).clamp(0.0, 1.0);
      final displayedPercent = percent == 0.0 ? '0' : percent >= 0.01 ? '${(percent * 100).toInt()}' : '<1';
      expect(find.text('$displayedPercent%'), findsOneWidget);
    });
  });
*/

  group('DialogAction Tests', () {
    testWidgets('DialogAction displays the correct text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: DialogAction(
            text: 'Test Action',
            onPressed: () {},
          ),
        ),
      );

      expect(find.text('Test Action'), findsOneWidget);
    });

    testWidgets('DialogAction responds to tap', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: DialogAction(
            text: 'Test Action',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(DialogAction));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('DialogAction styles for isDefault and isDestructive',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: DialogAction(
            text: 'Default Action',
            isDefault: true,
            onPressed: () {},
          ),
        ),
      );

      await tester.pumpWidget(
        CupertinoApp(
          home: DialogAction(
            text: 'Destructive Action',
            isDestructive: true,
            onPressed: () {},
          ),
        ),
      );
    });
  });

  group('PopupDialog Tests', () {
    testWidgets('PopupDialog displays title and content correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: PopupDialog(
            title: const Text('Test Title'),
            content: const Text('Test Content'),
            actions: [DialogAction(text: 'OK', onPressed: () {})],
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('PopupDialog actions work correctly',
        (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: PopupDialog(
            title: const Text('Test Title'),
            content: const Text('Test Content'),
            actions: [
              DialogAction(
                text: 'Tap Me',
                onPressed: () {
                  tapped = true;
                },
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('PopupDialog layout and UI are as expected',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: PopupDialog(
            title: const Text('Test Title'),
            content: const Text('Test Content'),
            actions: [
              DialogAction(
                  text: 'OK',
                  onPressed: () {
                    tapped = true;
                  })
            ],
          ),
        ),
      );
      expect(tapped, isTrue);
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });
  });

  testWidgets('category_picker are as expected', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CategoryPicker(
          controller: FixedExtentScrollController(),
          onChanged: (val) {},
        ),
      ),
    );
    expect(tapped, isTrue);
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Clothing'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);
    expect(find.text('Fitness'), findsOneWidget);
    expect(find.text('Housing'), findsOneWidget);
  });

  testWidgets('DatePicker are as expected', (WidgetTester tester) async {
    var changed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: DatePicker(
          initialDate: DateTime.now(),
          onChanged: (val) {
            changed = true;
          },
        ),
      ),
    );
    expect(changed, isTrue);
  });

  testWidgets('CategoryBudgetItem are as expected',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CategoryBudgetItem(
          data: Progress(
              category: Category(
                  index: 1,
                  name: "helloo",
                  color: Color(0xffffffff),
                  iconData: Icons.abc),
              budget: 111,
              total: 2),
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );
    expect(tapped, isTrue);
  });

  testWidgets('CategoryBudgetItem are as expected',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: DialogAction(
          text: "hello world",
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );
    expect(tapped, isTrue);
    expect(find.text('hello world'), findsOneWidget);
  });
}
