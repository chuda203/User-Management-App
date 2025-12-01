import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../components/user_detail_card.dart';
import '../view_models/user_detail_view_model.dart';
import '../../../core/utils/route_constants.dart';

class UserDetailView extends StatefulWidget {
  const UserDetailView({super.key});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully initialized before calling async operations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserDetail();
    });
  }

  Future<void> _loadUserDetail() async {
    final viewModel = context.read<UserDetailViewModel>();

    final args = ModalRoute.of(context)?.settings.arguments;

    int userId = 0;
    if (args is Map) {
      // Arguments from home/user list are in the form of {'id': id, 'fromHome': bool}
      userId = args['id'] as int;
    } else if (args is int) {
      // If directly passed as integer
      userId = args;
    } else if (args is User) {
      // Fallback for cases where a User object was passed directly
      userId = args.id;
    } else {
      // Type not supported
      return;
    }

    // Load the user detail using the ViewModel
    await viewModel.loadUserDetail(userId);
  }

  Future<void> _editUser() async {
    if (context.read<UserDetailViewModel>().user != null) {
      final result = await Navigator.pushNamed(
        context,
        RouteConstants.userEditRoute,
        arguments: context.read<UserDetailViewModel>().user!,
      );

      if (result != null && context.mounted) {
        User? updatedUser = result as User?;
        if (updatedUser != null) {
          // Update the user in the view model after successful edit
          context.read<UserDetailViewModel>().setUser(updatedUser);
        }
      }
    }
  }

  Future<void> _deleteUser() async {
    if (context.read<UserDetailViewModel>().user != null) {
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete User'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final viewModel = context.read<UserDetailViewModel>();
        final result = await viewModel.deleteUser(context.read<UserDetailViewModel>().user!.id);

        if (result) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting user: ${viewModel.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserDetailViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Clear the ViewModel state when navigating away
            context.read<UserDetailViewModel>().clearState();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: viewModel.isLoading ? null : _editUser,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: viewModel.isLoading ? null : _deleteUser,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (viewModel.error != null || viewModel.user == null) {
              return Center(
                child: Text(
                  viewModel.error ?? 'User not found',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }

            return SingleChildScrollView(
              child: UserDetailCard(user: viewModel.user!),
            );
          },
        ),
      ),
    );
  }
}