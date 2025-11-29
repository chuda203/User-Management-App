import 'package:flutter/material.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/custom_button.dart';

class LoginFormComponent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final bool isLoading;
  final GlobalKey<FormState> formKey;

  const LoginFormComponent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.isLoading,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextField(
            label: '',
            hint: 'Email',
            controller: emailController,
            prefixIcon: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email';
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: '',
            hint: 'Password',
            controller: passwordController,
            isPassword: true,
            prefixIcon: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const CircularProgressIndicator()
          else
            CustomButton(
              text: 'Login',
              onPressed: onLoginPressed,
            ),
        ],
      ),
    );
  }
}