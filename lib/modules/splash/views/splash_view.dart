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
  late SplashViewModel _splashViewModel;

  @override
  void initState() {
    super.initState();
    _splashViewModel = SplashViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashSequence();
    });
  }

  Future<void> _startSplashSequence() async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

    // Simulate loading time for splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if widget is still mounted after delay
    if (!mounted) return;

    // Check authentication status using the stored viewModel
    final hasValidToken = await _splashViewModel.checkAuthentication();

    // Ensure context is still valid before navigation
    if (!mounted) return;

    // Navigate based on authentication status
    if (hasValidToken) {
      // User is authenticated, go to home screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteConstants.homeRoute);
      }
    } else {
      // User is not authenticated, go to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteConstants.loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _splashViewModel,
      child: const SplashComponent(),
    );
  }
}