import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/styles/theme.dart';
import 'core/utils/constants.dart';
import 'core/utils/route_constants.dart';
import 'core/models/user.dart';
import 'modules/login/views/login_view.dart';
import 'modules/home/views/home_view.dart';
import 'modules/user_list/views/user_list_view.dart';
import 'modules/user_detail/views/user_detail_view.dart';
import 'modules/user_add/views/user_add_view.dart';
import 'modules/user_edit/views/user_edit_view.dart';
import 'modules/splash/views/splash_view.dart';
import 'modules/login/view_models/login_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initialize(); // Initialize environment variables
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: RouteConstants.splashRoute,
      routes: {
        RouteConstants.splashRoute: (context) => const SplashView(),
        RouteConstants.loginRoute: (context) => const LoginView(),
        RouteConstants.homeRoute: (context) => const HomeView(),
        RouteConstants.userListRoute: (context) => const UserListView(),
        RouteConstants.userDetailRoute: (context) => const UserDetailView(),
        RouteConstants.userAddRoute: (context) => const UserAddView(),
        RouteConstants.userEditRoute: (context) => UserEditView(initialUser: ModalRoute.of(context)?.settings.arguments as User),
      },
    );
  }
}