import std / [ sequtils, strutils, strformat ]
import def

proc handle*(cli: seq[string]): Operation =
  try:
    result = Operation(kind: parseEnum[CliOption](cli[0]))
  except:
    stderr.writeLine(fmt"ERROR: First Argument got to be one of: {CliOption.toSeq.`$`[2..^2]}")
    QuitFailure.quit

  case result.kind:
    of `in`, `out`:
      discard
    of get:
      discard


