import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:human_benchmark/data/model/chimp_test_result.dart';

class ChimpTestResultPage extends StatelessWidget {
  const ChimpTestResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeData = GoRouterState.of(context).extra! as Map<String, dynamic>;
    final ChimpTestResult gameResult = routeData['result'] as ChimpTestResult;
    return Scaffold(
      body: Center(
        child: Text('Highest length: ${gameResult.sequenceLength}'),
      ),
    );
  }
}
