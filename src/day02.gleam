/// --- Day 2: Historian Hysteria ---
/// Part 2 was much harder than I expected, I kept having edge cases even though the example passed the test.
///
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("--- Day 2: Historian Hysteria ---")
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/02.txt")

  wishbox.print_solution(part: 1, answer: part01(input))
  wishbox.print_solution(part: 2, answer: part02(input))
}

pub fn part01(input: String) -> Int {
  let assert Ok(reports) = parse(input)
  count_valid_reports(reports, is_report_valid)
}

pub fn part02(input: String) -> Int {
  let assert Ok(reports) = parse(input)
  count_valid_reports(reports, is_report_valid_using_problem_dampener)
}

// --

fn parse(input: String) -> Result(List(List(Int)), Nil) {
  wishbox.parse_lines(input, parse_line)
}

fn parse_line(input: String) -> Result(List(Int), Nil) {
  string.split(input, " ")
  |> list.try_map(int.parse)
}

fn count_valid_reports(reports: List(List(a)), validator: fn(List(a)) -> Bool) {
  reports
  |> list.filter(validator)
  |> list.length
}

// Solver for part 1
fn is_report_valid(report: List(Int)) -> Bool {
  let check_fn = get_check_fn(report)

  report
  |> list.window_by_2
  |> list.all(check_fn)
}

// Solver for part 2
fn is_report_valid_using_problem_dampener(report: List(Int)) -> Bool {
  case is_report_valid(report) {
    True -> True
    False ->
      case recheck_using_problem_dampener(report) {
        True -> True
        // This is a silly hack. It's because my algorithm can't remove the first element of the list,
        // so I reverse the list and retry.
        False -> recheck_using_problem_dampener(list.reverse(report))
      }
  }
}

fn recheck_using_problem_dampener(report: List(Int)) -> Bool {
  let check_fn = get_check_fn(report)

  let assert Ok(first_element) = list.first(report)
  let assert Ok(report_without_unsafe_element) =
    report
    |> list.window_by_2
    |> list.map(fn(pair) {
      let #(_, b) = pair
      #(b, check_fn(pair))
    })
    // Here we know the second element in the pair and the validity
    |> list.pop(fn(pair_with_validity) {
      let #(_, is_valid) = pair_with_validity
      is_valid == False
    })
    // Get the list without the invalid jump
    |> result.map(fn(x) { x.1 })
    // Map everything to the 2nd number
    |> result.map(fn(x) { list.map(x, fn(x) { x.0 }) })
    // Add the first element back to the front of the list
    |> result.map(fn(x) { list.prepend(x, first_element) })

  is_report_valid(report_without_unsafe_element)
}

type DirectionCount {
  DirectionCount(increasing: Int, decreasing: Int, similar: Int)
}

// Analyse the report, see if it's mostly increasing, or decreasing, return the function to use
// for checking validity of each pair.
fn get_check_fn(report: List(Int)) -> fn(#(Int, Int)) -> Bool {
  let direction_count =
    report
    |> list.window_by_2
    |> list.fold(DirectionCount(0, 0, 0), fn(acc, elem) {
      let #(a, b) = elem
      case int.compare(a, b) {
        Eq -> DirectionCount(..acc, similar: acc.similar + 1)
        Gt -> DirectionCount(..acc, decreasing: acc.decreasing + 1)
        Lt -> DirectionCount(..acc, increasing: acc.increasing + 1)
      }
    })

  // I'll just ignore the equal case, since it will be invalid anyway
  case direction_count.increasing > direction_count.decreasing {
    True -> is_increasing
    False -> is_decreasing
  }
}

fn is_increasing(pair: #(Int, Int)) -> Bool {
  let #(first, second) = pair
  let absolute_value = int.absolute_value(first - second)
  first < second && absolute_value <= 3 && absolute_value >= 1
}

fn is_decreasing(pair: #(Int, Int)) -> Bool {
  let #(first, second) = pair
  let absolute_value = int.absolute_value(first - second)
  first > second && absolute_value <= 3 && absolute_value >= 1
}
