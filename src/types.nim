import std / [ times, streams, strutils, strformat ]
import zero_functional
import def

#=======================================
#   Enumeration Types
#=======================================
type
  Action* = enum
    In Out
  Grouping* = enum
    ByDay ByWeek ByMonth


#=======================================
#   Simple Type Definitions
#=======================================
type Index = Natural | BackwardsIndex
type IsoWeekAndYear = tuple[isoweek: IsoWeekRange, isoyear: IsoYear]
type MonthAndYear = tuple[month: Month, year: IsoYear]


#=======================================
#   Cutom Duration to string procedure
#=======================================
proc `$`(d: Duration): string =
  let
    hours = d.inHours
    decimal = ((d.inMinutes - d.inHours * 60) / 60 * 100).int
  fmt"{hours}.{decimal:02}"


#=======================================
#   date/time-string conversion
#=======================================
const
  dateFormat = initTimeFormat("dd-MM-yyyy")
  timeFormat = initTimeFormat("HH:mm")

proc strToDate(str: string): DateTime =  str.parse(dateFormat)
proc dateToStr(date: DateTime): string = date.format(dateFormat)
proc strToTime(str: string): DateTime =  str.parse(timeFormat)
proc timeToStr(time: DateTime): string = time.format(timeFormat)


#=======================================
#   Stamp Type
#=======================================
type Stamp* = object
  action: Action
  date: DateTime
  time: DateTime
  newEntry: bool

proc initStamp*(action: Action; date, time: string, newEntry = false): Stamp =
  Stamp(action: action, date: date.strToDate, time: time.strToTime, newEntry: newEntry)
proc initStamp*(action, date, time: string, newEntry = false): Stamp =
  initStamp(parseEnum[Action] action, date, time, newEntry)
proc initStamp*(op: Operation): Stamp =
  # TODO
  discard

proc date*(stamp: Stamp): DateTime = stamp.date
proc dateStr*(stamp: Stamp): string = stamp.date.dateToStr
proc timeStr*(stamp: Stamp): string = stamp.time.timeToStr

proc newEntry*(stamp: Stamp): bool = stamp.newEntry
proc `@$`*(stamp: Stamp): seq[string] =
  @[ $stamp.action, stamp.dateStr, stamp.timeStr ]


#=======================================
#   WorkDay Collection (of Stamps)
#=======================================
type Workday* = object
  stamps: seq[Stamp]

proc initWorkDay*(stamps: seq[Stamp]): WorkDay =
  WorkDay(stamps: stamps)
proc initWorkDay*(stamp: Stamp): WorkDay =
  WorkDay(stamps: @[stamp])

# access procedures
proc `[]`(day: WorkDay; i: Index): Stamp =
  day.stamps[i]
proc `[]`[U,V: Ordinal](day: WorkDay; slice: HSlice[U,V]): seq[Stamp] =
  day.stamps[slice]

proc add*(day: var WorkDay; stamp: Stamp) =
  day.stamps.add stamp

proc len(day: WorkDay): int = day.stamps.len
proc high(day: WorkDay): int = day.stamps.high
proc low(day: WorkDay): int = day.stamps.low

iterator items*(day: WorkDay): Stamp =
  for stamp in day.stamps.items:
    yield stamp

# data procedures
proc date*(day: WorkDay): DateTime = day.stamps[0].date
proc dateStr*(day: WorkDay): string = day.stamps[0].dateStr

proc getIsoWeekAndYear(day: WorkDay): IsoWeekAndYear =
  day.date.getIsoWeekAndYear

proc getMonthAndYear(day: WorkDay): MonthAndYear =
  (month: day.date.month, year: day.getIsoWeekAndYear.isoyear)

proc getWorkTime(day: WorkDay): Duration =
  # TODO: handle incomplete stamps properly!
  # TODO: add Lunch break
  result = initDuration(0)
  for i in countup(day.low, day.high, 2):
    result += day[i+1].time - day[i].time

proc `$`*(day: WorkDay): string =
  # TODO: handle not done days (incomplete stamps) properly!
  var sstr = newStringStream("")
  sstr.write(locale.ddd[day.date.weekday] & " ")
  sstr.write(day.dateStr & ":  ")
  let indWidth = sstr.getPosition()

  sstr.write(day[0].timeStr & " - " & day[1].timeStr)

  for i in countup(2, day.high, 2):
    sstr.write("\n" & indWidth.spaces)
    sstr.write(day[i].timeStr & " - " & day[i+1].timeStr)

  sstr.write("  +" & $day.getWorkTime)
  return sstr.data


#=======================================
#   WorkWeek Collection (of WorkDay)
#=======================================
type WorkWeek* = object
  days: seq[WorkDay]

# access procedures
proc add(week: var WorkWeek; day: WorkDay) =
  week.days.add(day)

iterator items(week: WorkWeek): WorkDay =
  for day in week.days.items:
    yield day

# data procedures
proc getIsoWeekAndYear(week: WorkWeek): IsoWeekAndYear =
  week.days[0].getIsoWeekAndYear

