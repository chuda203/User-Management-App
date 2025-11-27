import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../components/user_detail_card.dart';
import '../../../core/services/user_service.dart';

class UserDetailView extends StatefulWidget {
  const UserDetailView({super.key});

  @override
  State<UserDetailView> createState() => _UserDetailViewState();
}

class _UserDetailViewState extends State<UserDetailView> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully initialized before calling async operations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUserDetail();
    });
  }

  Future<void> _loadUserDetail() async {
    try {
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
        if (mounted) {
          setState(() {
            _isLoading = false;
            _user = null;
          });
        }
        return;
      }

      // Get the original user with photo avatar from the service
      final userService = UserService();
      final originalUser = await userService.getUserById(userId);

      if (mounted) {
        setState(() {
          _user = originalUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _user = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Detail'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Detail'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('User not found'),
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: UserDetailCard(user: _user!),
        ),
      ),
    );
  }
}