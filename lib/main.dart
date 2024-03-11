import 'package:flutter/cupertino.dart';
import 'package:kkb/app.dart';
import 'package:provider/provider.dart';

import 'model/app_state_model.dart';

void main() {
  return runApp(ChangeNotifierProvider<AppStateModel>(
    create: (_) => AppStateModel()..loadProfile(),
    child: const App(),
  ));
}