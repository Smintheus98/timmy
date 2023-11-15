import std / [ times, parsecsv, strutils, strformat ]
import global


converter rowToStamp(row: CsvRow): Stamp =
  Stamp(
    action: parseEnum[Action](row[0]),
    date: row[1].strToDate,
    time: row[2].strToTime,
    newEntry: false
  )

converter stampToRow(stamp: Stamp): CsvRow =
  @[
    stamp.action.`$`,
    stamp.date.dateToStr,
    stamp.time.timeToStr
  ]

proc loadData*(filename: string): TimeSheet =
  # TODO: handle missing information better (day not done, forgot to log-in/out, etc.)
  var
    sheet: TimeSheet
    parser: CsvParser
  try:
    parser.open(filename, skipInitialSpace = true)
    while parser.readRow():
      let stamp = parser.row.Stamp
      if sheet.len == 0 or stamp.date != sheet[^1][0].date:
        if sheet[^1].len mod 2 != 0:
          raise IOError.newException("Non-matching stamps")
        sheet.add @[stamp]
      else:
        sheet[^1].add stamp
  except:
    stderr.writeLine(fmt"Error while loading data from '{filename}'")
    stderr.writeLine(getCurrentExceptionMsg())
    QuitFailure.quit
  finally:
    parser.close()

proc saveData*(sheet: TimeSheet; filename: string; writeAll = false) =
  var file: File
  let fileMode = if writeAll: fmWrite else: fmAppend
  try:
    file = filename.open(fileMode)
    for workday in sheet:
      for stamp in workday:
        if writeAll or stamp.newEntry:
          file.writeLine(stamp.CsvRow)
  except:
    stderr.writeLine(fmt"Error while writing data to '{filename}'")
    stderr.writeLine(getCurrentExceptionMsg())
    QuitFailure.quit
  finally:
    file.close()
