import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../view_models/user_edit_view_model.dart';

class UserEditView extends StatelessWidget {
  final User initialUser;

  const UserEditView({super.key, required this.initialUser});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserEditViewModel(),
      child: _UserEditViewContent(initialUser: initialUser),
    );
  }
}

class _UserEditViewContent extends StatefulWidget {
  final User initialUser;

  const _UserEditViewContent({required this.initialUser});

  @override
  State<_UserEditViewContent> createState() => _UserEditViewState();
}

class _UserEditViewState extends State<_UserEditViewContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialUser.name);
    _emailController = TextEditingController(text: widget.initialUser.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Edit User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final userEditViewModel =
                    context.read<UserEditViewModel>();

                try {
                  await userEditViewModel.updateUser(
                    widget.initialUser.id,
                    name: _nameController.text,
                    email: _emailController.text,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Pop the edit screen and let the parent screen handle refresh
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit User Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}