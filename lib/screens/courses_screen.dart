import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../widgets/app_logo.dart';
import '../services/moodle_service.dart';

class CoursesScreen extends StatefulWidget {
  final Function(Course) onOpenCourse;

  const CoursesScreen({super.key, required this.onOpenCourse});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedFilter = 'Todos';
  String _searchQuery = '';
  List<Course> _courses = MockData.courses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoodleCourses();
  }

  Future<void> _loadMoodleCourses() async {
    try {
      final rawCourses = await MoodleService.getCourses();
      if (rawCourses.isNotEmpty) {
        final mapped = rawCourses.map((c) {
          return Course(
            id: c['id'].toString(),
            name: c['fullname'] ?? 'Curso Moodle',
            code: c['shortname'] ?? 'MOD',
            description: c['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Curso oficial sincronizado desde Moodle LMS.',
            teacher: 'Profesor Titular Moodle',
            progress: 0.85,
            status: 'En curso',
            iconName: 'school',
            modules: [
              CourseModule(title: 'Módulo 1: Introducción y Bienvenida', duration: '1 semana', isCompleted: true),
              CourseModule(title: 'Módulo 2: Contenidos Oficiales Moodle', duration: '3 semanas', isCompleted: false),
            ],
            activities: [
              Activity(
                id: 'm_${c['id']}_1',
                title: 'Evaluación Diagnóstica Moodle',
                courseName: c['fullname'] ?? 'Curso',
                dueDate: '30 Oct 2026',
                status: 'pendiente',
                type: 'examen',
              ),
            ],
          );
        }).toList();

        if (mounted) {
          setState(() {
            _courses = mapped;
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _courses.where((course) {
      final matchesFilter = _selectedFilter == 'Todos' || course.status == _selectedFilter;
      final matchesSearch = course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 28),
            const SizedBox(width: 8),
            const Text('Mis Cursos (Moodle)'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o clave de materia...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todos', 'En curso', 'Completados'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: AppTheme.skyBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Courses List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.skyBlue))
                  : filteredCourses.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron cursos.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => widget.onOpenCourse(course),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.skyBlue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                course.code,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.skyBlue,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: course.status == 'En curso'
                                                    ? AppTheme.warningOrange.withOpacity(0.15)
                                                    : AppTheme.successGreen.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                course.status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: course.status == 'En curso'
                                                      ? AppTheme.warningOrange
                                                      : AppTheme.successGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          course.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          course.teacher,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          course.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textMuted,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // Progress Bar
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Progreso del curso',
                                                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                                ),
                                                Text(
                                                  '${(course.progress * 100).toInt()}%',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: course.progress,
                                                backgroundColor: AppTheme.borderColor,
                                                color: course.progress == 1.0
                                                    ? AppTheme.successGreen
                                                    : AppTheme.skyBlue,
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
