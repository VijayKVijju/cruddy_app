class FrequencyMapper {
  static const Map<String, int> _map = {
    "A": 440, "B": 350, "C": 260, "D": 474, "E": 492,
    "F": 401, "G": 584, "H": 553, "I": 582, "J": 525,
    "K": 501, "L": 532, "M": 594, "N": 599, "O": 528,
    "P": 539, "Q": 675, "R": 683, "S": 698, "T": 631,
    "U": 628, "V": 611, "W": 622, "X": 677, "Y": 688, "Z": 693,
    " ": 418
  };

  static const _toleranceHz = 7.5;

  static String charFromFrequency(double f) {
    String best = '?';
    double bestDiff = double.infinity;
    _map.forEach((ch, hz) {
      final d = (f - hz).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = ch;
      }
    });
    return bestDiff <= _toleranceHz ? best : '?';
  }
}
