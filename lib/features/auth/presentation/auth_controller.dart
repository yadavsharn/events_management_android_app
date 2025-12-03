import 'package:event_management_realtime/core/utils/utils.dart';
import 'package:event_management_realtime/features/auth/data/auth_repository_impl.dart';
import 'package:event_management_realtime/features/auth/domain/auth_repository.dart';
import 'package:event_management_realtime/features/auth/domain/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateProvider<UserEntity?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    ref: ref,
  );
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false); // Loading state

  Future<void> signInWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;
    final res = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (user) {
        _ref.read(userProvider.notifier).update((state) => user);
        // Navigate to home (Handled by Router stream usually, or manual nav)
      },
    );
  }

  Future<void> signUpWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = true;
    final res = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (user) {
        _ref.read(userProvider.notifier).update((state) => user);
      },
    );
  }

  Future<void> getUserData() async {
    final res = await _authRepository.getCurrentUser();
    res.fold(
      (l) => _ref.read(userProvider.notifier).update((state) => null),
      (user) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  Future<void> signOut(BuildContext context) async {
    final res = await _authRepository.signOut();
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => null);
      },
    );
  }
}
