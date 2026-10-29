import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'moodle_tester_screen.dart';

class AdminNavigationShell extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminNavigationShell({super.key, required this.onLogout});

  @override
  State<AdminNavigationShell> createState() => _AdminNavigationShellState();
}

class _AdminNavigationShellState extends State<AdminNavigationShell> {
  int _currentIndex = 0;
  bool _showMoodleTester = false;

  @override
  Widget build(BuildContext context) {
    if (_showMoodleTester) {
      return MoodleTesterScreen(onBack: () => setState(() => _showMoodleTester = false));
    }

    final List<Widget> adminScreens = [
      // 1. Gestión Académica & Cohortes
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppLogo(size: 28),
              SizedBox(width: 8),
              Text('Panel Admin - Académico'),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.navyBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel de Control Administrador', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Gestión global de programas, cohortes y matrículas sincronizadas.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Programas Activos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
            const SizedBox(height: 12),
            _adminCard('Ingeniería en Sistemas Computacionales', 'ISC-2026', '3 Cohortes activas • 145 Estudiantes'),
            _adminCard('Licenciatura en Administración Educativa', 'LAE-2026', '2 Cohortes activas • 90 Estudiantes'),
          ],
        ),
      ),

      // 2. Integración y Sincronización Moodle
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Moodle API Global'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: 20),
                const Text('Sincronización con Moodle LMS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                const SizedBox(height: 8),
                const Text('Administra la conexión REST global, tokens de Web Service y verifica la sincronización de usuarios.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showMoodleTester = true),
                  icon: const Icon(Icons.hub_rounded),
                  label: const Text('Abrir Consola Moodle API'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
                ),
              ],
            ),
          ),
        ),
      ),

      // 3. Auditoría y Seguridad
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Auditoría del Sistema'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Registros de Auditoría (Audit Logs)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
            const SizedBox(height: 12),
            _auditLogCard('USER_LOGIN', 'Alex Rodríguez inició sesión', 'Hace 5 minutos'),
            _auditLogCard('COURSE_SYNC', 'Sincronización Moodle completada', 'Hace 1 hora'),
            _auditLogCard('ROLE_ASSIGNED', 'Rol teacher asignado a Dra. Elena Gómez', 'Hace 1 día'),
          ],
        ),
      ),

      // 4. Perfil Administrador
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Perfil Administrador'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    const AppLogo(size: 70),
                    const SizedBox(height: 14),
                    const Text('Admin General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                    const SizedBox(height: 4),
                    const Text('admin@inicia.edu.mx', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.errorRed.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Text('Superadmin', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout, color: AppTheme.errorRed),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorRed)),
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      body: adminScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.pureWhite,
        selectedItemColor: AppTheme.skyBlue,
        unselectedItemColor: AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), activeIcon: Icon(Icons.admin_panel_settings_rounded), label: 'Académico'),
          BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), activeIcon: Icon(Icons.hub_rounded), label: 'Moodle API'),
          BottomNavigationBarItem(icon: Icon(Icons.security_outlined), activeIcon: Icon(Icons.security_rounded), label: 'Auditoría'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _adminCard(String title, String code, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.navyBlue)),
          const SizedBox(height: 2),
          Text('$code • $subtitle', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _auditLogCard(String action, String detail, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.pureWhite, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.skyBlue)),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
            ],
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
