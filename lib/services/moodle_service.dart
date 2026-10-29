import 'dart:convert';
import 'package:http/http.dart' as http;

class MoodleService {
  // Dirección del proxy local accesible desde el teléfono Android físico en la red local
  static const String proxyUrl = 'http://192.168.1.121:3000';

  /// Obtiene información general del sitio y del usuario autenticado
  static Future<Map<String, dynamic>> getSiteInfo() async {
    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'wsfunction': 'core_webservice_get_site_info'}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Error HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('No se pudo conectar con el servidor Moodle via Proxy: $e');
    }
  }

  /// Obtiene la lista de cursos reales (excluyendo ID 1, asegurando el curso Introducción a IINICIA ID 2)
  static Future<List<dynamic>> getCourses() async {
    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'wsfunction': 'core_course_get_courses'}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.where((c) => c['id'] != 1).map((c) {
            c['fullname'] = (c['fullname'] ?? '').toString().trim();
            c['shortname'] = (c['shortname'] ?? '').toString().trim();
            return c;
          }).toList();
        } else if (data is Map && data.containsKey('error')) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Error al consultar cursos');
    } catch (e) {
      throw Exception('Error de conexión al obtener cursos: $e');
    }
  }

  /// Obtiene las categorías de cursos
  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'wsfunction': 'core_course_get_categories'}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Obtiene los contenidos, secciones y recursos de un curso específico (Ej. ID 2 para Introducción a IINICIA)
  static Future<List<dynamic>> getCourseContents(int courseId) async {
    try {
      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'wsfunction': 'core_course_get_contents',
          'params': {'courseid': courseId}
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
