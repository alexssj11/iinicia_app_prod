import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Cargando...';
  String _email = '';
  String _program = 'Ingeniería en Sistemas Computacionales';
  String _roleTitle = 'Estudiante Activo';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final email = user.email ?? '';
        _email = email;

        if (email.contains('admin')) {
          _name = 'Administrador General';
          _program = 'Gestión Global de Infraestructura';
          _roleTitle = 'Superadmin BDD';
        } else if (email.contains('elena')) {
          _name = 'Dra. Elena Gómez';
          _program = 'Departamento de Ciencias Computacionales';
          _roleTitle = 'Profesor Titular';
        } else {
          // Intentar obtener de Supabase
          final profile = await SupabaseService.fetchUserProfile();
          if (profile != null) {
            _name = '${profile['first_name'] ?? 'Alex'} ${profile['last_name'] ?? 'Rodríguez'}';
          } else {
            _name = email.split('@')[0].replaceAll('.', ' ').toUpperCase();
          }
          _roleTitle = 'Estudiante Activo';
        }
      }
    } catch (_) {
      _email = 'alex.rodriguez@inicia.edu.mx';
      _name = 'Alex Rodríguez';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppTheme.skyBlue)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 28),
            SizedBox(width: 8),
            Text('Mi Perfil'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar & Basic Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const AppLogo(size: 80),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.skyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _roleTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.skyBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Student Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _detailRow('Programa / Área', _program),
                    const Divider(height: 24, color: AppTheme.borderColor),
                    _detailRow('Matrícula / ID', '20245892'),
                    const Divider(height: 24, color: AppTheme.borderColor),
                    _detailRow('Estatus escolar', 'Activo (Regular)'),
                    const Divider(height: 24, color: AppTheme.borderColor),
                    _detailRow('Campus', 'Campus Virtual Central'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Menu Options
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _menuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Datos Personales',
                      onTap: () => _showMsg(context, 'Mostrando datos personales...'),
                    ),
                    _menuItem(
                      icon: Icons.school_outlined,
                      title: 'Historial Académico y Kardex',
                      onTap: () => _showMsg(context, 'Mostrando historial académico...'),
                    ),
                    _menuItem(
                      icon: Icons.settings_outlined,
                      title: 'Configuración de la App',
                      onTap: () => _showMsg(context, 'Configuraciones generales...'),
                    ),
                    _menuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Ayuda y Soporte Técnico',
                      onTap: () => _showMsg(context, 'Contactando a soporte técnico...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.errorRed),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.errorRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14)),
      ],
    );
  }

  Widget _menuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.skyBlue),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
    );
  }

  void _showMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
