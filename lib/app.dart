import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trailapp/logic/auth_bloc.dart';
import 'package:trailapp/logic/crud_bloc.dart';
import 'package:trailapp/repositories/crud_repository.dart';
import 'package:trailapp/ui/login_screen.dart';
import 'package:trailapp/ui/crud_list_screen.dart';

class TrailApp extends StatelessWidget {
  const TrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(const CheckAuthStatus()),
        ),
        BlocProvider<CrudBloc>(
          create: (_) => CrudBloc(repository: CrudRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Supabase CRUD',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Screen transition logic
            if (state is Authenticated) {
              return const CrudListScreen();
            }
            
            // Show splash (simple progress) only on initial load
            if (state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            // For all other states (Unauthenticated, Loading, Error, Success),
            // stay on the LoginScreen. The LoginScreen handles its own 
            // inner loading indicators and snackbars for errors/success.
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
