import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const IniciaApp());
}

class IniciaApp extends StatelessWidget {
  const IniciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INICIA - Instituto de Innovación y Ciencias Aplicadas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}

enum AppState { welcome, login, register, mainApp }

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppState _currentState = AppState.welcome;

  void _goToLogin() {
    setState(() {
      _currentState = AppState.login;
    });
  }

  void _goToRegister() {
    setState(() {
      _currentState = AppState.register;
    });
  }

  void _goToMainApp() {
    setState(() {
      _currentState = AppState.mainApp;
    });
  }

  void _logout() {
    setState(() {
      _currentState = AppState.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case AppState.welcome:
        return WelcomeScreen(onGetStarted: _goToLogin);
      case AppState.login:
        return LoginScreen(
          onLoginSuccess: _goToMainApp,
          onNavigateToRegister: _goToRegister,
        );
      case AppState.register:
        return RegisterScreen(
          onRegisterSuccess: _goToLogin,
          onBackToLogin: _goToLogin,
        );
      case AppState.mainApp:
        return MainNavigationShell(onLogout: _logout);
    }
  }
}
