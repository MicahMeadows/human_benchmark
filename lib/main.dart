import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/pages/chimp_test_page.dart';
import 'package:human_benchmark/pages/chimp_test_result_page.dart';
import 'package:human_benchmark/pages/game_select_page.dart';
import 'package:human_benchmark/pages/reaction_time_test_page.dart';
import 'package:human_benchmark/pages/visual_memory_page.dart';

void main() {
  runApp(MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: GameSelectPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/visual_memory_game',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: VisualMemoryPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/reaction_game',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: ReactionTimeTestPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/chimp_game_result',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: ChimpTestResultPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/chimp_game',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: ChimpTestPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          );
        },
      ),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
