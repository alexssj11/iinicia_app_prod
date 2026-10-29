import '../models/app_models.dart';

class MockData {
  static final UserProfile student = UserProfile(
    name: 'Alex Rodríguez',
    email: 'alex.rodriguez@inicia.edu.mx',
    program: 'Ingeniería en Sistemas Computacionales',
    studentId: '20245892',
    semester: '6° Semestre',
    avatarInitials: 'AR',
  );

  static final List<Course> courses = [
    Course(
      id: 'c1',
      name: 'Matemáticas Discretas',
      code: 'MAT-301',
      description: 'Estudio de estructuras algebraicas, grafos, árboles y lógica matemática aplicada a la computación.',
      teacher: 'Dra. Elena Gómez',
      progress: 0.75,
      status: 'En curso',
      iconName: 'calculate',
      modules: [
        CourseModule(title: 'Módulo 1: Lógica Proposicional', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 2: Teoría de Conjuntos', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 3: Teoría de Grafos', duration: '4 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 4: Autómatas Finitos', duration: '4 semanas', isCompleted: false),
      ],
      activities: [
        Activity(
          id: 'a1',
          title: 'Entrega de Proyecto Final de Grafos',
          courseName: 'Matemáticas Discretas',
          dueDate: '25 Oct 2026',
          status: 'pendiente',
          type: 'proyecto',
        ),
        Activity(
          id: 'a2',
          title: 'Examen Parcial 2',
          courseName: 'Matemáticas Discretas',
          dueDate: '28 Oct 2026',
          status: 'pendiente',
          type: 'examen',
        ),
      ],
    ),
    Course(
      id: 'c2',
      name: 'Programación Web',
      code: 'ISC-402',
      description: 'Desarrollo de aplicaciones web modernas utilizando React, TypeScript, Node.js y arquitecturas REST.',
      teacher: 'Mtro. Carlos Mendoza',
      progress: 0.88,
      status: 'En curso',
      iconName: 'code',
      modules: [
        CourseModule(title: 'Módulo 1: HTML5 y CSS3 Avanzado', duration: '2 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 2: JavaScript ES6+ y TypeScript', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 3: React Framework', duration: '4 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 4: Backend con Node.js y Express', duration: '4 semanas', isCompleted: false),
      ],
      activities: [
        Activity(
          id: 'a3',
          title: 'Práctica 4: Componentes en React',
          courseName: 'Programación Web',
          dueDate: '22 Oct 2026',
          status: 'pendiente',
          type: 'tarea',
        ),
      ],
    ),
    Course(
      id: 'c3',
      name: 'Redes de Computadoras',
      code: 'RED-501',
      description: 'Modelo OSI, protocolos TCP/IP, enrutamiento, seguridad en redes y administración de subredes.',
      teacher: 'Ing. Roberto Sánchez',
      progress: 0.60,
      status: 'En curso',
      iconName: 'router',
      modules: [
        CourseModule(title: 'Módulo 1: Introducción a Redes', duration: '2 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 2: Capa de Transporte TCP/UDP', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 3: Enrutamiento IP y Subnetting', duration: '4 semanas', isCompleted: false),
        CourseModule(title: 'Módulo 4: Seguridad y Firewalls', duration: '3 semanas', isCompleted: false),
      ],
      activities: [
        Activity(
          id: 'a4',
          title: 'Configuración de VLANs en Packet Tracer',
          courseName: 'Redes de Computadoras',
          dueDate: '18 Oct 2026',
          status: 'vencida',
          type: 'tarea',
        ),
      ],
    ),
    Course(
      id: 'c4',
      name: 'Base de Datos',
      code: 'BD-202',
      description: 'Diseño relacional, normalización, consultas SQL avanzadas, procedimientos almacenados y bases de datos NoSQL.',
      teacher: 'Dra. Sofía Morales',
      progress: 1.0,
      status: 'Completados',
      iconName: 'storage',
      modules: [
        CourseModule(title: 'Módulo 1: Modelo Entidad-Relación', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 2: Normalización y SQL', duration: '4 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 3: Stored Procedures y Triggers', duration: '3 semanas', isCompleted: true),
        CourseModule(title: 'Módulo 4: Introducción a MongoDB', duration: '2 semanas', isCompleted: true),
      ],
      activities: [
        Activity(
          id: 'a5',
          title: 'Evaluación Final de Base de Datos',
          courseName: 'Base de Datos',
          dueDate: '10 Sep 2026',
          status: 'entregada',
          type: 'examen',
        ),
      ],
    ),
  ];

  static final List<Activity> allActivities = [
    Activity(
      id: 'a1',
      title: 'Entrega de Proyecto Final de Grafos',
      courseName: 'Matemáticas Discretas',
      dueDate: '25 Oct 2026',
      status: 'pendiente',
      type: 'proyecto',
    ),
    Activity(
      id: 'a2',
      title: 'Examen Parcial 2',
      courseName: 'Matemáticas Discretas',
      dueDate: '28 Oct 2026',
      status: 'pendiente',
      type: 'examen',
    ),
    Activity(
      id: 'a3',
      title: 'Práctica 4: Componentes en React',
      courseName: 'Programación Web',
      dueDate: '22 Oct 2026',
      status: 'pendiente',
      type: 'tarea',
    ),
    Activity(
      id: 'a4',
      title: 'Configuración de VLANs en Packet Tracer',
      courseName: 'Redes de Computadoras',
      dueDate: '18 Oct 2026',
      status: 'vencida',
      type: 'tarea',
    ),
    Activity(
      id: 'a5',
      title: 'Evaluación Final de Base de Datos',
      courseName: 'Base de Datos',
      dueDate: '10 Sep 2026',
      status: 'entregada',
      type: 'examen',
    ),
  ];

  static final List<NotificationItem> notifications = [
    NotificationItem(
      id: 'n1',
      title: 'Nueva tarea asignada',
      description: 'Dra. Elena Gómez publicó "Entrega de Proyecto Final de Grafos" en Matemáticas Discretas.',
      time: 'Hace 2 horas',
      isRead: false,
      type: 'tarea',
    ),
    NotificationItem(
      id: 'n2',
      title: 'Calificación actualizada',
      description: 'Se ha publicado tu calificación de la Práctica 3 en Programación Web: 98/100.',
      time: 'Ayer',
      isRead: false,
      type: 'calificacion',
    ),
    NotificationItem(
      id: 'n3',
      title: 'Recordatorio de Examen',
      description: 'Examen Parcial 2 de Matemáticas Discretas programado para el 28 de Octubre.',
      time: 'Hace 3 días',
      isRead: true,
      type: 'examen',
    ),
    NotificationItem(
      id: 'n4',
      title: 'Aviso de Inscripción',
      description: 'El periodo de preinscripción para el próximo semestre inicia el 15 de Noviembre.',
      time: 'Hace 5 días',
      isRead: true,
      type: 'inscripcion',
    ),
  ];
}
