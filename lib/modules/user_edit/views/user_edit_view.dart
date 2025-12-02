import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../view_models/user_edit_view_model.dart';

class UserEditView extends StatefulWidget {
  final User initialUser;

  const UserEditView({super.key, required this.initialUser});

  @override
  State<UserEditView> createState() => _UserEditViewState();
}

class _UserEditViewState extends State<UserEditView> {
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
                    Provider.of<UserEditViewModel>(context, listen: false);
                
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
                  
                  // Pop with the updated user data
                  Navigator.pop(context, User(
                    id: widget.initialUser.id,
                    name: _nameController.text,
                    username: _nameController.text.toLowerCase(),
                    email: _emailController.text,
                    avatar: widget.initialUser.avatar,
                  ));
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