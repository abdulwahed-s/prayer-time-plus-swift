# Calculation Methods

Every case of `CalculationMethod` returns a fresh `CalculationParameters` value
from ``CalculationMethod/parameters``. The table below decodes the most commonly
used methods; the full set is available through `CalculationMethod.allCases`, and
any method can be resolved from its string key with `CalculationMethod.from(key:)`.

`Maghrib` is always derived from sunset. `Isha` is either a twilight angle or an
interval measured from Maghrib. Minute offsets are applied on top.

## Standard methods

| Method | Key | Fajr | Isha | Notes |
|---|---|---|---|---|
| `muslimWorldLeague` | `mwl` | 18° | 17° | Muslim World League |
| `egyptian` | `egypt` | 19.5° | 17.5° | Egyptian General Authority of Survey |
| `karachi` | `karachi` | 18° | 18° | University of Islamic Sciences, Karachi |
| `ummAlQura` | `makkah` | 18.5° | Maghrib + 90 min | +30 min in Ramadan (Saudi Arabia) |
| `northAmerica` | `isna` | 15° | 15° | Islamic Society of North America |

## Gulf and Middle East

| Method | Key | Fajr | Isha | Other offsets |
|---|---|---|---|---|
| `emirates` | `emirates` | 18.5° | 18.5° − 3 min | Fajr +1, Sunrise −4, Dhuhr +2; Maghrib sunset + 2 min |
| `qatar` | `qatar` | 18° | Maghrib + 90 min | Maghrib sunset + 2 min |
| `kuwait` | `kuwait` | 18° | 17.5° | — |
| `oman` | `oman` | 18° | 18° + 1 min | Dhuhr +5, Asr +5; Maghrib sunset + 5 min |
| `jordan` | `jordan` | 18.12° | 17.975° | Maghrib sunset + 1 min |
| `syria` | `syria` | 19.5° | 17.5° | — |
| `iraq` | `iraq` | 18° | 17° | Dhuhr +5, Asr +3; Maghrib sunset + 2 min |
| `palestine` | `palestine` | 20.11° | 17.9° | Fajr −5; Maghrib sunset + 4 min |
| `kuwait` | `kuwait` | 18° | 17.5° | — |

## North Africa

| Method | Key | Fajr | Isha | Other offsets |
|---|---|---|---|---|
| `morocco` | `morocco` | 19.09° | 17° | Sunrise −2, Dhuhr +5; Maghrib sunset + 3 min |
| `algeria` | `algeria` | 18° | 17° | Maghrib sunset + 3 min |
| `tunisia` | `tunisia` | 18° | 18° + 1 min | Fajr −1, Dhuhr +7; Maghrib sunset + 1 min |
| `libya` | `libya` | 18.3° | 18.35° | Dhuhr +4; Maghrib sunset + 4 min |
| `sudan` | `sudan` | 18.12° | 17.88° | Sunrise +3, Dhuhr +3; Maghrib sunset − 4 min |

## Turkey, Asia and beyond

| Method | Key | Fajr | Isha | Other offsets |
|---|---|---|---|---|
| `turkey` | `turkey` | 18° | 16.93° | Sunrise −6, Dhuhr +6, Asr +4; Maghrib sunset + 5 min |
| `malaysia` | `malaysia` | 20° | 18° | Dhuhr +1 |
| `malaysia2` | `malaysia2` | 20° | 18.46° | Dhuhr +3, Asr +2; Maghrib sunset + 1 min |
| `indonesia` | `indonesia` | 20° | 18° + 2 min | Fajr +2, Sunrise −2, Dhuhr +2, Asr +2 |
| `maldives` | `maldives` | 19° | 19° + 1 min | Fajr −1, Dhuhr +4, Asr +1; Maghrib sunset + 1 min |
| `kazakhstan` | `kazakhstan` | 14.97° | 14.96° | Dhuhr +5, Asr +5 |
| `moscow` | `moscow` | 16° | 15.1° + 2 min | Dhuhr +1, Asr +1; Maghrib sunset + 1 min |

## Europe and North America

| Method | Key | Fajr | Isha | Other offsets |
|---|---|---|---|---|
| `uoif` | `uoif` | 12° | 12° + 5 min | Fajr −5, Dhuhr +5; Maghrib sunset + 4 min |
| `switzerland` | `switzerland` | 17.99° | Maghrib + 100 min | Fajr +1, Sunrise +4; Maghrib sunset − 4 min |
| `czech` | `czech` | 12.04° | 12.04° | Dhuhr +5; Maghrib sunset − 2 min |
| `belgium` | `belgium` | 18° | 18° | — |
| `montreal` | `montreal` | 15° | 15° | — |

Additional city-scoped presets are available (for example `london`, `birmingham`,
`aachen`, `munchen`, `potsdam`, `nurnberg`, `paris`, `toulouse`, `lyon`,
`orleans`, `windsor`, `calgary`, `mississauga`, `luxembourg`, `austria`,
`tajikistan`, `omanMuscat`, `azrou`, `fribourg`, `southKorea`, `rotterdam`,
`dordrecht`, `eindhoven`) using the same angle-based computation.
