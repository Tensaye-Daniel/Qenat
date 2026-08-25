enum QenatCategory {
  work,
  health,
  personal,
  learning;

  String get label => switch (this) {
        work => 'Work',
        health => 'Health',
        personal => 'Personal',
        learning => 'Learning',
      };

  String get code => name;

  static QenatCategory? fromCode(String? code) {
    if (code == null) return null;
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }
}
