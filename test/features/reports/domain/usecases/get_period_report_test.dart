import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/reports/domain/entities/report_entities.dart';
import '../../../../../lib/features/reports/domain/usecases/get_period_report.dart';

void main() {
  group('GetPeriodReportParams', () {
    test('should calculate correct week dates', () {
      // Act
      final params = GetPeriodReportParams(period: ReportPeriod.week);

      // Assert
      expect(params.endDate.difference(params.startDate).inDays, lessThanOrEqualTo(7));
    });

    test('should calculate correct month dates', () {
      // Act
      final params = GetPeriodReportParams(period: ReportPeriod.month);

      // Assert
      expect(params.startDate.day, 1); // Should start on 1st of month
      expect(params.endDate.month, params.startDate.month);
    });

    test('should calculate correct year dates', () {
      // Act
      final params = GetPeriodReportParams(period: ReportPeriod.year);

      // Assert
      expect(params.startDate.month, 1); // Should start in January
      expect(params.startDate.day, 1); // Should start on 1st
      expect(params.endDate.month, 12); // Should end in December
      expect(params.endDate.day, 31); // Should end on 31st
    });

    test('should use custom dates when period is custom', () {
      // Arrange
      final customStart = DateTime(2024, 1, 15);
      final customEnd = DateTime(2024, 1, 25);

      // Act
      final params = GetPeriodReportParams(
        period: ReportPeriod.custom,
        customStartDate: customStart,
        customEndDate: customEnd,
      );

      // Assert
      expect(params.startDate, customStart);
      expect(params.endDate, customEnd);
    });

    test('should use default dates when custom dates are null', () {
      // Act
      final params = GetPeriodReportParams(
        period: ReportPeriod.custom,
        customStartDate: null,
        customEndDate: null,
      );

      // Assert
      expect(params.startDate, isNotNull);
      expect(params.endDate, isNotNull);
      expect(params.endDate.isAfter(params.startDate), true);
    });
  });
}