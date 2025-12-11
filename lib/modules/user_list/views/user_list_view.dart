import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../components/user_list_tile.dart';
import '../view_models/user_list_view_model.dart';

class UserListView extends StatelessWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserListViewModel(),
      child: const _UserListViewContent(),
    );
  }
}

class _UserListViewContent extends StatefulWidget {
  const _UserListViewContent();

  @override
  State<_UserListViewContent> createState() => _UserListViewState();
}

class _UserListViewState extends State<_UserListViewContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize the user list from the service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userListViewModel = context.read<UserListViewModel>();
      userListViewModel.initializeUsers();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Refresh the user list when the app resumes
      if (mounted) {
        final userListViewModel = context.read<UserListViewModel>();
        userListViewModel.refreshUsers();
      }
    }
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
            // Refresh data when navigating away
            final userListViewModel = context.read<UserListViewModel>();
            userListViewModel.refreshUsers();
            Navigator.pop(context);
          },
        ),
        title: const Text('All Users'),
        titleSpacing: 0, // Reduce spacing between leading and title
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, RouteConstants.userAddRoute);

          // Refresh the list to ensure it's up to date after the operation
          if (context.mounted) {
            final userListViewModel = context.read<UserListViewModel>();
            await userListViewModel.refreshUsers();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UserListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.allUsers.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.allUsers.length,
                    itemBuilder: (context, index) {
                      final user = viewModel.allUsers[index];
                      return UserListTile(
                        user: user,
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            RouteConstants.userDetailRoute,
                            arguments: {
                              'id': user.id,
                              'fromHome': false,
                            }, // Mark as NOT coming from home
                          );

                          // Refresh the list after returning from detail view
                          if (context.mounted) {
                            final userListViewModel = context.read<UserListViewModel>();
                            await userListViewModel.refreshUsers();
                          }
                        },
                      );
                    },
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
