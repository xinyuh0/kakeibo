String formatNumber(int number) {
  if (number >= 1000 && number < 1000000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  } else if (number >= 1000000 && number < 1000000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000000000) {
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  } else {
    return number.toString();
  }
}

String formatNumberWithCommas(int number) {
  final String numberString = number.toString();
  final int length = numberString.length;

  if (length <= 3) {
    return numberString; // No need to add commas for numbers with 3 or fewer digits
  }

  String formatted = '';
  int count = 0;

  for (int i = length - 1; i >= 0; i--) {
    formatted = numberString[i] + formatted;
    count++;

    if (count == 3 && i > 0) {
      formatted = ',$formatted';
      count = 0;
    }
  }

  return formatted;
}
