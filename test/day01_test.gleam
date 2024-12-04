import day01
import gleeunit/should
import simplifile

const example = "3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn part01_example_test() {
  let answer = day01.part01(example)
  should.equal(answer, 11)
}

pub fn part01_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/01.txt")
  let answer = day01.part01(input)
  should.equal(answer, 2_375_403)
}

pub fn part02_example_test() {
  let answer = day01.part02(example)
  should.equal(answer, 31)
}

pub fn part02_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/01.txt")
  let answer = day01.part02(input)
  should.equal(answer, 23_082_277)
}
