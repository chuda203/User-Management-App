import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../view_models/splash_view_model.dart';
import '../components/splash_component.dart';
import '../../login/view_models/login_view_model.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate loading time for splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if user has valid token
    LoginViewModel loginViewModel = context.read<LoginViewModel>();
    bool hasValidToken = await loginViewModel.hasValidToken();

    // Navigate based on authentication status
    if (hasValidToken) {
      // User is authenticated, go to home screen
      Navigator.of(context).pushReplacementNamed(RouteConstants.homeRoute);
    } else {
      // User is not authenticated, go to login screen
      Navigator.of(context).pushReplacementNamed(RouteConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: const SplashComponent(),
    );
  }
}