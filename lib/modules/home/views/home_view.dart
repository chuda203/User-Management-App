import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/route_constants.dart';
import '../view_models/home_view_model.dart';
import '../components/user_list_item.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..initializeUsers(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            Consumer<HomeViewModel>(
              builder: (context, homeViewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    // Perform the logout which clears the token
                    await homeViewModel.logout();

                    // Navigate back to login screen
                    Navigator.pushReplacementNamed(
                      context,
                      RouteConstants.loginRoute,
                    );
                  },
                );
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
      ),
    );
  }
}
