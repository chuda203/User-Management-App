import 'package:first_task/core/data/local/local_user_data_source.dart';
import 'package:first_task/core/data/remote/remote_user_data_source.dart';
import 'package:first_task/core/models/user.dart';

abstract class UserRepository {
  Future<List<User>> getAllUsers({int page});
  Future<User?> getUserById(int id);
  Future<User> updateUser(int id, {String? name, String? job, String? email});
  Future<User> createUser({String? name, String? job, String? email});
  Future<bool> deleteUser(int id);
  Future<void> syncUsersFromRemote();
}

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource _localDataSource;
  final RemoteUserDataSource _remoteDataSource;

  UserRepositoryImpl({
    required LocalUserDataSource localDataSource,
    required RemoteUserDataSource remoteDataSource,
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
      
      // Then update in remote API
      final updatedUser = await _remoteDataSource.updateUser(
        id,
        name: name,
        job: job,
        email: email,
      );
      
      // Sync back to local database in case the remote response has different data
      await _localDataSource.insertUser(updatedUser);
      
      return updatedUser;
    } catch (e) {
      // If remote fails, still return the local updated user
      try {
        final updatedUser = await _remoteDataSource.updateUser(
          id,
          name: name,
          job: job,
          email: email,
        );
        await _localDataSource.insertUser(updatedUser);
        return updatedUser;
      } catch (remoteError) {
        // If remote fails but local succeeded, return updated user from local
        final localUser = await _localDataSource.getUserById(id);
        if (localUser != null) {
          return localUser;
        } else {
          rethrow; // Re-throw if both fail
        }
      }
    }
  }

  @override
  Future<User> createUser({String? name, String? job, String? email}) async {
    try {
      // Create in remote API first to get the server-generated ID
      final newUser = await _remoteDataSource.createUser(
        name: name,
        job: job,
        email: email,
      );
      
      // Cache in local database
      await _localDataSource.insertUser(newUser);
      
      return newUser;
    } catch (e) {
      // If remote API fails, we can't create in local since we need the server ID
      rethrow;
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    try {
      // Delete from local database first
      await _localDataSource.deleteUser(id);
      
      // Then delete from remote API
      final result = await _remoteDataSource.deleteUser(id);
      
      return result;
    } catch (e) {
      // If remote fails, still return true if local deletion succeeded
      try {
        final result = await _remoteDataSource.deleteUser(id);
        // Also remove from local in case it wasn't removed before
        await _localDataSource.deleteUser(id);
        return result;
      } catch (remoteError) {
        // If remote fails, check if local deletion happened
        return true; // We already deleted locally, so conceptually the user is deleted
      }
    }
  }

  @override
  Future<void> syncUsersFromRemote() async {
    try {
      final remoteUsers = await _remoteDataSource.getAllUsers();
      await _localDataSource.clearUsers();
      await _localDataSource.insertAllUsers(remoteUsers);
    } catch (e) {
      // If sync fails, we keep the local data as is
      // The next time we try to fetch, we'll attempt remote again
    }
  }
}