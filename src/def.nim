import std/times
from std/os import getEnv
from std/strutils import startswith

const GermanLocale = DateTimeLocale(
  MMM: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
  MMMM: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
  ddd: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
  dddd: [ "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
)

let
  weeklyHours* = initDuration(hours=13)  # TODO: make variable
  LANG = "LANG".getEnv
  locale* =
      case LANG[0..1]:
        of "de":
          GermanLocale
        else:
          DefaultLocale

