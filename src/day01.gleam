/// --- Day 1: Historian Hysteria ---
/// TIL: You can't destructure tuples in function heads, at least not yet.
/// TIL: list.reduce returns a result (which means it can stop early, and handle errors)
/// TIL: I really like the `by:` argument in `list.sort(list_2, by: int.compare)`
/// TIL: There's `list.try_map`, I like it!
///
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("--- Day 1: Historian Hysteria ---")
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/01.txt")

  let part_1_answer = part01(input)
  wishbox.print_solution(part: 1, answer: part_1_answer)

  let part_2_answer = part02(input)
  wishbox.print_solution(part: 2, answer: part_2_answer)
}

pub fn part01(input: String) -> Int {
  let assert Ok(#(list_1, list_2)) = parse(input)
  total_distance_between_lists(list_1, list_2)
}

pub fn part02(input: String) -> Int {
  let assert Ok(#(list_1, list_2)) = parse(input)
  similarity_score(list_1, list_2)
}

// -- Implementation --->

fn parse(input: String) -> Result(#(List(Int), List(Int)), Nil) {
  wishbox.parse_lines(input, parse_line)
  |> result.map(list.unzip)
}

fn parse_line(input: String) -> Result(#(Int, Int), Nil) {
  let assert [a, b] = string.split(input, "   ")

  case int.parse(a), int.parse(b) {
    Ok(a), Ok(b) -> Ok(#(a, b))
    _, _ -> Error(Nil)
  }
}

fn total_distance_between_lists(list_1: List(Int), list_2: List(Int)) -> Int {
  let sorted_list_1 = list.sort(list_1, by: int.compare)
  let sorted_list_2 = list.sort(list_2, by: int.compare)
  let zipped_list = list.zip(sorted_list_1, sorted_list_2)

  list.map(zipped_list, fn(a) { int.absolute_value(a.0 - a.1) })
  |> list.fold(0, fn(acc, x) { acc + x })
}

fn similarity_score(list_1: List(Int), list_2: List(Int)) -> Int {
  let frequency_map = build_frequency_map(list_2)

  list.map(list_1, fn(x) {
    let multiplier = case dict.get(frequency_map, x) {
      Ok(count) -> count
      Error(_) -> 0
    }

    x * multiplier
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

fn build_frequency_map(list: List(Int)) -> Dict(Int, Int) {
  list.fold(list, dict.new(), fn(d, x) {
    case dict.get(d, x) {
      Ok(count) -> dict.insert(d, x, count + 1)
      Error(_) -> dict.insert(d, x, 1)
    }
  })
}
