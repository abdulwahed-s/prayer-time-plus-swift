@testable import PrayerTimePlus
import XCTest

/// Property test: every method equals its own angles computed with zero offsets,
/// shifted by exactly the method's documented per-prayer offsets.
final class RegionalOffsetTests: XCTestCase {
    private let coordinates = Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5)
    private let date = DateComponents(year: 2026, month: 6, day: 28)
    private let offsetSeconds = 3 * 3600

    private func minuteOfDay(_ date: Date?) -> Int? {
        guard let date, let zone = TimeZone(secondsFromGMT: offsetSeconds) else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return hour * 60 + minute
    }

    func testEachMethodIsItsBaselineShiftedByOffsets() {
        let utcOffset = TimeInterval(offsetSeconds)
        for method in CalculationMethod.allCases {
            let params = method.parameters
            var baselineParams = params
            baselineParams.methodAdjustments = PrayerAdjustments()

            let full = PrayerTimes(
                coordinates: coordinates, date: date,
                calculationParameters: params, utcOffset: utcOffset,
            )
            let baseline = PrayerTimes(
                coordinates: coordinates, date: date,
                calculationParameters: baselineParams, utcOffset: utcOffset,
            )

            let adjustments = params.methodAdjustments
            // An interval Isha is built from Maghrib, so it also carries Maghrib's offset.
            let ishaShift = params.ishaIsInterval
                ? adjustments.maghrib + adjustments.isha
                : adjustments.isha
            let expected: [(Prayer, Int)] = [
                (.fajr, adjustments.fajr),
                (.sunrise, adjustments.sunrise),
                (.dhuhr, adjustments.dhuhr),
                (.asr, adjustments.asr),
                (.maghrib, adjustments.maghrib),
                (.isha, ishaShift),
            ]
            for (prayer, shift) in expected {
                guard let base = minuteOfDay(baseline.time(for: prayer)),
                      let actual = minuteOfDay(full.time(for: prayer)) else { continue }
                let target = ((base + shift) % 1440 + 1440) % 1440
                XCTAssertEqual(actual, target, "\(method.key) \(prayer)")
            }
        }
    }
}
