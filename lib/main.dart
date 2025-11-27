import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/styles/theme.dart';
import 'core/utils/constants.dart';
import 'modules/login/views/login_view.dart';
import 'modules/home/views/home_view.dart';
import 'modules/user_list/views/user_list_view.dart';
import 'modules/user_detail/views/user_detail_view.dart';
import 'modules/login/view_models/login_view_model.dart';
import 'modules/home/view_models/home_view_model.dart';
import 'modules/user_list/view_models/user_list_view_model.dart';
import 'modules/user_detail/view_models/user_detail_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => UserListViewModel()),
        ChangeNotifierProvider(create: (_) => UserDetailViewModel()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppConstants.loginRoute,
        routes: {
          AppConstants.loginRoute: (context) => const LoginView(),
          AppConstants.homeRoute: (context) => const HomeView(),
          AppConstants.userListRoute: (context) => const UserListView(),
          AppConstants.userDetailRoute: (context) => const UserDetailView(),
        },
      ),
    );
  }
}