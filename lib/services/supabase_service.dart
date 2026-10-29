import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Credenciales oficiales de Supabase proporcionadas por el usuario
  static const String supabaseUrl = 'https://upyuztleczmwnouuloha.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_XAOr18-uO8QaUvn1wAyBjA_d9dfH1ZV';

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      // Manejo de error de inicialización
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // Obtiene el perfil de la tabla 'users' vinculado al usuario autenticado de Supabase
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return null;

      final data = await client
          .from('users')
          .select('*, user_roles(roles(name))')
          .eq('auth_user_id', user.id)
          .single();

      return data;
    } catch (_) {
      return null;
    }
  }

  // Obtiene las postulaciones/aplicaciones del usuario de la tabla 'program_applications'
  static Future<List<Map<String, dynamic>>> fetchUserApplications() async {
    try {
      final user = client.auth.currentUser;
      if (user == null) return [];

      final data = await client
          .from('program_applications')
          .select('*, programs(name, code), cohorts(name)')
          .eq('user_id', user.id);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}
