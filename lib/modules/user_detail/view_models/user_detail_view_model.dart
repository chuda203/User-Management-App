import 'package:flutter/material.dart';
import '../../../core/models/user.dart';

class UserDetailViewModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}