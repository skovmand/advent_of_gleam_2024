import day04
import gleeunit/should
import simplifile

const example = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"

pub fn part1_example_test() {
  let answer = day04.parse(example) |> day04.part1()
  should.equal(answer, 18)
}

pub fn part1_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/04.txt")
  let answer = day04.parse(input) |> day04.part1()
  should.equal(answer, 2644)
}

pub fn part2_example_test() {
  let answer = day04.parse(example) |> day04.part2()
  should.equal(answer, 9)
}

pub fn part2_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/04.txt")
  let answer = day04.parse(input) |> day04.part2()
  should.equal(answer, 1952)
}
