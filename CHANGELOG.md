# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-09-21

### Added

- Working angle-based Maghrib support through the existing
  `maghribIsInterval`/`maghribValue` API, with safe Sunset fallback for
  unavailable or non-chronological events.
- Cross-package Custom preset parity: `.other` now starts at Fajr 18°, Maghrib
  at Sunset, and Isha 17°, using the stable key `custom`.

### Changed

- `CalculationMethod.from(key:)` accepts legacy `other` as an alias for
  `custom`.

### Fixed

- Interval Isha is calculated from the final Maghrib, including an angle-based
  Maghrib; method and user offsets remain applied exactly once.
- Automatic national method resolution now maps Iraq (`IQ`) to `iraq` instead
  of `egypt`, and Austria (`AT`) to `austria` instead of `tunisia`.
- Removed the unused continent fallback from the generated resolution model;
  country misses now fall back directly to Muslim World League as documented.

## [0.1.0] - 2026-07-09

### Added

- Initial release of `PrayerTimePlus`, a dependency-free Swift package for
  computing Islamic prayer times.
- Astronomical core: Julian day, solar declination, equation of time, transit,
  the sun-at-depression time, and the Asr shadow-factor time.
- `CalculationMethod` presets for every supported region, each keyed to the
  reference parameter table, plus a fully custom `.other`.
- `CalculationParameters` with per-prayer offsets, madhab, high-latitude rule and
  Ramadan handling.
- `PrayerTimes` producing true-UTC instants, with current/next prayer,
  `today(...)`, and an automatic high-latitude fallback.
- `SunnahTimes` for the middle and last third of the night.
- `AutoMethod` country-to-method resolution from bundled data.
- A CLI demo target and a comprehensive test suite, including the verified
  golden vectors.

[Unreleased]: https://github.com/abdulwahed-s/prayer-time-plus-swift/compare/0.3.0...HEAD
[0.3.0]: https://github.com/abdulwahed-s/prayer-time-plus-swift/compare/0.1.0...0.3.0
[0.1.0]: https://github.com/abdulwahed-s/prayer-time-plus-swift/releases/tag/0.1.0
