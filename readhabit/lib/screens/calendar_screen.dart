// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/reading_provider.dart';
import '../models/user_book.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _monthController;
  final Map<String, List<UserBook>> _dailyReadings = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _monthController = PageController(initialPage: _getInitialPage());
    _loadReadingHistory();
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

  void _loadReadingHistory() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final readingProvider = context.read<ReadingProvider>();
      // Cargar datos reales de lectura desde ReadingProvider o Firestore
      // Por ahora, simular algunos días con lectura
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final dateKey = _formatDateKey(date);
        if (readingProvider.booksInProgress.isNotEmpty && i % 2 == 0) {
          _dailyReadings[dateKey] = [readingProvider.booksInProgress.first];
        }
      }
    }
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

  bool _hasReading(DateTime date) {
    return _dailyReadings.containsKey(_formatDateKey(date));
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu Progreso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Racha actual: ${readingProvider.currentStreak} días',
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                  ),
                ],
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
                    '${_dailyReadings.length} días de lectura',
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
        final hasReading = _hasReading(day);
        final isToday = _isToday(day);
        final isSelected = _isSelected(day);

        return GestureDetector(
          onTap: () => _onDaySelected(day),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.shade100
                  : isToday
                  ? Colors.orange.shade50
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: Colors.orange.shade300, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDay(day),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isCurrentMonth
                        ? (isToday ? Colors.orange.shade800 : Colors.black87)
                        : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                if (hasReading)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                    ),
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

    final dateKey = _formatDateKey(_selectedDay!);
    final readings = _dailyReadings[dateKey] ?? [];
    final isToday = _isToday(_selectedDay!);

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
              Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, d MMMM y', 'es').format(_selectedDay!),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Hoy',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (readings.isEmpty)
            Text(
              isToday ? 'Aún no has leído hoy' : 'No hay registro de lectura',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            Text(
              'Libros leídos:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...readings.map((userBook) => _buildBookItem(userBook)),
          ],
          if (isToday) ...[
            const SizedBox(height: 16),
            Consumer<ReadingProvider>(
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
                  return ElevatedButton(
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      readingProvider.markDailyReading(authProvider.user!.uid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Marcar lectura de hoy'),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookItem(UserBook userBook) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userBook.book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userBook.book.author,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Cap. ${userBook.currentChapter + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendario',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Tu calendario de lectura',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
