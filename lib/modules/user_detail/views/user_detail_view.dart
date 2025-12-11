import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../components/user_detail_card.dart';
import '../view_models/user_detail_view_model.dart';
import '../../../core/utils/route_constants.dart';

class UserDetailView extends StatelessWidget {
  const UserDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDetailViewModel(),
      child: const _UserDetailViewContent(),
    );
  }
}

class _UserDetailViewContent extends StatefulWidget {
  const _UserDetailViewContent();

  @override
  State<_UserDetailViewContent> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<_UserDetailViewContent> {
  bool _isDeleteInitiated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDetail();
    });
  }

  Future<void> _loadUserDetail() async {
    // Check if widget is still mounted before proceeding
    if (!mounted) return;

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

    // Check if context is still mounted after getting arguments
    if (!mounted) return;

    // Load the user detail using the ViewModel
    await viewModel.loadUserDetail(userId);

    // Check if context is still mounted after async operation
    if (!mounted) return;
  }

  Future<void> _editUser() async {
    final user = context.read<UserDetailViewModel>().user;
    if (user != null) {
      await Navigator.pushNamed(
        context,
        RouteConstants.userEditRoute,
        arguments: user,
      );

      // Refresh the data after coming back from edit
      if (mounted) {
        // Check if context is still valid after async operation
        // Reload the user details to reflect the changes
        await context.read<UserDetailViewModel>().loadUserDetail(user.id);

        // If this user detail was accessed from user list screen,
        // trigger a refresh on the user list screen
        // For now, just reload the current user details
      }
    }
  }

  Future<void> _deleteUser() async {
    final userDetailViewModel = context.read<UserDetailViewModel>();
    final user = userDetailViewModel.user;

    if (user != null) {
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

      if (!mounted) {
        return; // Check if context is still valid after async operation
      }

      if (confirm == true) {
        setState(() {
          _isDeleteInitiated = true;
        });

        final result = await userDetailViewModel.deleteUser(user.id);

        if (!mounted) return; // Check again after another async operation

        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop immediately after successful deletion to avoid showing "User not found"
          Navigator.pop(context);
        } else {
          setState(() {
            _isDeleteInitiated = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting user: ${userDetailViewModel.error}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserDetailViewModel>();

    // If delete was initiated, show a message instead of the content
    if (_isDeleteInitiated) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting user...'),
            ],
          ),
        ),
      );
    }

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
              return const Center(child: CircularProgressIndicator());
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
