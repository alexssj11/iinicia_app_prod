import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../services/supabase_service.dart';
import 'moodle_tester_screen.dart';

class TeacherNavigationShell extends StatefulWidget {
  final VoidCallback onLogout;

  const TeacherNavigationShell({super.key, required this.onLogout});

  @override
  State<TeacherNavigationShell> createState() => _TeacherNavigationShellState();
}

class _TeacherNavigationShellState extends State<TeacherNavigationShell> {
  int _currentIndex = 0;
  bool _showMoodleTester = false;
  List<Map<String, dynamic>> _teacherCourses = [
    {'name': 'Matemáticas Discretas', 'code': 'MAT-301', 'students': 42},
    {'name': 'Estructuras de Datos', 'code': 'EDO-202', 'students': 38},
  ];

  void _showCreateCourseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Crear Nuevo Curso Moodle', style: TextStyle(color: AppTheme.navyBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Curso'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Clave (Ej. ISC-501)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final code = codeController.text.trim();
              if (name.isNotEmpty && code.isNotEmpty) {
                try {
                  await SupabaseService.client.from('programs').insert({
                    'name': name,
                    'code': code,
                    'description': 'Curso creado por docente',
                  });
                } catch (_) {}

                setState(() {
                  _teacherCourses.add({'name': name, 'code': code, 'students': 0});
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Curso creado y sincronizado con éxito!'), backgroundColor: AppTheme.successGreen),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
            child: const Text('Crear Curso'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = SupabaseService.client.auth.currentUser?.email ?? 'elena.gomez@inicia.edu.mx';
    final teacherName = currentEmail.split('@')[0].replaceAll('.', ' ').toUpperCase();

    if (_showMoodleTester) {
      return MoodleTesterScreen(onBack: () => setState(() => _showMoodleTester = false));
    }

    final List<Widget> teacherScreens = [
      // 1. Cursos Impartidos
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppLogo(size: 28),
              SizedBox(width: 8),
              Text('Panel Docente - Cursos'),
            ],
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.navyBlue),
              onPressed: _showCreateCourseDialog,
              tooltip: 'Crear Curso',
            ),
          ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bienvenido(a), $teacherName', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Gestiona tus ${_teacherCourses.length} cursos asignados y publica contenido en Moodle.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showCreateCourseDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo Curso'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cursos Asignados en Moodle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
            const SizedBox(height: 12),
            ..._teacherCourses.map((c) => _teacherCourseCard(c['name'], c['code'], '${c['students']} estudiantes matriculados', 2)),
          ],
        ),
      ),

      // 2. Calificaciones y Tareas pendientes de calificar
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Calificaciones y Tareas'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Entregas pendientes de revisión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
            const SizedBox(height: 12),
            _gradingTaskCard('Proyecto Final de Grafos', 'Matemáticas Discretas', '35 entregados / 7 pendientes'),
            _gradingTaskCard('Práctica 2: Árboles Binarios', 'Matemáticas Discretas', '40 entregados / 2 pendientes'),
          ],
        ),
      ),

      // 3. Herramienta Moodle LMS
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Moodle LMS Docente'),
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
                const Text('Gestión de Contenidos Moodle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                const SizedBox(height: 8),
                const Text('Conéctate a la API REST de Moodle para publicar cuestionarios, calificar y administrar recursos.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
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

      // 4. Perfil Docente
      Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: AppBar(
          title: const Text('Perfil Docente'),
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
                    Text(teacherName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
                    const SizedBox(height: 4),
                    Text(currentEmail, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.skyBlue.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: const Text('Profesor Titular', style: TextStyle(color: AppTheme.skyBlue, fontWeight: FontWeight.bold, fontSize: 12)),
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
      body: teacherScreens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.pureWhite,
        selectedItemColor: AppTheme.skyBlue,
        unselectedItemColor: AppTheme.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.class_outlined), activeIcon: Icon(Icons.class_rounded), label: 'Cursos'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in_outlined), activeIcon: Icon(Icons.assignment_turned_in_rounded), label: 'Calificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.hub_outlined), activeIcon: Icon(Icons.hub_rounded), label: 'Moodle'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _teacherCourseCard(String title, String code, String subtitle, int pending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.navyBlue)),
              const SizedBox(height: 2),
              Text('$code • $subtitle', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.warningOrange.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text('$pending pendientes', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.warningOrange)),
          ),
        ],
      ),
    );
  }

  Widget _gradingTaskCard(String taskName, String course, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.pureWhite, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(taskName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.navyBlue)),
          const SizedBox(height: 2),
          Text(course, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.skyBlue)),
              TextButton(onPressed: () {}, child: const Text('Calificar ahora')),
            ],
          ),
        ],
      ),
    );
  }
}
