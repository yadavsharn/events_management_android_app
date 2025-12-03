import 'package:event_management_realtime/core/error/failure.dart';
import 'package:event_management_realtime/core/utils/type_defs.dart';
import 'package:event_management_realtime/features/auth/data/auth_remote_data_source.dart';
import 'package:event_management_realtime/features/auth/domain/auth_repository.dart';
import 'package:event_management_realtime/features/auth/domain/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  FutureEither<UserEntity> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(const AuthFailure('User not logged in'));
      }
      return right(user);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return right(user);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return right(user);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureVoid signOut() async {
    try {
      await _remoteDataSource.signOut();
      return right(null);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
