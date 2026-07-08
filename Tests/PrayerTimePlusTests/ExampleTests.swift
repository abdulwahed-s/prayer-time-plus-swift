import Foundation
import PrayerTimePlus
import XCTest

/// Verifies the documented examples compile against the public API and stay correct.
final class ExampleTests: XCTestCase {
    func testReadmeQuickStart() {
        let times = PrayerTimes(
            coordinates: Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5),
            date: DateComponents(year: 2026, month: 6, day: 28),
            calculationParameters: CalculationMethod.oman.parameters,
            utcOffset: 4 * 3600,
            countryCode: "OM",
            cityName: "sohar",
        )

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 4 * 3600)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let rendered = Prayer.allCases.map { prayer in
            times.time(for: prayer).map { formatter.string(from: $0) } ?? "--:--"
        }
        XCTAssertEqual(rendered, ["03:59", "05:27", "12:21", "15:42", "19:10", "20:35"])
    }

    func testAutoResolutionExample() {
        XCTAssertEqual(AutoMethod.forCountry("OM"), .oman)
        XCTAssertEqual(AutoMethod.forCountry("SA"), .ummAlQura)
        XCTAssertEqual(AutoMethod.forCountry("fr"), .uoif)
    }

    func testCustomParametersExample() {
        var params = CalculationMethod.oman.parameters
        params.madhab = .hanafi
        params.highLatitudeRule = .seventhOfTheNight
        params.adjustments.fajr = 2
        XCTAssertEqual(params.madhab, .hanafi)
        XCTAssertEqual(params.adjustments.fajr, 2)
    }
}
