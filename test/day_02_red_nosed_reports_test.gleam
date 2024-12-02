import day_02_red_nosed_reports
import gleeunit/should
import simplifile

const example = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"

pub fn part01_example_test() {
  let answer = day_02_red_nosed_reports.part01(example)
  should.equal(answer, 2)
}

pub fn part01_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/02.txt")
  let answer = day_02_red_nosed_reports.part01(input)
  should.equal(answer, 334)
}

pub fn part02_example_test() {
  let answer = day_02_red_nosed_reports.part02(example)
  should.equal(answer, 4)
}

// Yes, this bit me in my first implementation, because I detected if the numbers decreased
// by looking at the first two only.
pub fn part02_where_first_two_decrease_test() {
  let input =
    "69 67 70 72 73 74 76
"
  let answer = day_02_red_nosed_reports.part02(input)

  should.equal(answer, 1)
}

// This bit me too, since my algorithm never removed the first number.
pub fn part02_where_first_number_should_be_removed_test() {
  let input =
    "5 69 70 72 73 74 76
"
  let answer = day_02_red_nosed_reports.part02(input)

  should.equal(answer, 1)
}

// Never bit me, but just to be sure it works for the last number too!
pub fn part02_where_last_number_should_be_removed_test() {
  let input =
    "69 70 72 73 74 76 1
"
  let answer = day_02_red_nosed_reports.part02(input)

  should.equal(answer, 1)
}

pub fn part02_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/02.txt")
  let answer = day_02_red_nosed_reports.part02(input)
  should.equal(answer, 400)
}
