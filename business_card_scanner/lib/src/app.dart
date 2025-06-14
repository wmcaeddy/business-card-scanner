import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:settings/settings.dart';

import 'injection_container.dart';
import 'presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>(
          create: (BuildContext context) => LocaleCubit(
            getLocale: getIt(),
            saveLocale: getIt(),
          )..loadLocale(),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(builder: (context, state) {
      return MaterialApp(
        title: 'BizScan',
        locale: state.locale,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F37C9)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      );
    });
  }
}
