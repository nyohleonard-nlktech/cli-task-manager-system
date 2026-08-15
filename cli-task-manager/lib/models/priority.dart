/// Task priority. Declared in ascending urgency order so its
/// [Enum.index] can be used directly as a sort key (high = 2, low = 0).
enum Priority {
  low,
  medium,
  high;

  static Priority fromString(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'low':
        return Priority.low;
      case 'medium':
      case 'med':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        throw ArgumentError('Unknown priority "$raw". Use low, medium, or high.');
    }
  }
}
