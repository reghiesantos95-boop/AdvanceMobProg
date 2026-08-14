const String host = 'https://dummyjson.com';
const double usdToPhpRate = 56.0;

String formatPesoPrice(double usdPrice) {
  final pesoPrice = usdPrice * usdToPhpRate;
  return 'PHP ${pesoPrice.toStringAsFixed(2)}';
}
