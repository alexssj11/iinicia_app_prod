import '../models/app_models.dart';
import '../data/mock_data.dart';
import 'supabase_service.dart';
import 'moodle_api_service.dart';

class IniciaRepository {
  /// Obtiene el perfil del usuario autenticado (desde Supabase si está disponible, con fallback a MockData)
  static Future<UserProfile> fetchCurrentProfile() async {
    try {
      final supaUser = await SupabaseService.fetchUserProfile();
      if (supaUser != null) {
        return UserProfile(
          name: '${supaUser['first_name'] ?? ''} ${supaUser['last_name'] ?? ''}'.trim(),
          email: supaUser['email'] ?? MockData.student.email,
          program: 'Ingeniería en Sistemas Computacionales',
          studentId: '${supaUser['moodle_user_id'] ?? '20245892'}',
          semester: '6° Semestre',
          avatarInitials: '${supaUser['first_name']?[0] ?? 'A'}${supaUser['last_name']?[0] ?? 'R'}',
        );
      }
    } catch (_) {
      // Fallback si la BDD Supabase no está conectada o no hay sesión activa
    }
    return MockData.student;
  }

  /// Obtiene los cursos reales (combinando Moodle API y MockData)
  static Future<List<Course>> fetchCourses({String? moodleUrl, String? moodleToken}) async {
    try {
      if (moodleUrl != null && moodleToken != null && moodleUrl.isNotEmpty && moodleToken.isNotEmpty) {
        final moodleCourses = await MoodleApiService.getCourses(baseUrl: moodleUrl, token: moodleToken);
        if (moodleCourses.isNotEmpty) {
          return moodleCourses.map((mc) => Course(
            id: 'm_${mc.id}',
            name: mc.fullname,
            code: mc.shortname,
            description: 'Curso sincronizado desde Moodle LMS oficial.',
            teacher: 'Profesor Titular Moodle',
            progress: mc.progress / 100.0,
            status: mc.completed ? 'Completados' : 'En curso',
            iconName: 'school',
            modules: [],
            activities: [],
          )).toList();
        }
      }
    } catch (_) {
      // Fallback a datos estáticos
    }
    return MockData.courses;
  }

  /// Obtiene las actividades académicas reales
  static Future<List<Activity>> fetchActivities({String? moodleUrl, String? moodleToken}) async {
    try {
      if (moodleUrl != null && moodleToken != null && moodleUrl.isNotEmpty && moodleToken.isNotEmpty) {
        final moodleAssigns = await MoodleApiService.getAssignments(baseUrl: moodleUrl, token: moodleToken);
        if (moodleAssigns.isNotEmpty) {
          return moodleAssigns.map((ma) => Activity(
            id: 'ma_${ma.id}',
            title: ma.name,
            courseName: ma.courseName,
            dueDate: 'Próxima entrega',
            status: ma.submitted ? 'entregada' : 'pendiente',
            type: 'tarea',
          )).toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return MockData.allActivities;
  }
}
