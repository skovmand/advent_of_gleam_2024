import day06
import gleeunit/should
import simplifile

const example = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"

pub fn part1_example_test() {
  let answer = day06.parse(example) |> day06.part_1()
  should.equal(answer, 41)
}

pub fn part1_test() {
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/06.txt")
  let answer = day06.parse(input) |> day06.part_1()
  should.equal(answer, 5318)
}

pub fn part2_example_test() {
  let answer = day06.parse(example) |> day06.part_2()
  should.equal(answer, 6)
}
// This test is too slow (more than 5 seconds)
// pub fn part2_test() {
//   let assert Ok(input) = simplifile.read(from: "puzzle_inputs/06.txt")
//   let answer = day06.parse(input) |> day06.part_2()
//   should.equal(answer, 1831)
// }
