// lib/models/user_models.dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? bio;
  final int currentStreak;
  final int longestStreak;
  final int totalBooksCompleted;
  final int totalChaptersRead;
  final DateTime joinDate;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.bio,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalBooksCompleted = 0,
    this.totalChaptersRead = 0,
    required this.joinDate,
  });

  AppUser copyWith({String? name, String? email, String? bio}) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalBooksCompleted: totalBooksCompleted,
      totalChaptersRead: totalChaptersRead,
      joinDate: joinDate,
    );
  }
}

class UserSettings {
  final bool notifications;
  final String reminderTime;
  final int weeklyGoal;
  final String language;
  final bool darkMode;

  UserSettings({
    this.notifications = true,
    this.reminderTime = '20:00',
    this.weeklyGoal = 5,
    this.language = 'es',
    this.darkMode = false,
  });

  UserSettings copyWith({
    bool? notifications,
    String? reminderTime,
    int? weeklyGoal,
    String? language,
    bool? darkMode,
  }) {
    return UserSettings(
      notifications: notifications ?? this.notifications,
      reminderTime: reminderTime ?? this.reminderTime,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
