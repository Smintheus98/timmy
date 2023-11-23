import std / [ sequtils, strutils, strformat ]
import def

proc parse*(cli: seq[string]): Operation =
  ## NOTE: returned Operation may be invalid and has to be checked seperately!
  if cli.len == 0:
    return initOperation()

  try:
    result = initOperation(parseEnum[CliOption](cli[0]))
  except:
    stderr.writeLine(fmt"ERROR: First Argument got to be one of: {CliOption.toSeq.`$`[2..^2]}")
    QuitFailure.quit

  case result.kind:
    of `in`, `out`:
      if cli.len >= 2:
        result.time = cli[1]
        if cli.len >= 3:
          result.date = cli[2]
    of get:
      discard


