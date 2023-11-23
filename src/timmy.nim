import std / [ os, strformat, streams ]
import types, data


let
  datapath = getEnv("HOME") & "/.local/share/timmy"
  datafile = datapath / "timesheet.csv"

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
    of ByMonth:
      let months = sheet.parseMonths
      for month in months.last(n):
        sstr.writeLine($month)

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
      if not datapath.dirExists():
        datapath.createDir()
      datafile.writeFile("")
  except:
    stderr.writeLine(fmt"Error while creating file '{datafile}'")
    QuitFailure.quit

when isMainModule:
  main()
else:
  export main, show, datapath, datafile
  export global, data
