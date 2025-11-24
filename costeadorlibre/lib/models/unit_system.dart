// lib/models/unit_system.dart

enum MeasurementUnit {
  kilograms('kg', 'Kilogramos', UnitType.weight, 1000),
  grams('gr', 'Gramos', UnitType.weight, 1),
  liters('L', 'Litros', UnitType.volume, 1000),
  milliliters('ml', 'Mililitros', UnitType.volume, 1),
  meters('m', 'Metros', UnitType.length, 100),
  centimeters('cm', 'Centímetros', UnitType.length, 1),
  units('u', 'Unidades', UnitType.count, 1);

  final String symbol;
  final String displayName;
  final UnitType type;
  final double baseMultiplier;

  const MeasurementUnit(this.symbol, this.displayName, this.type, this.baseMultiplier);

  double toBaseUnit(double value) {
    return value * baseMultiplier;
  }

  double fromBaseUnit(double baseValue) {
    return baseValue / baseMultiplier;
  }

  static double convert(double value, MeasurementUnit from, MeasurementUnit to) {
    if (from.type != to.type) {
      throw Exception('No se pueden convertir unidades de diferentes tipos');
    }
    final baseValue = from.toBaseUnit(value);
    return to.fromBaseUnit(baseValue);
  }

  static MeasurementUnit fromString(String symbol) {
    return MeasurementUnit.values.firstWhere(
      (u) => u.symbol == symbol,
      orElse: () => MeasurementUnit.units,
    );
  }
}

enum UnitType {
  weight,
  volume,
  length,
  count,
}