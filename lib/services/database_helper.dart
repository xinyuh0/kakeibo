import 'package:flutter/cupertino.dart';
import 'package:kkb/model/spending_record.dart';
import 'package:kkb/model/budget.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/category_controller.dart';

class DatabaseHelper {
  static Future<Database> get database async {
    WidgetsFlutterBinding.ensureInitialized();
    return await openDatabase(
      join(await getDatabasesPath(), 'records.db'),
      version: 1,
      onCreate: _onCreate,
    );
  }

  static deleteDB() async {
    final dbPath = join(await getDatabasesPath(), 'records.db');
    final db = await database;
    await db.close();
    await deleteDatabase(dbPath);
  }

  static _onCreate(Database db, int version) async {
    // Create records table
    await db.execute(
      '''CREATE TABLE records(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            name TEXT,
            amount INTEGER,
            category INTEGER,
            date INTEGER,
            store TEXT,
            payment_method TEXT,
            notes TEXT,
            location TEXT
          )''',
    );

    // Create budget table
    // For each month, a category either non-exist or exist once
    await db.execute(
      '''CREATE TABLE budget(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            amount INTEGER NOT NULL,
            category INTEGER NOT NULL,
            year INTEGER NOT NULL,
            month INTEGER NOT NULL,
            UNIQUE (category, year, month))''',
    );
  }

  static Future<int> insertRecord(
      String name,
      int amount,
      int categoryIndex,
      DateTime date,
      String store,
      String paymentMethod,
      String notes,
      String location) async {
    final db = await database;
    final data = {
      'name': name,
      'amount': amount,
      'category': categoryIndex,
      'date': date.millisecondsSinceEpoch,
      'store': store,
      'payment_method': paymentMethod,
      'notes': notes,
      'location': location,
    };
    final newRecordId = await db.insert(
      'records',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return newRecordId;
  }

  static Future<void> deleteRecord(int id) async {
    final db = await database;
    await db.delete(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateRecord(SpendingRecord record) async {
    final db = await database;
    await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<List<SpendingRecord>> getRecords() async {
    try {
      final db = await database;
      final maps = await db.query('records'); // orderBy ?
      return List.generate(maps.length, (i) {
        return SpendingRecord(
          id: maps[i]['id'] as int,
          name: maps[i]['name'] as String,
          amount: maps[i]['amount'] as int,
          category: CategoryController.getCategory(maps[i]['category'] as int),
          date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date'] as int),
          store: maps[i]['store'] as String,
          paymentMethod: maps[i]['payment_method'] as String,
          notes: maps[i]['notes'] as String,
          location: maps[i]['location'] as String,
        );
      });
    } catch (e) {
      // TODO: Add logger for error msg
      return <SpendingRecord>[];
    }
  }

  static Future<void> clearAllRecords() async {
    final db = await database;
    try {
      // Delete all the rows in 'records' table
      await db.delete('records');
      // Reset incremental id
      await db.execute('DELETE FROM sqlite_sequence WHERE name=?', ['records']);
    } catch (e) {}
  }

  static Future<List<Budget>> getBudgetByMonth(int year, int month) async {
    try {
      final db = await database;
      final maps = await db.query(
        'budget',
        where: 'year = ? AND month = ?',
        whereArgs: [year, month],
      );

      return List.generate(
        maps.length,
        (i) => Budget(
          id: maps[i]['id'] as int,
          amount: maps[i]['amount'] as int,
          category: CategoryController.getCategory(maps[i]['category'] as int),
          year: maps[i]['year'] as int,
          month: maps[i]['month'] as int,
        ),
      );
    } catch (e) {
      // TODO: Add logger for error msg
      return <Budget>[];
    }
  }

  static Future<int> insertBudget(
      int amount, int categoryIndex, int year, int month) async {
    final db = await database;
    final data = {
      'amount': amount,
      'category': categoryIndex,
      'year': year,
      'month': month,
    };

    List<Budget> budgetInfo = await getBudgetByMonth(year, month);

    int allCategoryIndex = CategoryController.getCategoryCount() - 1;

    // 1. empty budgetInfo - All
    // 2. empty budgetInfo - non-All, insert 2 row
    // 3. non-empty - All, (check if larger than lower bound, currently check in frontend)
    // 4. non-empty - non-All, (check if update of total budget is needed)

    // case 1 & 3
    if (categoryIndex == allCategoryIndex) {
      final int newId = await db.insert(
        'budget',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return newId;
    }

    // case 2
    if (budgetInfo.isEmpty && categoryIndex != allCategoryIndex) {
      final int newId = await db.insert(
        'budget',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await db.insert(
        'budget',
        {
          'amount': amount,
          'category': allCategoryIndex,
          'year': year,
          'month': month,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return newId;
    }

    // case 4
    // Compute the lower bound.
    int lowerBound = budgetInfo
        .where((element) =>
            element.category.index != allCategoryIndex &&
            element.category.index != categoryIndex)
        .fold(0, (previousValue, element) => previousValue + element.amount);

    lowerBound += amount;

    int currTotalBudget =
        budgetInfo.firstWhere((element) => element.category.index == allCategoryIndex).amount;

    final int newId = await db.insert(
      'budget',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Sum of all the category budgets larger than the original total budget.
    // We need to update the total budget as well.
    if (currTotalBudget < lowerBound) {
      await db.insert(
        'budget',
        {
          'amount': lowerBound,
          'category': allCategoryIndex,
          'year': year,
          'month': month,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    return newId;
  }
}
