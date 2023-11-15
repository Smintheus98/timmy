import std / [ os, strformat, streams ]
import global, data


let
  dataPath = getEnv("HOME") & "/.local/share/timmy"
  datafile = dataPath / "timesheet.csv"

proc show(sheet: TimeSheet; grouping: Grouping; n: Natural = 0) =
  var strs = newStringStream("")

  case grouping:
    of ByDay:
      let lower = if n == 0: 0 else: sheet.len-n
      for workDay in sheet[lower..^1]:
        strs.write(workDay[0].date.dateToStr)
        discard
    of ByWeek: discard
    of ByMonth: discard



  for workday in sheet:
    discard


  # <date>:  <time-in> - <time-out> [,
  #          <time-in> - <time-out> [, ]] <hours>
  #
  # week:
  # <date>:  <time-in> - <time-out>  <hours>
  # <date>:  <time-in> - <time-out>  <hours>
  # <date>:  <time-in> - <time-out>  <hours>
  # ==> Calender week: <cw>, hours: <sum hours>
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
