import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'user_profile.dart';

class AppStateModel extends ChangeNotifier {
  var _user = UserProfile(10000);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_profile.json');
  }

  Future<String> readUserProfile() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      final newProfile = UserProfile(10000);
      return jsonEncode(newProfile);
    }
  }

  Future<File> writeUserProfile(UserProfile profile) async {
    final json = jsonEncode(profile);
    final file = await _localFile;
    // Write the file
    return file.writeAsString(json);
  }

  void loadProfile() async {
    final jsonString = await readUserProfile();
    _user =
        UserProfile.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

    notifyListeners();
  }

  int get budget {
    return _user.budget;
  }

  void changeBudget(int newBudget) {
    _user.setBudget(newBudget);
    writeUserProfile(_user);
    notifyListeners();
  }
}
