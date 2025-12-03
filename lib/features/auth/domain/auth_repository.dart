import 'package:event_management_realtime/core/utils/type_defs.dart';
import 'package:event_management_realtime/features/auth/domain/user_entity.dart';

abstract class AuthRepository {
  FutureEither<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });

  FutureEither<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  FutureEither<UserEntity> getCurrentUser();

  FutureVoid signOut();
}
