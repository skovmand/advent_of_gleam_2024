/// --- Day 4: Ceres Search ---
/// TIL: I spent some time learning how to use `use`
/// TIL: Finally realised I could simplify some things with result.try instead of result.map
///
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("--- Day 4: Ceres Search ---")
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/04.txt")

  let parsed = parse(input)
  wishbox.print_solution(part: 1, answer: part1(parsed))
  wishbox.print_solution(part: 2, answer: part2(parsed))
}

pub fn part1(input: Grid) -> Int {
  count_xmas_matches_for_grid(input)
}

pub fn part2(input: Grid) -> Int {
  count_all_x_mas_matches(input)
}

// -- Implementation --->

type Point =
  #(Int, Int)

type Grid =
  Dict(Point, String)

pub fn parse(input: String) -> Grid {
  wishbox.parse_lines(input, parse_line)
  |> list.index_map(fn(letters, line) {
    list.map(letters, fn(letter_and_column) {
      let #(letter, column) = letter_and_column
      #(#(column, line), letter)
    })
  })
  |> list.flatten
  |> dict.from_list
}

fn parse_line(input: String) -> List(#(String, Int)) {
  string.split(input, "")
  |> list.index_map(fn(letter, column) { #(letter, column) })
}

/// Part 1
fn count_xmas_matches_for_grid(grid: Grid) {
  dict.fold(grid, 0, fn(count, point, _letter) {
    count + count_xmas_matches_for_point(grid, point)
  })
}

fn count_xmas_matches_for_point(grid: Grid, point: Point) {
  let #(x, y) = point
  let checks = [
    // Forwards
    [#(x, y), #(x + 1, y), #(x + 2, y), #(x + 3, y)],
    // Backwards
    [#(x + 3, y), #(x + 2, y), #(x + 1, y), #(x, y)],
    // Downwards
    [#(x, y), #(x, y + 1), #(x, y + 2), #(x, y + 3)],
    // Upwards
    [#(x, y), #(x, y - 1), #(x, y - 2), #(x, y - 3)],
    // Diagonal to the north-east
    [#(x, y), #(x + 1, y - 1), #(x + 2, y - 2), #(x + 3, y - 3)],
    // Diagonal to the south-east
    [#(x, y), #(x + 1, y + 1), #(x + 2, y + 2), #(x + 3, y + 3)],
    // Diagonal to the south-west
    [#(x, y), #(x - 1, y + 1), #(x - 2, y + 2), #(x - 3, y + 3)],
    // Diagonal to the north-west
    [#(x, y), #(x - 1, y - 1), #(x - 2, y - 2), #(x - 3, y - 3)],
  ]

  list.count(checks, fn(check) { word_in_grid(grid, check) == Ok("XMAS") })
}

fn word_in_grid(grid: Grid, points: List(Point)) -> Result(String, Nil) {
  use word, point <- list.try_fold(points, "")
  use letter <- result.try(dict.get(grid, point))
  Ok(word <> letter)
}

/// Part 2
fn count_all_x_mas_matches(grid: Grid) -> Int {
  dict.fold(grid, 0, fn(count, point, _letter) {
    count + score_x_mas_for_point(grid, point)
  })
}

fn score_x_mas_for_point(grid: Grid, point: Point) -> Int {
  let #(x, y) = point
  let north_east_check = [#(x + 1, y - 1), #(x, y), #(x - 1, y + 1)]
  let north_west_check = [#(x - 1, y - 1), #(x, y), #(x + 1, y + 1)]

  let north_east = word_in_grid(grid, north_east_check) |> is_mas_match()
  let north_west = word_in_grid(grid, north_west_check) |> is_mas_match()

  case north_east && north_west {
    True -> 1
    False -> 0
  }
}

fn is_mas_match(word: Result(String, Nil)) -> Bool {
  case word {
    Ok("MAS") | Ok("SAM") -> True
    _ -> False
  }
}
