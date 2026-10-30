import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { home, goals, journal, insights }

class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.home);

  void selectTab(AppTab tab) {
    if (tab != state) emit(tab);
  }
}
