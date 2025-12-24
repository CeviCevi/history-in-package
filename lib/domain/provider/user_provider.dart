// providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/domain/services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;

  UserModel? _currentUser;
  UserProvider({required UserService userService}) : _userService = userService;

  UserModel? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser?.isSignedIn ?? false;
}
