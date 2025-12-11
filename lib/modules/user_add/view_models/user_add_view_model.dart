import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/repository/user_repository.dart';
import '../../../core/services/local_user_service.dart';
import '../../../core/services/remote_user_service.dart';

class UserAddViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserAddViewModel()
      : _userRepository = UserRepositoryImpl(
          localDataSource: LocalUserServiceImpl(),
          remoteDataSource: RemoteUserServiceImpl(),
        );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<User> addUser({String? name, String? email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _userRepository.createUser(
        name: name,
        email: email,
      );
      _error = null;
      return newUser;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}