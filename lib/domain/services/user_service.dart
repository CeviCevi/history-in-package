import 'package:pytl_backup/data/models/user_model/user_model.dart';
import 'package:pytl_backup/domain/repository/user_repository.dart';

class UserService {
  final UserRepository _service = UserRepository();

  Future<UserModel?> login(String email, String password) async {
    final data = await _service.getUserByEmail(email);

    if (data?.password == password) {
      return data!;
    } else {
      return null;
    }
  }

  Future<UserModel?> register(
    String login,
    String email,
    String password,
  ) async {
    final data = await _service.getUserByEmail(email);

    if (data != null) {
      return null;
    } else {
      return _service.addUser(login, email, password);
    }
  }
}
