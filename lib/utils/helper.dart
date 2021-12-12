class Helper {
  static String getTimerString(int sec) {
    return '${((sec) ~/ 60).toString().padLeft(2, '0')}: ${((sec) % 60).toString().padLeft(2, '0')}';
  }
}
