import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user.dart';
import '../components/user_detail_card.dart';
import '../view_models/user_detail_view_model.dart';

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