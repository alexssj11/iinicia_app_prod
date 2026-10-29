import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/moodle_api_service.dart';
import '../widgets/app_logo.dart';

class MoodleTesterScreen extends StatefulWidget {
  final VoidCallback onBack;

  const MoodleTesterScreen({super.key, required this.onBack});

  @override
  State<MoodleTesterScreen> createState() => _MoodleTesterScreenState();
}

class _MoodleTesterScreenState extends State<MoodleTesterScreen> with SingleTickerProviderStateMixin {
  // Datos reales ingresados para la prueba con Moodle Docker
  final _urlController = TextEditingController(text: 'http://192.168.1.121:3000');
  final _tokenController = TextEditingController(text: 'c1f7b6a010723ed65d2b749c3fdd0aac');

  late TabController _tabController;
  bool _isLoading = false;
  String? _connectionStatus;
  bool _isSuccess = false;
  Map<String, dynamic>? _siteData;
  List<MoodleCourse> _moodleCourses = [];
  List<MoodleAssignment> _moodleAssignments = [];
  bool _isLoadingData = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _testAndFetchAll() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = null;
      _errorMessage = null;
      _siteData = null;
      _moodleCourses = [];
      _moodleAssignments = [];
    });

    final result = await MoodleApiService.testConnection(
      baseUrl: _urlController.text,
      token: _tokenController.text,
    );

    setState(() {
      _isLoading = false;
      _isSuccess = result['success'];
      _connectionStatus = result['message'];
      _siteData = result['data'];
    });

    if (_isSuccess) {
      _fetchAllData();
    }
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final courses = await MoodleApiService.getCourses(
        baseUrl: _urlController.text,
        token: _tokenController.text,
      );

      final assignments = await MoodleApiService.getAssignments(
        baseUrl: _urlController.text,
        token: _tokenController.text,
      );

      setState(() {
        _isLoadingData = false;
        _moodleCourses = courses;
        _moodleAssignments = assignments;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 28),
            SizedBox(width: 8),
            Text('Moodle LMS - Conexión REST'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.navyBlue,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.skyBlue,
          tabs: const [
            Tab(text: 'Conexión'),
            Tab(text: 'Cursos'),
            Tab(text: 'Tareas'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Connection & Settings
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Demo Professor Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.skyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.skyBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.skyBlue, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Modo Demostración Moodle 5.3',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 13),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Los datos del servidor local y el token ya están configurados para la prueba del profesor.',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Credenciales Web Service de Moodle',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                        ),
                        const SizedBox(height: 16),
                        const Text('URL del Proxy / Servidor Moodle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.link, color: AppTheme.textMuted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Token de Web Service (wstoken)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _tokenController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.key, color: AppTheme.textMuted),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testAndFetchAll,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.power_settings_new_rounded),
                            label: Text(_isLoading ? 'Conectando con Moodle...' : '⚡ Probar Conexión y Cargar Datos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.skyBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_connectionStatus != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isSuccess ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccess ? AppTheme.successGreen.withOpacity(0.3) : AppTheme.errorRed.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                            color: _isSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _connectionStatus!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_siteData != null) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Información del Sitio Moodle',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        children: [
                          _infoRow('Sitio', _siteData!['sitename'] ?? 'N/A'),
                          const Divider(height: 16),
                          _infoRow('Usuario', _siteData!['username'] ?? 'N/A'),
                          const Divider(height: 16),
                          _infoRow('Nombre', _siteData!['fullname'] ?? 'N/A'),
                          const Divider(height: 16),
                          _infoRow('Versión', _siteData!['release'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Tab 2: Courses from Moodle
            _isLoadingData
                ? const Center(child: CircularProgressIndicator(color: AppTheme.skyBlue))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Error al obtener cursos: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.errorRed),
                          ),
                        ),
                      )
                    : _moodleCourses.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No hay cursos sincronizados.\nPulsa "Probar Conexión y Cargar Datos" en la pestaña Conexión.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _moodleCourses.length,
                            itemBuilder: (context, index) {
                              final course = _moodleCourses[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.fullname,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Clave: ${course.shortname}',
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.skyBlue.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${course.progress}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.skyBlue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

            // Tab 3: Assignments from Moodle
            _isLoadingData
                ? const Center(child: CircularProgressIndicator(color: AppTheme.skyBlue))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Error al obtener tareas: $_errorMessage',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.errorRed),
                          ),
                        ),
                      )
                    : _moodleAssignments.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                'No hay tareas sincronizadas.\nPulsa "Probar Conexión y Cargar Datos" en la pestaña Conexión.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _moodleAssignments.length,
                            itemBuilder: (context, index) {
                              final assign = _moodleAssignments[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.skyBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.assignment, color: AppTheme.skyBlue),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            assign.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            assign.courseName,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: assign.submitted
                                            ? AppTheme.successGreen.withOpacity(0.15)
                                            : AppTheme.warningOrange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        assign.submitted ? 'Entregada' : 'Pendiente',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: assign.submitted ? AppTheme.successGreen : AppTheme.warningOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue, fontSize: 13)),
      ],
    );
  }
}
