import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub fn header(title: String) {
  io.println(string.concat(["🕯️🎄 --- ", title, " --- 🕯️🎄"]))
  io.println("")
}

pub fn print_solution(part part: Int, answer answer: any) {
  string.concat(["Part ", int.to_string(part), ": "])
  |> io.println

  io.debug(answer)
  io.println("")
}

pub fn parse_lines(input: String, mapper: fn(String) -> a) -> List(a) {
  string.split(input, "\n")
  |> list.filter(fn(line) { line != "" })
  |> list.map(mapper)
}

pub fn try_parse_lines(
  input: String,
  mapper: fn(String) -> Result(a, Nil),
) -> Result(List(a), Nil) {
  string.split(input, "\n")
  |> list.filter(fn(line) { line != "" })
  |> list.try_map(mapper)
}
