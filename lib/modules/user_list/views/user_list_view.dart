import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/constants.dart';
import '../components/user_list_tile.dart';
import '../view_models/user_list_view_model.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  @override
  void initState() {
    super.initState();
    // Initialize the user list from the service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userListViewModel = Provider.of<UserListViewModel>(
        context,
        listen: false,
      );
      userListViewModel.initializeUsers();
    });
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
        title: const Text('All Users'),
        titleSpacing: 0, // Reduce spacing between leading and title
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppConstants.userDetailRoute,
                            arguments: {
                              'id': user.id,
                              'fromHome': false,
                            }, // Mark as NOT coming from home
                          );
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
