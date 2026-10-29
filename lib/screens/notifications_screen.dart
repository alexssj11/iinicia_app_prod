import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/app_logo.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final unreadCount = MockData.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 28),
            const SizedBox(width: 8),
            const Text('Notificaciones'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in MockData.notifications) {
                    n.isRead = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas marcadas como leídas')),
                );
              },
              child: const Text(
                'Marcar leídas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.skyBlue,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: MockData.notifications.isEmpty
            ? const Center(
                child: Text(
                  'No tienes notificaciones.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: MockData.notifications.length,
                itemBuilder: (context, index) {
                  final notif = MockData.notifications[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        notif.isRead = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : AppTheme.skyBlue.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notif.isRead ? AppTheme.borderColor : AppTheme.skyBlue.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: notif.isRead ? AppTheme.textMuted.withOpacity(0.1) : AppTheme.skyBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getNotificationIcon(notif.type),
                              color: notif.isRead ? AppTheme.textMuted : AppTheme.skyBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.skyBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif.time,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'tarea':
        return Icons.assignment_outlined;
      case 'calificacion':
        return Icons.star_outline_rounded;
      case 'examen':
        return Icons.alarm_rounded;
      case 'inscripcion':
        return Icons.school_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
