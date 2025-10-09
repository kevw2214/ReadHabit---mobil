// lib/screens/calendar_screen.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/reading_provider.dart';
import '../providers/user_library_provider.dart';
import '../models/user_models.dart';
import '../models/user_book.dart';
import '../models/book.dart';

// Enum para los estados de lectura
enum ReadingStatus {
  read, // Leí - verde
  notRead, // No leí - rojo (solo días pasados)
  paused, // En pausa - naranja
  today, // Hoy - azul
  future, // Futuro - gris neutral
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _monthController;
  final Map<String, ReadingStatus> _dailyStatus = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _monthController = PageController(initialPage: _getInitialPage());
    _loadReadingStatus();
  }

  @override
  void dispose() {
    _monthController.dispose();
    super.dispose();
  }

  int _getInitialPage() {
    final now = DateTime.now();
    return (now.year - 2020) * 12 + now.month - 1;
  }

  void _loadReadingStatus() {
    final today = DateTime.now();

    // Solo cargar estados para días pasados y hoy
    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);

      // Asignar estados de ejemplo solo para días pasados
      if (i == 0) {
        _dailyStatus[dateKey] = ReadingStatus.today; // Hoy
      } else if (i % 3 == 0) {
        _dailyStatus[dateKey] = ReadingStatus.read; // Leí
      } else if (i % 5 == 0) {
        _dailyStatus[dateKey] = ReadingStatus.paused; // En pausa
      } else {
        _dailyStatus[dateKey] =
            ReadingStatus.notRead; // No leí (solo días pasados)
      }
    }

    // Los días futuros no se cargan en _dailyStatus, por defecto serán "future"
  }

  String _formatDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatMonthYear(DateTime date) {
    return DateFormat('MMMM y', 'es').format(date);
  }

  String _formatDay(DateTime date) {
    return DateFormat('d').format(date);
  }

  String _formatWeekday(DateTime date) {
    return DateFormat('E', 'es').format(date).substring(0, 1).toUpperCase();
  }

  ReadingStatus _getDayStatus(DateTime date) {
    final dateKey = _formatDateKey(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(date.year, date.month, date.day);

    // Si es un día futuro, retornar estado "future"
    if (currentDate.isAfter(today)) {
      return ReadingStatus.future;
    }

    // Si no está en el mapa, es un día pasado sin registro = "notRead"
    return _dailyStatus[dateKey] ?? ReadingStatus.notRead;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return _selectedDay != null &&
        date.year == _selectedDay!.year &&
        date.month == _selectedDay!.month &&
        date.day == _selectedDay!.day;
  }

  bool _isPastDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(date.year, date.month, date.day);
    return currentDate.isBefore(today);
  }

  bool _isFutureDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = DateTime(date.year, date.month, date.day);
    return currentDate.isAfter(today);
  }

  Color _getStatusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.read:
        return Colors.green.shade500;
      case ReadingStatus.notRead:
        return Colors.red.shade400;
      case ReadingStatus.paused:
        return Colors.orange.shade500;
      case ReadingStatus.today:
        return Colors.blue.shade500;
      case ReadingStatus.future:
        return Colors.grey.shade400;
    }
  }

  Color _getStatusBackgroundColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.read:
        return Colors.green.shade50;
      case ReadingStatus.notRead:
        return Colors.red.shade50;
      case ReadingStatus.paused:
        return Colors.orange.shade50;
      case ReadingStatus.today:
        return Colors.blue.shade50;
      case ReadingStatus.future:
        return Colors.transparent;
    }
  }

  String _getStatusText(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.read:
        return 'Leí';
      case ReadingStatus.notRead:
        return 'No leí';
      case ReadingStatus.paused:
        return 'En pausa';
      case ReadingStatus.today:
        return 'Hoy';
      case ReadingStatus.future:
        return 'Próximo';
    }
  }

  IconData _getStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.read:
        return Icons.check_circle;
      case ReadingStatus.notRead:
        return Icons.cancel;
      case ReadingStatus.paused:
        return Icons.pause_circle;
      case ReadingStatus.today:
        return Icons.today;
      case ReadingStatus.future:
        return Icons.schedule;
    }
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    // Agregar días del mes anterior para completar la primera semana
    final firstWeekday = firstDay.weekday;
    for (int i = firstWeekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Agregar días del mes actual
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i + 1));
    }

    // Agregar días del próximo mes para completar la última semana
    final totalCells = ((days.length + 6) ~/ 7) * 7;
    while (days.length < totalCells) {
      days.add(days.last.add(const Duration(days: 1)));
    }

    return days;
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  void _onPageChanged(int page) {
    final year = 2020 + (page ~/ 12);
    final month = (page % 12) + 1;
    setState(() {
      _focusedDay = DateTime(year, month, 1);
    });
  }

  void _previousMonth() {
    _monthController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextMonth() {
    _monthController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Consumer<ReadingProvider>(
        builder: (context, readingProvider, child) {
          final readDays = _dailyStatus.values
              .where((status) => status == ReadingStatus.read)
              .length;
          final pausedDays = _dailyStatus.values
              .where((status) => status == ReadingStatus.paused)
              .length;
          final notReadDays = _dailyStatus.values
              .where((status) => status == ReadingStatus.notRead)
              .length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu Progreso Mensual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$readDays leídos • $notReadDays sin leer • $pausedDays en pausa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      readingProvider.currentStreak.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
          Consumer<ReadingProvider>(
            builder: (context, readingProvider, child) {
              final readDays = _dailyStatus.values
                  .where((status) => status == ReadingStatus.read)
                  .length;

              return Column(
                children: [
                  Text(
                    _formatMonthYear(_focusedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$readDays días de lectura',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(DateTime month) {
    final days = _getDaysInMonth(month);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == month.month;
        final status = _getDayStatus(day);
        final isToday = _isToday(day);
        final isSelected = _isSelected(day);
        final isFuture = _isFutureDay(day);

        return GestureDetector(
          onTap: () => _onDaySelected(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? _getStatusBackgroundColor(status).withOpacity(0.7)
                  : _getStatusBackgroundColor(status),
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: _getStatusColor(status), width: 2)
                  : Border.all(color: Colors.transparent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDay(day),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isCurrentMonth
                        ? (isToday
                              ? _getStatusColor(status)
                              : (isFuture
                                    ? Colors.grey.shade400
                                    : Colors.black87))
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                if (status !=
                    ReadingStatus.future) // No mostrar icono en días futuros
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 12,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) return const SizedBox();

    final status = _getDayStatus(_selectedDay!);
    final isToday = _isToday(_selectedDay!);
    final isFuture = _isFutureDay(_selectedDay!);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMMM y', 'es').format(_selectedDay!),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusBackgroundColor(status),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(status).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(status), color: _getStatusColor(status)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado: ${_getStatusText(status)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                      Text(
                        _getStatusDescription(status),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (isToday && !isFuture) _buildTodayActions(),
          if (isFuture) _buildFutureDayMessage(),
        ],
      ),
    );
  }

  String _getStatusDescription(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.read:
        return 'Completaste tu lectura este día';
      case ReadingStatus.notRead:
        return 'No registraste lectura este día';
      case ReadingStatus.paused:
        return 'Usaste tu pausa semanal este día';
      case ReadingStatus.today:
        return 'Hoy - ¡Continúa tu racha!';
      case ReadingStatus.future:
        return 'Día futuro - ¡Prepárate para leer!';
    }
  }

  Widget _buildTodayActions() {
    return Consumer<ReadingProvider>(
      builder: (context, readingProvider, child) {
        if (readingProvider.hasCompletedToday) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '¡Ya completaste tu lectura de hoy!',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  readingProvider.markDailyReading();
                  setState(() {
                    _dailyStatus[_formatDateKey(DateTime.now())] =
                        ReadingStatus.read;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text('Marcar como "Leí"'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: readingProvider.hasWeeklyPauseAvailable
                    ? () {
                        readingProvider.useWeeklyPause();
                        setState(() {
                          _dailyStatus[_formatDateKey(DateTime.now())] =
                              ReadingStatus.paused;
                        });
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade600,
                  side: BorderSide(color: Colors.orange.shade600),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pause_circle, size: 20),
                    SizedBox(width: 8),
                    Text('Usar Pausa Semanal'),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildFutureDayMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Este día aún no ha llegado. ¡Prepárate para mantener tu racha!',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    // Solo mostrar leyenda para estados activos, no para "future"
    final activeStatuses = ReadingStatus.values
        .where((status) => status != ReadingStatus.future)
        .toList();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leyenda:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: activeStatuses.map((status) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Lectura'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarHeader(),
              const SizedBox(height: 20),
              _buildMonthNavigation(),
              _buildWeekdaysHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _monthController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, page) {
                    final year = 2020 + (page ~/ 12);
                    final month = (page % 12) + 1;
                    final currentMonth = DateTime(year, month, 1);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildCalendarGrid(currentMonth),
                                _buildSelectedDayDetails(),
                                _buildLegend(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
