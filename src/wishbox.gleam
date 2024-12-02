import gleam/int
import gleam/io
import gleam/string

pub fn header(day day: Int) {
  string.concat(["🕯️🎄 Day ", int.to_string(day), " 🕯️🎄"])
  |> io.println
  io.println("")
}

pub fn print_solution(part part: Int, answer answer: any) {
  string.concat(["Part ", int.to_string(part), ": "])
  |> io.println

  io.debug(answer)
  io.println("")
}
