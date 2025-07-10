import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

class CreditBankCubit extends Cubit<int> {
  CreditBankCubit() : super(0);

  void addCredits(int amount) {
    emit(state + amount);
  }

  void subtractCredits(int amount) {
    emit(max(0, state - amount));
  }
}
