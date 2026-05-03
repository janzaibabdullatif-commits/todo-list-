class DateHelper {

  static String getTaskLabel(DateTime taskDate) {
    final now = DateTime.now();

    if (_isSameDay(taskDate, now)) {
      return "Today";
    }

    if (_isTomorrow(taskDate, now)) {
      return "Tomorrow";
    }

    return _getWeekday(taskDate.weekday);
  }

  static bool isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  static bool _isTomorrow(DateTime date, DateTime now) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return _isSameDay(date, tomorrow);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static String _getWeekday(int day) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[day - 1];
  }
}