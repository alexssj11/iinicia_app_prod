import 'dart:convert';
import 'package:http/http.dart' as http;

class MoodleSiteInfo {
  final String sitename;
  final String username;
  final String fullname;
  final String lang;
  final int userid;

  MoodleSiteInfo({
    required this.sitename,
    required this.username,
    required this.fullname,
    required this.lang,
    required this.userid,
  });

  factory MoodleSiteInfo.fromJson(Map<String, dynamic> json) {
    return MoodleSiteInfo(
      sitename: json['sitename'] ?? 'Campus Moodle',
      username: json['username'] ?? 'usuario',
      fullname: json['fullname'] ?? 'Estudiante',
      lang: json['lang'] ?? 'es',
      userid: json['userid'] ?? 1,
    );
  }
}

class MoodleCourse {
  final int id;
  final String fullname;
  final String shortname;
  final int progress;
  final bool completed;

  MoodleCourse({
    required this.id,
    required this.fullname,
    required this.shortname,
    required this.progress,
    required this.completed,
  });

  factory MoodleCourse.fromJson(Map<String, dynamic> json) {
    return MoodleCourse(
      id: json['id'] ?? 1,
      fullname: json['fullname'] ?? 'Curso sin nombre',
      shortname: json['shortname'] ?? 'MOD',
      progress: json['progress'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }
}

class MoodleAssignment {
  final int id;
  final String name;
  final int dueDate;
  final String courseName;
  final bool submitted;

  MoodleAssignment({
    required this.id,
    required this.name,
    required this.dueDate,
    required this.courseName,
    required this.submitted,
  });

  factory MoodleAssignment.fromJson(Map<String, dynamic> json) {
    return MoodleAssignment(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Tarea',
      dueDate: json['duedate'] ?? 0,
      courseName: json['coursename'] ?? 'Curso',
      submitted: json['submitted'] ?? false,
    );
  }
}

class MoodleApiService {
  // Configuración por defecto para conexión real con Moodle LMS
  static String defaultBaseUrl = 'https://moodle.inicia.edu.mx';
  static String defaultToken = '';

  /// Conexión real a Moodle REST API (core_webservice_get_site_info)
  static Future<Map<String, dynamic>> testConnection({
    required String baseUrl,
    required String token,
  }) async {
    if (baseUrl.isEmpty || token.isEmpty) {
      return {
        'success': false,
        'message': 'Por favor ingresa la URL del servidor y el Token de Moodle.',
      };
    }

    try {
      final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final endpoint = Uri.parse('$cleanUrl/webservice/rest/server.php?wstoken=$token&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json');
      
      final response = await http.get(endpoint).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('exception')) {
          return {
            'success': false,
            'message': 'Error de autenticación Moodle: ${data['message'] ?? 'Token inválido'}',
          };
        }
        return {
          'success': true,
          'message': 'Conexión exitosa con Moodle LMS (${data['sitename'] ?? 'Campus Virtual'})',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Error HTTP ${response.statusCode}: Servidor Moodle no accesible o URL incorrecta.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: No se pudo conectar al servidor Moodle ($e).',
      };
    }
  }

  /// Obtiene los cursos reales del usuario desde Moodle (core_enrol_get_users_courses)
  static Future<List<MoodleCourse>> getCourses({
    required String baseUrl,
    required String token,
    int userid = 20245892,
  }) async {
    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final endpoint = Uri.parse('$cleanUrl/webservice/rest/server.php?wstoken=$token&wsfunction=core_enrol_get_users_courses&userid=$userid&moodlewsrestformat=json');

    final response = await http.get(endpoint).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded.map((c) => MoodleCourse.fromJson(c)).toList();
      } else if (decoded is Map && decoded.containsKey('exception')) {
        throw Exception(decoded['message']);
      }
    }
    throw Exception('No se pudieron obtener los cursos de Moodle.');
  }

  /// Obtiene las tareas reales desde Moodle (mod_assign_get_assignments)
  static Future<List<MoodleAssignment>> getAssignments({
    required String baseUrl,
    required String token,
  }) async {
    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final endpoint = Uri.parse('$cleanUrl/webservice/rest/server.php?wstoken=$token&wsfunction=mod_assign_get_assignments&moodlewsrestformat=json');

    final response = await http.get(endpoint).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('courses')) {
        List<MoodleAssignment> allAssigns = [];
        for (var course in decoded['courses']) {
          String cName = course['fullname'] ?? 'Curso Moodle';
          if (course['assignments'] != null) {
            for (var assign in course['assignments']) {
              assign['coursename'] = cName;
              allAssigns.add(MoodleAssignment.fromJson(assign));
            }
          }
        }
        return allAssigns;
      } else if (decoded is Map && decoded.containsKey('exception')) {
        throw Exception(decoded['message']);
      }
    }
    throw Exception('No se pudieron obtener las tareas de Moodle.');
  }
}
