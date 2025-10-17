import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_book.dart';
import '../../providers/user_library_provider.dart';
import '../../providers/auth_provider.dart';

class ReadingPlanScreen extends StatefulWidget {
  final UserBook userBook;

  const ReadingPlanScreen({super.key, required this.userBook});

  @override
  State<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends State<ReadingPlanScreen> {
  late int _selectedPlan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.userBook.readingPlan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurar Plan de Lectura', style: TextStyle(fontSize: 16)),
            Text(
              'Personaliza tu experiencia de lectura',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: widget.userBook.book.coverUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.userBook.book.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.book),
                            ),
                          )
                        : const Icon(Icons.book),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userBook.book.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.userBook.book.author,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.userBook.book.category} • ${widget.userBook.totalChapters} capítulos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración del Libro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Número total de capítulos'),
                      Text(
                        widget.userBook.totalChapters.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Capítulos por día de lectura'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _selectedPlan.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _selectedPlan.toString(),
                          activeColor: const Color(0xFF1E90FF),
                          onChanged: (value) {
                            setState(() {
                              _selectedPlan = value.round();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_selectedPlan',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E90FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Cuántos capítulos leerás cada día para mantener tu racha',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Horario de Lectura',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Estimación de tiempo según tu plan:',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeInfo(
                        icon: Icons.timer,
                        value: '${_calculateDaysToFinish()} días',
                        label: 'Para terminar',
                      ),
                      _buildTimeInfo(
                        icon: Icons.auto_stories,
                        value: '${(_selectedPlan * 10)} min',
                        label: 'Lectura diaria',
                      ),
                      _buildTimeInfo(
                        icon: Icons.calendar_today,
                        value: '${_calculateWeeksToFinish()} sem',
                        label: 'Duración aprox.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePlan,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Guardar Plan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E90FF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1E90FF), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _calculateDaysToFinish() {
    final remainingChapters = widget.userBook.remainingChapters;
    return remainingChapters > 0
        ? (remainingChapters / _selectedPlan).ceil()
        : 0;
  }

  int _calculateWeeksToFinish() {
    return (_calculateDaysToFinish() / 7).ceil();
  }

  void _savePlan() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final libraryProvider = Provider.of<UserLibraryProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      final success = await libraryProvider.updateReadingPlan(
        userBookId: widget.userBook.id,
        chaptersPerDay: _selectedPlan,
        userId: authProvider.user!.uid,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan de lectura actualizado'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                libraryProvider.errorMessage ?? 'Error al actualizar plan',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
