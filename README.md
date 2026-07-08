# PrayerTimePlus

[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fabdulwahed-s%2Fprayer-time-plus-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/abdulwahed-s/prayer-time-plus-swift)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fabdulwahed-s%2Fprayer-time-plus-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/abdulwahed-s/prayer-time-plus-swift)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A native, dependency-free Swift package for computing Islamic prayer times. It
pairs Adhan-style ergonomics with a specific reference engine's angles, per-prayer
offsets and country-based "Auto" resolution — matching that engine to the minute.

> **Also available for [Dart / Flutter](https://github.com/abdulwahed-s/prayer_time_plus)
> and [Kotlin / JVM](https://github.com/abdulwahed-s/prayer-time-plus-kotlin).** All three
> are faithful ports of the same solar engine and compute identical times to the minute.
> See [Other platforms](#other-platforms).

- **Zero third-party dependencies** — Swift standard library and Foundation only.
- **Deterministic** — the timezone enters as a caller-supplied offset; there is
  no timezone database and no network.
- **Customizable** — every angle, interval, offset, madhab and high-latitude rule
  is overridable.

## Requirements

- Swift 6.3+
- macOS 10.15+, iOS 13+, tvOS 13+, watchOS 6+ (and Linux, Foundation only)

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/abdulwahed-s/prayer-time-plus-swift.git", from: "0.1.0"),
]
```

Then add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "PrayerTimePlus", package: "prayer-time-plus-swift"),
    ]
)
```

## Quick start

```swift
import PrayerTimePlus

let times = PrayerTimes(
    coordinates: Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5),
    date: DateComponents(year: 2026, month: 6, day: 28),
    calculationParameters: CalculationMethod.oman.parameters,
    utcOffset: 4 * 3600,          // seconds east of UTC (include DST yourself)
    countryCode: "OM",
    cityName: "sohar"
)

let formatter = DateFormatter()
formatter.dateFormat = "HH:mm"
formatter.timeZone = TimeZone(secondsFromGMT: 4 * 3600)

for prayer in Prayer.allCases {
    let value = times.time(for: prayer).map { formatter.string(from: $0) } ?? "--:--"
    print("\(prayer): \(value)")
}
// fajr: 03:59, sunrise: 05:27, dhuhr: 12:21, asr: 15:42, maghrib: 19:10, isha: 20:35
```

Each returned value is a true UTC `Date` (or `nil` when the sun never reaches the
required angle). Format it with a `DateFormatter` whose `timeZone` you set — the
instant itself carries no wall-clock zone.

## Initialization

| Parameter | Type | Description |
|---|---|---|
| `coordinates` | `Coordinates` | Latitude, longitude (east-positive) and altitude. |
| `date` | `DateComponents` | Only year, month and day are used. |
| `calculationParameters` | `CalculationParameters` | Angles, offsets, madhab, high-latitude rule. |
| `utcOffset` | `TimeInterval` | Seconds east of UTC, including any DST. |
| `countryCode` | `String` | ISO-3166 alpha-2, for the elevation and Ramadan rules. |
| `cityName` | `String` | Retained for reference. |

Use `PrayerTimes.today(...)` to compute for the current calendar day at a given
offset.

## Calculation methods

Obtain a preset from `CalculationMethod` and read `.parameters`:

```swift
let params = CalculationMethod.muslimWorldLeague.parameters
```

| Method | Fajr | Isha |
|---|---|---|
| `.muslimWorldLeague` | 18° | 17° |
| `.egyptian` | 19.5° | 17.5° |
| `.karachi` | 18° | 18° |
| `.ummAlQura` | 18.5° | Maghrib + 90 min (120 in Ramadan) |
| `.northAmerica` | 15° | 15° |
| `.emirates`, `.qatar`, `.kuwait`, `.oman`, `.turkey`, … | regional | regional |

See [Documentation/CalculationMethods.md](Documentation/CalculationMethods.md)
for the full table, or enumerate `CalculationMethod.allCases`. Build a fully
custom method with `.other`.

## Madhab

| Madhab | Asr shadow factor |
|---|---|
| `.shafi` | 1 (Shāfiʿī / Mālikī / Ḥanbalī) |
| `.hanafi` | 2 (Ḥanafī) |

```swift
var params = CalculationMethod.karachi.parameters
params.madhab = .hanafi
```

## High-latitude rule

| Rule | Behaviour |
|---|---|
| `.automatic` | Natural times, retried once with one-seventh if Fajr/Isha degenerate. Default. |
| `.unadjusted` | No fallback; Fajr/Isha may be `nil` near the poles. |
| `.middleOfTheNight` | Pins Fajr/Isha to the middle of the night. |
| `.seventhOfTheNight` | Pins Fajr/Isha within one-seventh of the night. |
| `.twilightAngle` | Pins Fajr/Isha to a fraction of the night from their angle. |

## Auto resolution

Resolve a method from a country code:

```swift
AutoMethod.forCountry("OM")   // .oman
AutoMethod.forCountry("SA")   // .ummAlQura
AutoMethod.forCountry("fr")   // .uoif  (case-insensitive)
```

## Sunnah times

```swift
let sunnah = SunnahTimes(from: times)
sunnah.middleOfTheNight      // Date?
sunnah.lastThirdOfTheNight   // Date?
```

## Custom offsets

```swift
var params = CalculationMethod.oman.parameters
params.madhab = .hanafi
params.highLatitudeRule = .seventhOfTheNight
params.adjustments.fajr = 2        // add 2 minutes to Fajr
params.isRamadan = true            // Umm al-Qura +30 Isha (in SA)
```

The current and next prayer are available directly:

```swift
times.currentPrayer()   // Prayer?
times.nextPrayer()      // Prayer?
```

## Dates and time zones

Julian day is computed from the calendar date only. The caller supplies
`utcOffset` in seconds (fold in DST yourself); the package has no timezone
database. Each returned `Date` is the true UTC instant — display it with a
`DateFormatter` whose `timeZone` you choose.

## Command-line demo

```sh
swift run prayer-time-plus-cli
```

## Documentation

Every public symbol carries a DocC comment. Build the documentation in Xcode with
**Product ▸ Build Documentation**, or add
[swift-docc-plugin](https://github.com/apple/swift-docc-plugin) to generate it
from the command line.

## Other platforms

The same solar engine, ported idiomatically to three ecosystems — identical
results to the minute:

| Platform | Package | Repository |
|---|---|---|
| **Swift** · iOS, macOS, watchOS, tvOS, Linux — you are here | [Swift Package Index](https://swiftpackageindex.com/abdulwahed-s/prayer-time-plus-swift) | [prayer-time-plus-swift](https://github.com/abdulwahed-s/prayer-time-plus-swift) |
| Dart / Flutter | [`prayer_time_plus`](https://pub.dev/packages/prayer_time_plus) | [prayer_time_plus](https://github.com/abdulwahed-s/prayer_time_plus) |
| Kotlin / JVM | [`io.github.abdulwahed-s:prayer-time-plus`](https://central.sonatype.com/artifact/io.github.abdulwahed-s/prayer-time-plus) | [prayer-time-plus-kotlin](https://github.com/abdulwahed-s/prayer-time-plus-kotlin) |

The Swift-version and platform badges above are served by the
[Swift Package Index](https://swiftpackageindex.com/abdulwahed-s/prayer-time-plus-swift)
and stay current automatically once the package is indexed.

## License

MIT — see [LICENSE](LICENSE).
