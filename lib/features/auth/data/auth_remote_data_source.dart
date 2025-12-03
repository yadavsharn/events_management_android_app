import 'package:event_management_realtime/core/constants/app_constants.dart';
import 'package:event_management_realtime/core/error/failure.dart';
import 'package:event_management_realtime/features/auth/data/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(Supabase.instance.client);
});

abstract class AuthRemoteDataSource {
  Session? get currentSession;
  Future<UserModel?> getCurrentUserData();
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabaseClient;
  const AuthRemoteDataSourceImpl(this._supabaseClient);

  @override
  Session? get currentSession => _supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentSession == null) return null;

      final userData = await _supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', currentSession!.user.id)
          .single();
      
      return UserModel.fromSupabase(userData);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerFailure('User is null!');
      }

      // Wait a bit for the trigger to create the profile
      // In a real app, you might want to retry or have a better flow
      await Future.delayed(const Duration(seconds: 1));

      final userData = await _supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromSupabase(userData);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const ServerFailure('User is null!');
      }

      final userData = await _supabaseClient
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromSupabase(userData);
    } on AuthException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
