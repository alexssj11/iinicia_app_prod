class Course {
  final String id;
  final String name;
  final String code;
  final String description;
  final String teacher;
  final double progress; // 0.0 to 1.0
  final String status; // 'En curso', 'Completados', 'Todos'
  final String iconName;
  final List<CourseModule> modules;
  final List<Activity> activities;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.teacher,
    required this.progress,
    required this.status,
    required this.iconName,
    required this.modules,
    required this.activities,
  });
}

class CourseModule {
  final String title;
  final String duration;
  final bool isCompleted;

  CourseModule({
    required this.title,
    required this.duration,
    required this.isCompleted,
  });
}

class Activity {
  final String id;
  final String title;
  final String courseName;
  final String dueDate;
  String status; // 'pendiente', 'entregada', 'vencida'
  final String type; // 'tarea', 'examen', 'proyecto'

  Activity({
    required this.id,
    required this.title,
    required this.courseName,
    required this.dueDate,
    required this.status,
    required this.type,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  bool isRead;
  final String type; // 'tarea', 'examen', 'calificacion', 'inscripcion'

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String program;
  final String studentId;
  final String semester;
  final String avatarInitials;

  UserProfile({
    required this.name,
    required this.email,
    required this.program,
    required this.studentId,
    required this.semester,
    required this.avatarInitials,
  });
}
