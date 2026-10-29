import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../widgets/app_logo.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String _selectedStatusFilter = 'Todas';

  void _showUploadDialog(Activity act) {
    final fileController = TextEditingController(text: 'documento_entrega.pdf');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Entregar: ${act.title}', style: const TextStyle(color: AppTheme.navyBlue, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sube tu archivo para esta actividad:', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: fileController,
              decoration: const InputDecoration(
                labelText: 'Archivo seleccionado',
                prefixIcon: Icon(Icons.insert_drive_file, color: AppTheme.skyBlue),
              ),
            ),
            const SizedBox(height: 12),
            const Text('💡 Formatos aceptados: PDF, DOCX, ZIP (Máx. 25MB)', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                act.status = 'entregada';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('¡Archivo subido y tarea entregada con éxito!'), backgroundColor: AppTheme.successGreen),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Subir y Entregar'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.skyBlue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = MockData.allActivities.where((act) {
      if (_selectedStatusFilter == 'Todas') return true;
      if (_selectedStatusFilter == 'Pendientes') return act.status == 'pendiente';
      if (_selectedStatusFilter == 'Entregadas') return act.status == 'entregada';
      if (_selectedStatusFilter == 'Vencidas') return act.status == 'vencida';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 28),
            SizedBox(width: 8),
            Text('Actividades Académicas'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todas', 'Pendientes', 'Entregadas', 'Vencidas'].map((filter) {
                    final isSelected = _selectedStatusFilter == filter;
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
                            _selectedStatusFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List of activities
            Expanded(
              child: filteredActivities.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay actividades en esta categoría.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final act = filteredActivities[index];
                        Color statusColor = AppTheme.skyBlue;
                        if (act.status == 'pendiente') statusColor = AppTheme.warningOrange;
                        if (act.status == 'entregada') statusColor = AppTheme.successGreen;
                        if (act.status == 'vencida') statusColor = AppTheme.errorRed;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.skyBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      act.type.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.skyBlue,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      act.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                act.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                act.courseName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: AppTheme.borderColor),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Fecha límite: ${act.dueDate}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (act.status == 'pendiente')
                                    ElevatedButton.icon(
                                      onPressed: () => _showUploadDialog(act),
                                      icon: const Icon(Icons.upload_file, size: 14),
                                      label: const Text('Entregar', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.skyBlue,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        minimumSize: Size.zero,
                                      ),
                                    ),
                                ],
                              ),
                            ],
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
