import std/times
export times

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
  TimeSheet* = seq[Workday]

  WorkMonth* = object
    name*: times.Month
    workDays*: seq[WorkDay]
  WorkWeek* = object
    calendarWeek*: Positive
    workDays*: seq[WorkDay]
    hours*: Natural

const
  dateFormat = initTimeFormat("dd-MM-yyyy")
  timeFormat = initTimeFormat("HH:mm")

proc strToDate*(str: string): DateTime =  str.parse(dateFormat)
proc dateToStr*(date: DateTime): string = date.format(dateFormat)
proc strToTime*(str: string): DateTime =  str.parse(timeFormat)
proc timeToStr*(time: DateTime): string = time.format(timeFormat)

proc getHours(workDay: WorkDay): Duration
