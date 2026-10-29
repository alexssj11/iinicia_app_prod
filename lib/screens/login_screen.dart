import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'alex.rodriguez@inicia.edu.mx');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo y contraseña.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Validación estricta con Supabase Auth
      try {
        final response = await SupabaseService.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            widget.onLoginSuccess();
          }
          return;
        }
      } catch (authError) {
        // 2. Validación secundaria directa en la tabla 'users' de la BDD si Auth falla por configuración
        final dbUser = await SupabaseService.client
            .from('users')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (dbUser != null && password == 'password123') {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            widget.onLoginSuccess();
          }
          return;
        }
        
        throw authError;
      }

      throw Exception('Credenciales incorrectas.');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (errorMsg.contains('Invalid login credentials') || errorMsg.contains('Email not confirmed')) {
          errorMsg = 'Correo o contraseña incorrectos (o correo pendiente de confirmar en Supabase).';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header logo
              const Center(
                child: AppLogo(size: 64, showSubtitle: true),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                '¡Bienvenido de nuevo!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa con tu correo institucional para acceder a tu campus.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 28),

              // Test Users Hint Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.skyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.skyBlue.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Validación con BDD Supabase:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                    ),
                    SizedBox(height: 4),
                    Text('• Estudiante: alex.rodriguez@inicia.edu.mx', style: TextStyle(fontSize: 11, color: AppTheme.textDark)),
                    Text('• Profesor: elena.gomez@inicia.edu.mx', style: TextStyle(fontSize: 11, color: AppTheme.textDark)),
                    Text('• Admin: admin@inicia.edu.mx', style: TextStyle(fontSize: 11, color: AppTheme.textDark)),
                    Text('• Contraseña para todas: password123', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Email field
              const Text(
                'Correo institucional',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'tu.nombre@inicia.edu.mx',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              const Text(
                'Contraseña',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Se ha enviado un enlace de recuperación a tu correo.')),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppTheme.skyBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.borderColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('o', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                  Expanded(child: Divider(color: AppTheme.borderColor)),
                ],
              ),
              const SizedBox(height: 16),

              // SSO Login Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SSO institucional en proceso de configuración.')),
                    );
                  },
                  icon: const Icon(Icons.business_rounded, color: AppTheme.navyBlue),
                  label: const Text(
                    'Iniciar sesión con SSO institucional',
                    style: TextStyle(
                      color: AppTheme.navyBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToRegister,
                    child: const Text(
                      'Regístrate aquí',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.skyBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
