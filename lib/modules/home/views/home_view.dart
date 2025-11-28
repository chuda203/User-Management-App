import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../view_models/home_view_model.dart';
import '../components/user_list_item.dart';
import '../../user_list/view_models/user_list_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeViewModel>(context, listen: false).initializeUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouteConstants.loginRoute);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here are our top users',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.users.isEmpty) {
                    return const Center(child: Text('No users found'));
                  }

                  return Column(
                    children: [
                      // Show first 3 users
                      ...viewModel.users.map(
                        (user) => UserListItem(
                          user: user,
                          onTap: () {
                            // For detail view, pass the user ID so the detail view can fetch original data
                            Navigator.pushNamed(
                              context,
                              RouteConstants.userDetailRoute,
                              arguments: {
                                'id': user.id,
                                'fromHome': true,
                              }, // Mark as coming from home
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Initialize the user list before navigating
                            final userListViewModel =
                                Provider.of<UserListViewModel>(
                                  context,
                                  listen: false,
                                );
                            userListViewModel.initializeUsers();
                            Navigator.pushNamed(
                              context,
                              RouteConstants.userListRoute,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View All Users',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
