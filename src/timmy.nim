import std / [ os, strformat, streams ]
import global, data


let
  dataPath = getEnv("HOME") & "/.local/share/timmy"
  datafile = dataPath / "timesheet.csv"

proc show(sheet: TimeSheet; grouping: Grouping; n: Natural = 0) =
  var sstr = newStringStream("")

  case grouping:
    of ByDay:
      for day in sheet.last(n):
        sstr.writeLine($day)
    of ByWeek:
      let weeks = sheet.parseWeeks
      for week in weeks.last(n):
        sstr.writeLine($week)
    of ByMonth: discard

  echo sstr.data
  ## ByDay:
  # <date>:  <time-in> - <time-out> [,
  #          <time-in> - <time-out> [, ]] <hours>
  #
  ## ByWeek:
  # <date>:  <time-in> - <time-out>  <hours>
  # <date>:  <time-in> - <time-out>  <hours>
  # <date>:  <time-in> - <time-out>  <hours>
  # ==> Week <cw>: <sum hours>
  # <date>:  <time-in> - <time-out>  <hours>
  # ==> Calender week: <cw>, hours: <sum hours>, remaining: <rem hours>
  #

proc main =
  try:
    if not datafile.fileExists():
      if not dataPath.dirExists():
        dataPath.createDir()
      datafile.writeFile("")
  except:
    stderr.writeLine(fmt"Error while creating file '{datafile}'")
    QuitFailure.quit

when isMainModule:
  main()
