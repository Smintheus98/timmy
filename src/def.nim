import std/times
from std/os import getEnv
from std/strutils import startswith, split

const GermanLocale = DateTimeLocale(
  MMM: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
  MMMM: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
  ddd: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
  dddd: [ "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
)

let
  weeklyHours* = initDuration(hours=13)  # TODO: make variable/setable
  LANG = "LANG".getEnv.split('.')[0]
  locale* =
      case LANG:
        of "de_AT", "de_BE", "de_CH", "de_DE", "de_IT", "de_LI", "de_LU":
          GermanLocale
        else:
          DefaultLocale


type
  CliOption* = enum
    `in` `out` get
  CliGrouping* = enum
    day week month
  DefaultOperation* = object
  StandardOperation* = object
    case kind*: CliOption
      of `in`, `out`:
        time*: string
        date*: string
      of get:
        grp*: CliGrouping
        n*: Natural
  Operation* = StandardOperation | DefaultOperation

proc initOperation*(): DefaultOperation =
  DefaultOperation()
proc initOperation*(kind: CliOption): StandardOperation =
  StandardOperation(kind: kind)

