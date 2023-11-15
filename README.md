# timmy
Simple work time record tool

### Usage

```
$ timmy [in|out [time [date]]]
> check <in|out> on <date> at <time>

$ timmy get [--week|--month] [-n]
```

Cases:
    - no argument:
        add current time for the current day as next reasonable action
    - one argument:
        check in/out specify action, use dafault time/date
        or get last n (otherways all days optionally grouped by week or month
    - two arguments:
        specify action and time on default date
    - three arguments:
        specify action, time and date

To correct wrong actions edit the data file manually.
the file may be found under `~/.config/timmy/data.csv`
