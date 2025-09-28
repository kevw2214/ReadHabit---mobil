// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_models.dart';

enum ProfileView { main, editProfile, settings }

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final UserSettings settings;
  final Function(AppUser) onUpdateUser;
  final Function(UserSettings) onUpdateSettings;
  final VoidCallback onLogout;
  final Function(String) onNavigate;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.settings,
    required this.onUpdateUser,
    required this.onUpdateSettings,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileView _currentView;
  late AppUser _editedUser;
  late UserSettings _editedSettings;

  @override
  void initState() {
    super.initState();
    _currentView = ProfileView.main;
    _resetEditedData();
  }

  void _resetEditedData() {
    _editedUser = widget.user;
    _editedSettings = widget.settings;
  }

  void _handleSaveProfile() {
    widget.onUpdateUser(_editedUser);
    setState(() {
      _currentView = ProfileView.main;
    });
  }

  void _handleSaveSettings() {
    widget.onUpdateSettings(_editedSettings);
    setState(() {
      _currentView = ProfileView.main;
    });
  }

  void _handleCancelEdit() {
    _resetEditedData();
    setState(() {
      _currentView = ProfileView.main;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentView) {
      case ProfileView.editProfile:
        return _buildEditProfileView();
      case ProfileView.settings:
        return _buildSettingsView();
      case ProfileView.main:
      default:
        return _buildMainView();
    }
  }

  Widget _buildMainView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 16),

            // Stats Summary
            _buildStatsSummary(),
            const SizedBox(height: 16),

            // Quick Settings
            _buildQuickSettings(),
            const SizedBox(height: 16),

            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.user.bio != null &&
                          widget.user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            widget.user.bio!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentView = ProfileView.editProfile;
                    });
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildProfileInfoRow(Icons.email, widget.user.email),
                const SizedBox(height: 8),
                _buildProfileInfoRow(
                  Icons.calendar_today,
                  'Miembro desde ${_formatDate(widget.user.joinDate)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  widget.user.currentStreak.toString(),
                  'Racha actual',
                ),
                _buildStatCard(
                  widget.user.longestStreak.toString(),
                  'Mejor racha',
                ),
                _buildStatCard(
                  widget.user.totalBooksCompleted.toString(),
                  'Libros terminados',
                ),
                _buildStatCard(
                  widget.user.totalChaptersRead.toString(),
                  'Capítulos leídos',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E90FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración rápida',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildQuickSettingRow(
                  Icons.notifications,
                  'Notificaciones',
                  trailing: Switch(
                    value: widget.settings.notifications,
                    onChanged: null, // Disabled in quick view
                  ),
                ),
                const SizedBox(height: 8),
                _buildQuickSettingRow(
                  Icons.access_time,
                  'Recordatorio: ${widget.settings.reminderTime}',
                ),
                const SizedBox(height: 8),
                _buildQuickSettingRow(
                  Icons.flag,
                  'Meta: ${widget.settings.weeklyGoal} días/semana',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingRow(IconData icon, String text, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentView = ProfileView.settings;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.settings, size: 16),
              SizedBox(width: 8),
              Text('Configuración completa'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade300),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('Cerrar sesión'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileView() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleCancelEdit,
        ),
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto de perfil',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Pronto podrás cambiar tu avatar',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Personal Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        _buildFormField(
                          'Nombre',
                          _editedUser.name,
                          (value) => setState(() {
                            _editedUser = _editedUser.copyWith(name: value);
                          }),
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          'Correo electrónico',
                          _editedUser.email,
                          (value) => setState(() {
                            _editedUser = _editedUser.copyWith(email: value);
                          }),
                          isEmail: true,
                        ),
                        const SizedBox(height: 16),
                        _buildBioField(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSaveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E90FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 16),
                        SizedBox(width: 8),
                        Text('Guardar'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleCancelEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 16),
                        SizedBox(width: 8),
                        Text('Cancelar'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    String value,
    Function(String) onChanged, {
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biografía',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: _editedUser.bio,
          onChanged: (value) => setState(() {
            _editedUser = _editedUser.copyWith(bio: value);
          }),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Cuéntanos un poco sobre ti...',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E90FF), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsView() {
    final reminderTimes = [
      '07:00',
      '08:00',
      '09:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
    ];
    final weeklyGoals = [3, 4, 5, 6, 7];
    final languages = [
      {'value': 'es', 'label': 'Español'},
      {'value': 'en', 'label': 'English'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleCancelEdit,
        ),
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notifications
            _buildSettingsSection(Icons.notifications, 'Notificaciones', [
              _buildSwitchSetting(
                'Recordatorios de lectura',
                'Recibe notificaciones diarias',
                _editedSettings.notifications,
                (value) => setState(() {
                  _editedSettings = _editedSettings.copyWith(
                    notifications: value,
                  );
                }),
              ),
            ]),
            const SizedBox(height: 16),

            // Reminder Time
            _buildSettingsSection(Icons.access_time, 'Hora de recordatorio', [
              DropdownButtonFormField<String>(
                value: _editedSettings.reminderTime,
                onChanged: (value) => setState(() {
                  _editedSettings = _editedSettings.copyWith(
                    reminderTime: value!,
                  );
                }),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: reminderTimes.map((time) {
                  return DropdownMenuItem(
                    value: time,
                    child: Text(
                      '$time ${int.parse(time.split(':')[0]) < 12 ? 'AM' : 'PM'}',
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // Weekly Goal
            _buildSettingsSection(Icons.flag, 'Meta semanal', [
              const Text(
                'Días de lectura por semana',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _editedSettings.weeklyGoal,
                onChanged: (value) => setState(() {
                  _editedSettings = _editedSettings.copyWith(
                    weeklyGoal: value!,
                  );
                }),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: weeklyGoals.map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days días'),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // Language
            _buildSettingsSection(Icons.language, 'Idioma', [
              DropdownButtonFormField<String>(
                value: _editedSettings.language,
                onChanged: (value) => setState(() {
                  _editedSettings = _editedSettings.copyWith(language: value!);
                }),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang['value'],
                    child: Text(lang['label']!),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 16),

            // Theme
            _buildSettingsSection(Icons.dark_mode, 'Tema', [
              _buildSwitchSetting(
                'Modo oscuro',
                'Cambiar tema de la aplicación',
                _editedSettings.darkMode,
                (value) => setState(() {
                  _editedSettings = _editedSettings.copyWith(darkMode: value);
                }),
              ),
            ]),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _handleSaveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E90FF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 16),
                  SizedBox(width: 8),
                  Text('Guardar configuración'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    IconData icon,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
