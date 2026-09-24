import 'package:flutter_test/flutter_test.dart';
import 'package:cortify/theme/app_theme.dart';

void main() {
  test('Cortify brand colors are defined', () {
    expect(CortifyColors.coral.toARGB32(), isNonZero);
    expect(CortifyColors.cream.toARGB32(), isNonZero);
    expect(CortifyColors.charcoal.toARGB32(), isNonZero);
  });
}
