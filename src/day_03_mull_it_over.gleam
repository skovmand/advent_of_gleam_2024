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
  wishbox.header(day: 2)
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/03.txt")

  wishbox.print_solution(part: 1, answer: part01(input))
}

pub fn part01(memory: String) -> Int {
  calculate_mul_instructions(memory)
}

pub fn part02(memory: String) -> Int {
  calculate_mul_instructions_with_dos_and_donts(memory)
}

// --

fn calculate_mul_instructions(memory: String) -> Int {
  let assert Ok(re) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  let matches = regexp.scan(with: re, content: memory)

  list.fold(matches, 0, fn(acc, match) {
    let assert [Some(a), Some(b)] = match.submatches
    let assert Ok(a) = int.parse(a)
    let assert Ok(b) = int.parse(b)

    acc + a * b
  })
}

fn calculate_mul_instructions_with_dos_and_donts(memory: String) -> Int {
  let options = regexp.Options(case_insensitive: False, multi_line: True)
  let assert Ok(replacer) =
    regexp.compile("don't\\(\\).*?do\\(\\)|don't\\(\\).*$", options)

  let fixed_memory = string.replace(in: memory, each: "\n", with: "")
  let fixed_memory = regexp.replace(each: replacer, in: fixed_memory, with: "")

  calculate_mul_instructions(fixed_memory)
}
