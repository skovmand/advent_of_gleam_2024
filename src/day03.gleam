/// --- Day 3: Mull It Over ---
///
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("--- Day 3: Mull It Over ---")
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/03.txt")

  wishbox.print_solution(part: 1, answer: part01(input))
  wishbox.print_solution(part: 2, answer: part02(input))
}

pub fn part01(memory: String) -> Int {
  calculate_mul_instructions(memory)
}

pub fn part02(memory: String) -> Int {
  memory
  |> remove_donts()
  |> calculate_mul_instructions()
}

// -- Implementation --

fn calculate_mul_instructions(memory: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let matches = regexp.scan(with: re, content: memory)

  use acc, match <- list.fold(matches, 0)
  let assert [Some(a), Some(b)] = match.submatches
  let assert Ok(a) = int.parse(a)
  let assert Ok(b) = int.parse(b)
  acc + a * b
}

fn remove_donts(memory: String) -> String {
  let assert Ok(replacer) =
    regexp.from_string("don't\\(\\).*?do\\(\\)|don't\\(\\).*$")

  // Turn the input into a single line, then remove don'ts
  string.replace(in: memory, each: "\n", with: "")
  |> regexp.replace(each: replacer, in: _, with: "")
}
