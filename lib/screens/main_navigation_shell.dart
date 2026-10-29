import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';
import 'courses_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'course_detail_screen.dart';
import 'moodle_tester_screen.dart';
import 'teacher_navigation_shell.dart';
import 'admin_navigation_shell.dart';

class MainNavigationShell extends StatefulWidget {
  final VoidCallback onLogout;

  const MainNavigationShell({super.key, required this.onLogout});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  Course? _selectedCourse;
  bool _showMoodleTester = false;
  
  String? _userRole;
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user != null) {
        final email = user.email ?? '';
        
        // Detección por correo o consulta a la BDD
        if (email.contains('elena') || email.contains('teacher')) {
          setState(() { _userRole = 'teacher'; _isLoadingRole = false; });
          return;
        } else if (email.contains('admin')) {
          setState(() { _userRole = 'admin'; _isLoadingRole = false; });
          return;
        }

        // Consultar roles desde la BDD de Supabase
        final profile = await SupabaseService.fetchUserProfile();
        if (profile != null && profile['user_roles'] != null) {
          final rolesList = profile['user_roles'] as List;
          for (var ur in rolesList) {
            final roleName = ur['roles']?['name'] ?? '';
            if (roleName == 'teacher') {
              setState(() { _userRole = 'teacher'; _isLoadingRole = false; });
              return;
            } else if (roleName == 'superadmin' || roleName == 'tech_admin' || roleName == 'academic_admin') {
              setState(() { _userRole = 'admin'; _isLoadingRole = false; });
              return;
            }
          }
        }
      }
    } catch (_) {}

    setState(() {
      _userRole = 'student';
      _isLoadingRole = false;
    });
  }

  Future<void> _handleLogout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRole) {
      return const Scaffold(
        backgroundColor: AppTheme.pureWhite,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.skyBlue),
        ),
      );
    }

    // Enrutamiento dinámico según el rol detectado en Supabase
    if (_userRole == 'teacher') {
      return TeacherNavigationShell(onLogout: _handleLogout);
    } else if (_userRole == 'admin') {
      return AdminNavigationShell(onLogout: _handleLogout);
    }

    // Panel por defecto para Estudiantes
    if (_showMoodleTester) {
      return MoodleTesterScreen(onBack: () => setState(() => _showMoodleTester = false));
    }

    if (_selectedCourse != null) {
      return CourseDetailScreen(
        course: _selectedCourse!,
        onBack: () => setState(() => _selectedCourse = null),
        onOpenMoodleModal: _showMoodleModal,
      );
    }

    final List<Widget> screens = [
      HomeScreen(
        onNavigateTab: (index) => setState(() => _currentIndex = index),
        onOpenCourse: (course) => setState(() => _selectedCourse = course),
        onOpenMoodleModal: _showMoodleModal,
      ),
      CoursesScreen(onOpenCourse: (course) => setState(() => _selectedCourse = course)),
      const NotificationsScreen(),
      ProfileScreen(onLogout: _handleLogout),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.skyBlue,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Cursos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Notificaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded),
              activeIcon: Icon(Icons.menu_rounded),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodleModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            const Text(
              'Integración Moodle',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'La plataforma se conecta mediante API REST con Moodle LMS para sincronizar materias, calificaciones y actividades.\n\n¿Deseas abrir el probador de API de Moodle incorporado?',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _showMoodleTester = true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
            child: const Text('Probar API Moodle'),
          ),
        ],
      ),
    );
  }
}
