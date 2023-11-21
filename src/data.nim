import std / [ times, parsecsv, strutils, strformat ]
import global


converter toStamp(row: CsvRow): Stamp = initStamp(row[0], row[1], row[2], false)
converter toRow(stamp: Stamp): CsvRow = @$stamp


proc loadData*(filename: string): TimeSheet =
  # TODO: handle missing information better (day not done, forgot to log-in/out, etc.)
  var
    sheet: TimeSheet
    parser: CsvParser
  try:
    parser.open(filename, skipInitialSpace = true)
    while parser.readRow():
      let stamp = parser.row.toStamp
      if sheet.len == 0 or stamp.date != sheet.last.date:
        sheet.add initWorkday(stamp)
      else:
        sheet.last.add stamp
  except:
    stderr.writeLine(fmt"Error while loading data from '{filename}'")
    stderr.writeLine(getCurrentExceptionMsg())
    QuitFailure.quit
  finally:
    parser.close()
  return sheet


proc saveData*(sheet: TimeSheet; filename: string; writeAll = false) =
  var file: File
  let fileMode = if writeAll: fmWrite else: fmAppend
  try:
    file = filename.open(fileMode)
    for workday in sheet:
      for stamp in workday:
        if writeAll or stamp.newEntry:
          file.writeLine(stamp.toRow)
  except:
    stderr.writeLine(fmt"Error while writing data to '{filename}'")
    stderr.writeLine(getCurrentExceptionMsg())
    QuitFailure.quit
  finally:
    file.close()
