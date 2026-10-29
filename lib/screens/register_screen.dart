import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Registro real en Supabase Auth
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'role': _selectedRole,
        },
      );

      if (response.user != null) {
        // Guardar rol adicional en user_roles si es necesario
        try {
          final roleId = _selectedRole == 'teacher' ? 5 : 6; // IDs según roles base
          await SupabaseService.client.from('user_roles').insert({
            'user_id': response.user!.id,
            'role_id': roleId,
          });
        } catch (_) {}

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión.'), backgroundColor: AppTheme.successGreen),
          );
          widget.onRegisterSuccess();
        }
      } else {
        throw Exception('No se pudo completar el registro en Supabase.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el registro: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppTheme.errorRed,
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
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackToLogin,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              const Center(child: AppLogo(size: 60, showSubtitle: true)),
              const SizedBox(height: 20),
              const Text(
                'Registro de Cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
              ),
              const SizedBox(height: 6),
              const Text('Crea tu cuenta institucional en la plataforma.', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
              const SizedBox(height: 24),

              const Text('Nombre(s)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(hintText: 'Ej. María'),
              ),
              const SizedBox(height: 16),

              const Text('Apellidos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(hintText: 'Ej. López Pérez'),
              ),
              const SizedBox(height: 16),

              const Text('Correo institucional', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'maria.lopez@inicia.edu.mx'),
              ),
              const SizedBox(height: 16),

              const Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '••••••••'),
              ),
              const SizedBox(height: 16),

              const Text('Tipo de usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(filled: true, fillColor: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Estudiante')),
                  DropdownMenuItem(value: 'teacher', child: Text('Profesor / Docente')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Registrarse'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?', style: TextStyle(color: AppTheme.textMuted)),
                  TextButton(
                    onPressed: widget.onBackToLogin,
                    child: const Text('Inicia sesión', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.skyBlue)),
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
