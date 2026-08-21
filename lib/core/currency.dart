/// Mirrors lib/currency.ts's CURRENCIES/currencySymbol on the web app —
/// keep these two lists in sync if a currency is ever added there.
const Map<String, String> _currencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'PKR': '₨',
  'MYR': 'RM',
  'SGD': 'S\$',
  'AUD': 'A\$',
  'CAD': 'C\$',
};

String currencySymbol(String code) => _currencySymbols[code] ?? '\$';

/// Mirrors lib/rewardBands.ts's formatDiscount.
String formatDiscount(String discountType, num? discountValue, String currency) {
  switch (discountType) {
    case 'percent':
      return '$discountValue% off';
    case 'fixed':
      return '${currencySymbol(currency)}$discountValue off';
    case 'free_item':
      return 'Free item';
    default:
      return '';
  }
}
