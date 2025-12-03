import 'package:event_management_realtime/features/auth/presentation/auth_controller.dart';
import 'package:event_management_realtime/features/auth/presentation/login_screen.dart';
import 'package:event_management_realtime/features/auth/presentation/signup_screen.dart';
import 'package:event_management_realtime/features/events/domain/event_entity.dart';
import 'package:event_management_realtime/features/events/presentation/create_edit_event_screen.dart';
import 'package:event_management_realtime/features/events/presentation/event_detail_screen.dart';

import 'package:event_management_realtime/features/events/presentation/event_list_screen.dart';
import 'package:event_management_realtime/features/analytics/presentation/analytics_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(userProvider);
  
  return GoRouter(
    initialLocation: LoginScreen.routeName,
    routes: [
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignupScreen.routeName,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: EventListScreen.routeName,
        builder: (context, state) => const EventListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            name: CreateEditEventScreen.routeName,
            builder: (context, state) => const CreateEditEventScreen(),
          ),
          GoRoute(
            path: ':id',
            name: EventDetailScreen.routeName,
            builder: (context, state) {
              final event = state.extra as EventEntity?;
              final eventId = state.pathParameters['id']!;
              return EventDetailScreen(eventId: eventId, event: event);
            },
          ),
        ],
      ),
      GoRoute(
        path: AnalyticsScreen.routeName,
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isLoggingIn = state.uri.toString() == LoginScreen.routeName;
      final isSigningUp = state.uri.toString() == SignupScreen.routeName;

      if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
        return LoginScreen.routeName;
      }

      if (isLoggedIn && (isLoggingIn || isSigningUp)) {
        return EventListScreen.routeName;
      }

      return null;
    },
  );
});