proc getCalendarWeek(week: WorkWeek): Positive =
  week.getIsoWeekAndYear.isoweek

proc getWorkTime(week: WorkWeek): Duration =
  week.days --> map(getWorkTime).sum()

proc `$`*(week: WorkWeek; showRemaining: bool = false): string =
  var sstr = newStringStream("")
  for day in week:
    sstr.writeLine($day)
  sstr.write(fmt"==> Week {week.getCalendarWeek}: +{week.getWorkTime}")
  if showRemaining:
    let diff = abs(weeklyHours - week.getWorkTime)
    if weeklyHours > week.getWorkTime:
      sstr.write("   -" & $diff)
    else:
      sstr.write("   +" & $diff)
  return sstr.data


#=======================================
#   WorkMonth Collection (of WorkDay)
#=======================================
type WorkMonth* = object
  days: seq[WorkDay]

# access procedures
proc add(month: var WorkMonth; day: WorkDay) =
  month.days.add day

iterator items(month: WorkMonth): WorkDay =
  for day in month.days.items:
    yield day

# data procedures
proc getMonthAndYear(month: WorkMonth): MonthAndYear =
  month.days[0].getMonthAndYear

proc getWorkTime(month: WorkMonth): Duration =
  month.days --> map(getWorkTime).sum()

proc `$`*(month: WorkMonth): string =
  var sstr = newStringStream("")
  for day in month:
    sstr.writeLine($day)
  let (m, y) = month.getMonthAndYear
  sstr.write(fmt"==> {locale.MMMM[m]} {y}: {month.getWorkTime}")
  return sstr.data


#=======================================
#   TimeSheet Collection (of WorkDay)
#=======================================
type TimeSheet* = object
  days: seq[Workday]

# access procedures
proc add*(sheet: var TimeSheet; day: WorkDay) =
  sheet.days.add day

proc len*(sheet: TimeSheet): int = sheet.days.len

proc last(sheet: TimeSheet): WorkDay =
  return sheet.days[^1]
proc last*(sheet: var TimeSheet): var WorkDay =
  return sheet.days[^1]
proc last*(sheet: TimeSheet; n: Natural): seq[WorkDay] =
  case n:
    of 0:
      return sheet.days
    else:
      let lower = max(0, sheet.len-n)
      return sheet.days[lower..^1]

iterator items*(sheet: TimeSheet): WorkDay =
  for day in sheet.days.items:
    yield day


#=======================================
#   WeekSheet Collection (of WorkWeeks)
#=======================================
type WeekSheet* = object
  weeks: seq[WorkWeek]

# access procedures
proc add(sheet: var WeekSheet; day: WorkWeek) =
  sheet.weeks.add(day)

proc len(sheet: WeekSheet): int = sheet.weeks.len

proc last*(sheet: var WeekSheet): var WorkWeek =
  return sheet.weeks[^1]
proc last*(sheet: WeekSheet; n: Natural): seq[WorkWeek] =
  case n:
    of 0:
      return sheet.weeks
    else:
      let lower = max(0, sheet.len-n)
      return sheet.weeks[lower..^1]

iterator items*(sheet: WeekSheet): WorkWeek =
  for day in sheet.weeks.items:
    yield day

proc parseWeeks*(sheet: TimeSheet): WeekSheet =
  for day in sheet:
    if result.len == 0 or day.getIsoWeekAndYear != result.last.getIsoWeekAndYear:
      result.add WorkWeek(days: @[day])
    else:
      result.last.add day


#=======================================
#   MonthSheet Collection (of WorkMonth)
#=======================================
type MonthSheet* = object
  months: seq[WorkMonth]

proc add(sheet: var MonthSheet; month: WorkMonth) =
  sheet.months.add month

proc len(sheet: MonthSheet): int = sheet.months.len

proc last(sheet: var MonthSheet): var WorkMonth =
  sheet.months[^1]
proc last*(sheet: MonthSheet; n: Natural): seq[WorkMonth] =
  case n:
    of 0:
      return sheet.months
    else:
      let lower = max(0, sheet.len-n)
      return sheet.months[lower..^1]

proc parseMonths*(sheet: TimeSheet): MonthSheet =
  for day in sheet:
    if result.len == 0 or day.getMonthAndYear != result.last.getMonthAndYear:
      result.add WorkMonth(days: @[day])
    else:
      result.last.add day


#=======================================
#   Validaion
#=======================================
proc validate(sheet: TimeSheet) =
  # TODO: interacively validate the sheet
  discard

proc check(sheet: TimeSheet): tuple[valid: bool, msgs: string] =
  var msg = newStringStream("")
  for day in sheet:
    let date = day.dateStr

    if day.len mod 2 != 0 and day != sheet.last:
      msg.writeLine(fmt"Missing Stamp on day {date}")

    var lastAction = day[0].action
    if lastAction != Action.In:
      msg.writeLine(fmt"First action of day {date} is not valid")

    for stamp in day[1..^1]:
      if stamp.action == lastAction:
        msg.writeLine(fmt"Two following actions of day {date} are identical")
      lastAction = stamp.action

  return (msg.data.len == 0, msg.data)

