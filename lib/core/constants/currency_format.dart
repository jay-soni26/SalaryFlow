import 'package:intl/intl.dart';

class CurrencyFormat {
  static final NumberFormat _inCurrency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inCurrencyCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return _inCurrency.format(amount);
    }
    return _inCurrencyCompact.format(amount);
  }

  static String formatWithSign(double amount, {bool isExpense = false}) {
    final formatted = format(amount.abs());
    if (isExpense) {
      return '-$formatted';
    } else if (amount > 0) {
      return '+$formatted';
    }
    return formatted;
  }
}

