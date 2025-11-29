import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../components/login_form_component.dart';
import '../view_models/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _performLogin() async {
    // Validate the form first - this will trigger the TextFormField validators
    if (_formKey.currentState?.validate() ?? false) {
      // Get the ViewModel before the async call to avoid context issues
      final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

      final response = await loginViewModel.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (response.success && mounted) {
        Navigator.pushReplacementNamed(context, RouteConstants.homeRoute);
      } else {
        // Handle login failure if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 48),
                LoginFormComponent(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onLoginPressed: _performLogin,
                  isLoading: viewModel.isLoading,
                  formKey: _formKey,
                ),
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}