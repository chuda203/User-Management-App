import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../view_models/splash_view_model.dart';
import '../components/splash_component.dart';

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

    // Check authentication status using SplashViewModel
    final splashViewModel = context.read<SplashViewModel>();
    final hasValidToken = await splashViewModel.checkAuthentication();

    // Ensure context is still valid before navigation
    if (!mounted) return;

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