import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/cubit/game_result_cubit.dart';
import 'package:human_benchmark/widget/games/chimp_test_page.dart';
import 'package:human_benchmark/widget/chimp_test_result_page.dart';
import 'package:human_benchmark/widget/game_select_page.dart';
import 'package:human_benchmark/widget/games/reaction_time_test_page.dart';
import 'package:human_benchmark/widget/games/visual_memory_page.dart';

final gameResultCubit = GameResultCubit();

void registerDependencies() {
  GetIt.I.registerSingleton<GameResultCubit>(gameResultCubit);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies();
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
