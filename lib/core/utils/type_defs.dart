import 'package:fpdart/fpdart.dart';
import 'package:event_management_realtime/core/error/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;
