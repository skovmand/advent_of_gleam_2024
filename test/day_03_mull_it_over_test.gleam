import day_03_mull_it_over
import gleeunit/should
import simplifile

pub fn part01_example_test() {
  let example =
    "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

  let answer = day_03_mull_it_over.part01(example)
  should.equal(answer, 161)
}

pub fn part01_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/03.txt")
  let answer = day_03_mull_it_over.part01(input)
  should.equal(answer, 170_807_108)
}

pub fn part02_example_test() {
  let example_2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

  let answer = day_03_mull_it_over.part02(example_2)
  should.equal(answer, 48)
}

pub fn part02_multiline_test() {
  let example_2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)un
do()?mul(8,5))"

  let answer = day_03_mull_it_over.part02(example_2)
  should.equal(answer, 48)
}

pub fn part02_string_can_end_with_dont_test() {
  let example_2 =
    "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)
"

  let answer = day_03_mull_it_over.part02(example_2)
  should.equal(answer, 8)
}

pub fn part02_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/03.txt")
  let answer = day_03_mull_it_over.part02(input)
  should.equal(answer, 74_838_033)
}
