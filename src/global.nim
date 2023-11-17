import std / [ times, streams, strutils, strformat ]
import zero_functional

export times

const
  dateFormat = initTimeFormat("dd-MM-yyyy")
  timeFormat = initTimeFormat("HH:mm")
  weeklyHours = 13  # TODO: make variable

type
  Grouping* = enum
    ByDay ByWeek ByMonth
  Action* = enum
    In Out
  Stamp* = object
    action*: Action
    date*: DateTime
    time*: DateTime
    newEntry*: bool
  Workday* = seq[Stamp]
  WorkWeek* = object
    days*: seq[WorkDay]
  WorkMonth* = object
    days*: seq[WorkDay]
  TimeSheet* = seq[Workday]
  WeekSheet* = seq[WorkWeek]
  MonthSheet* = seq[WorkMonth]


proc strToDate*(str: string): DateTime =  str.parse(dateFormat)
proc dateToStr*(date: DateTime): string = date.format(dateFormat)
proc strToTime*(str: string): DateTime =  str.parse(timeFormat)
proc timeToStr*(time: DateTime): string = time.format(timeFormat)

proc date(day: WorkDay): DateTime =
  day[0].date

proc getIsoWeekAndYear(day: WorkDay): tuple[isoweek: IsoWeekRange, isoyear: IsoYear] =
  day.date.getIsoWeekAndYear

proc getCalendarWeek(week: WorkWeek): Positive =
  week.days[0].getIsoWeekAndYear.isoweek

proc getWorkTime(day: WorkDay): Duration =
  # TODO: handle incomplete Data properly!
  # TODO: add Lunch break
  result = initDuration(0)
  for i in countup(day.low, day.high, 2):
    result += day[i+1].time - day[i].time
    
proc getWorkTime(week: WorkWeek): Duration =
  week.days --> map(getWorkTime).sum()

proc getWorkTime(month: WorkMonth): Duration =
  month.days --> map(getWorkTime).sum()

proc check(sheet: TimeSheet): tuple[valid: bool, msgs: string] =
  var msg = newStringStream("")
  for day in sheet:
    let date = day.date.dateToStr

    if day.len mod 2 != 0 and day != sheet[^1]:
      msg.writeLine(fmt"Missing Stamp on day {date}")

    var lastAction = day[0].action
    if lastAction != Action.In:
      msg.writeLine(fmt"First action of day {date} is not valid")

    for stamp in day[1..^1]:
      if stamp.action == lastAction:
        msg.writeLine(fmt"Two following actions of day {date} are identical")
      lastAction = stamp.action

  return (msg.data.len == 0, msg.data)

proc parseWeeks*(sheet: TimeSheet): WeekSheet =
  result = @[]
  for day in sheet:
    if result.len == 0 or day.getIsoWeekAndYear != result[^1].days[0].getIsoWeekAndYear:
      result.add WorkWeek(days: @[day])
    else:
      result[^1].days.add day

proc `$`*(day: WorkDay): string =
  # TODO: handle not done days (incomplete data) properly!
  var sstr = newStringStream("")
  sstr.write(DefaultLocale.ddd[day.date.weekday] & " ")
  sstr.write(day.date.dateToStr & ":  ")
  let indWidth = sstr.getPosition()

  sstr.write(day[0].time.timeToStr & " - " & day[1].time.timeToStr)

  for i in countup(2, day.high, 2):
    sstr.write("\n" & indWidth.spaces)
    sstr.write(day[i].time.timeToStr & " - " & day[i+1].time.timeToStr)

  sstr.write("  " & $day.getWorkTime)
  return sstr.data

proc `$`*(week: WorkWeek): string =
  var sstr = newStringStream("")
  for day in week.days:
    sstr.writeLine($day)
  sstr.write(fmt"==> Week {week.getCalendarWeek}: {week.getWorkTime}")
  return sstr.data

