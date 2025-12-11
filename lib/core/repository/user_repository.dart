import 'package:flutter/foundation.dart';
import 'package:first_task/core/services/local_user_service.dart';
import 'package:first_task/core/services/remote_user_service.dart';
import 'package:first_task/core/models/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers({int page});
  Future<User?> getUserById(int id);
  Future<User> updateUser(int id, {String? name, String? job, String? email});
  Future<User> createUser({String? name, String? job, String? email});
  Future<bool> deleteUser(int id);
  Future<void> syncUsersFromRemote();
  Future<void> syncPendingOperations();
}

class UserRepositoryImpl implements UserRepository {
  final LocalUserService _localDataSource;
  final RemoteUserService _remoteDataSource;

  UserRepositoryImpl({
    required LocalUserService localDataSource,
    required RemoteUserService remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<List<User>> getAllUsers({int page = 1}) async {
    try {
      // Try to get users from local database first
      final localUsers = await _localDataSource.getAllUsers();

      // If local database is empty, fetch from remote and cache locally
      if (localUsers.isEmpty) {
        await syncUsersFromRemote();
        return await _localDataSource.getAllUsers();
      }

      return localUsers;
    } catch (e) {
      // If there's an error with local database, fallback to remote API
      try {
        final remoteUsers = await _remoteDataSource.getAllUsers(page: page);
        // Cache the remote users locally for offline access
        await _localDataSource.insertAllUsers(remoteUsers);
        return remoteUsers;
      } catch (remoteError) {
        // If both local and remote fail, throw the original error
        rethrow;
      }
    }
  }

  @override
  Future<User?> getUserById(int id) async {
    try {
      // Try to get user from local database first
      User? localUser = await _localDataSource.getUserById(id);

      if (localUser != null) {
        return localUser;
      }

      // If not found locally, fetch from remote and cache
      final remoteUser = await _remoteDataSource.getUserById(id);
      if (remoteUser != null) {
        await _localDataSource.insertUser(remoteUser);
      }

      return remoteUser;
    } catch (e) {
      // If local fails, try remote
      try {
        final remoteUser = await _remoteDataSource.getUserById(id);
        if (remoteUser != null) {
          await _localDataSource.insertUser(remoteUser);
        }
        return remoteUser;
      } catch (remoteError) {
        // If both local and remote fail, return null
        return null;
      }
    }
  }

  @override
  Future<User> updateUser(int id, {String? name, String? job, String? email}) async {
    try {
      // Try to update in local database first
      final user = User(
        id: id,
        name: name ?? '',
        username: name?.toLowerCase() ?? 'updated',
        email: email ?? '',
        avatar: 'https://randomuser.me/api/portraits/lego/1.jpg',
      );

      await _localDataSource.updateUser(user);

      try {
        // Then update in remote API
        final updatedUser = await _remoteDataSource.updateUser(
          id,
          name: name,
          job: job,
          email: email,
        );
        debugPrint('[INFO] Successfully updated user ${id} on remote API');

        // Sync back to local database in case the remote response has different data
        await _localDataSource.insertUser(updatedUser);

        return updatedUser;
      } catch (remoteError) {
        debugPrint('[WARN] Failed to update user ${id} on remote API: $remoteError. Keeping local changes.');
        // Return local user with the changes
        return await _localDataSource.getUserById(id) ?? user;
      }
    } catch (e) {
      debugPrint('[ERROR] Failed to update user locally: $e');
      rethrow;
    }
  }

  @override
  Future<User> createUser({String? name, String? job, String? email}) async {
    // Generate a temporary negative ID for offline use
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    // Create a temporary user with the negative ID for immediate use
    final tempUser = User(
      id: tempId,
      name: name ?? 'New User',
      username: (name ?? 'newuser').toLowerCase(),
      email: email ?? '',
      avatar: 'https://randomuser.me/api/portraits/lego/1.jpg',
    );

    // Insert the temporary user into local database immediately for instant response
    await _localDataSource.insertUser(tempUser);
    debugPrint('[INFO] User created offline with temporary ID: $tempId');

    try {
      // Try to create in remote API
      final newUser = await _remoteDataSource.createUser(
        name: name,
        job: job,
        email: email,
      );

      // Update the local database with the actual server ID
      await _localDataSource.deleteUser(tempId); // Remove the temp user
      await _localDataSource.insertUser(newUser); // Insert with real ID

      debugPrint('[INFO] User successfully created with server ID: ${newUser.id}');

      return newUser;
    } catch (e) {
      // If remote fails, keep the temporary user and return it
      debugPrint('[ERROR] Failed to create user on remote API: $e. Keeping offline user with ID: $tempId');
      return tempUser;
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    // First delete from local database
    await _localDataSource.deleteUser(id);

    try {
      // Then try to delete from remote API
      final result = await _remoteDataSource.deleteUser(id);
      debugPrint('[INFO] Successfully deleted user $id from remote API');
      return result;
    } catch (remoteError) {
      // If remote fails, still return true since it's deleted locally
      debugPrint('[WARN] Failed to delete user $id from remote API: $remoteError. User deleted locally.');
      return true;
    }
  }

  @override
  Future<void> syncUsersFromRemote() async {
    // This method should only be called when logging in or when explicitly requested
    // to get fresh server data - not for regular sync of changes
    try {
      debugPrint('[INFO] Starting full sync from remote API...');
      final remoteUsers = await _remoteDataSource.getAllUsers();
      await _localDataSource.clearUsers();
      await _localDataSource.insertAllUsers(remoteUsers);
      debugPrint('[INFO] Successfully synced ${remoteUsers.length} users from remote API');
    } catch (e) {
      debugPrint('[ERROR] Failed to sync users from remote API: $e');
      // If sync fails, we keep the local data as is
      // The next time we try to fetch, we'll attempt remote again
    }
  }

  @override
  Future<void> syncPendingOperations() async {
    debugPrint('[INFO] Starting sync of pending operations (create/update/delete)...');

    try {
      // Check for users with negative IDs (temporary IDs for offline users)
      final allUsers = await _localDataSource.getAllUsers();
      final offlineUsers = allUsers.where((user) => user.id < 0).toList();

      // Try to sync each offline user
      for (final user in offlineUsers) {
        try {
          debugPrint('[INFO] Attempting to sync offline user: ${user.name} with temporary ID: ${user.id}');

          // Try to create the user on remote
          final newUser = await _remoteDataSource.createUser(
            name: user.name,
            email: user.email,
          );

          // Update the local database with the actual server ID
          await _localDataSource.deleteUser(user.id); // Remove the temp user
          await _localDataSource.insertUser(newUser); // Insert with real ID

          debugPrint('[INFO] Successfully synced offline user to server with ID: ${newUser.id}');
        } catch (e) {
          debugPrint('[WARN] Failed to sync offline user ${user.name} (temp ID: ${user.id}): $e. Will retry later.');
          // Continue to next user even if one fails
        }
      }

      debugPrint('[INFO] Pending operations sync completed');
    } catch (e) {
      debugPrint('[ERROR] Error during sync of pending operations: $e');
    }
  }
}