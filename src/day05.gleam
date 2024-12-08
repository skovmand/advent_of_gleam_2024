/// --- Day 5: Print Queue ---
///
import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("--- Day 5: Print Queue ---")
  let assert Ok(input) = simplifile.read(from: "puzzle_inputs/05.txt")

  let parsed = parse(input)
  wishbox.print_solution(part: 1, answer: part1(parsed))
  wishbox.print_solution(part: 1, answer: part2(parsed))
}

pub fn part1(input: Day05Input) -> Int {
  let Input(ordering_rules, print_jobs) = input
  count_valid_print_jobs(ordering_rules, print_jobs)
}

pub fn part2(input: Day05Input) -> Int {
  let Input(ordering_rules, print_jobs) = input
  sum_of_reordered_print_jobs(ordering_rules, print_jobs)
}

// -- Parsing --->

pub type Page =
  Int

pub type PageOrderingRules =
  Dict(Page, Set(Page))

pub type PrintJob =
  List(Page)

pub type Day05Input {
  Input(ordering_rules: PageOrderingRules, print_jobs: List(PrintJob))
}

pub fn parse(input: String) -> Day05Input {
  let assert [page_ordering_rule_lines, update_lines] =
    string.split(input, "\n\n")

  let ordering_rules: PageOrderingRules =
    {
      use line <- wishbox.parse_lines(page_ordering_rule_lines)
      let assert [a, b] = string.split(line, "|")
      let assert Ok(a) = int.parse(a)
      let assert Ok(b) = int.parse(b)
      #(a, b)
    }
    |> build_page_ordering_rules()

  let assert Ok(updates) = {
    use line <- wishbox.try_parse_lines(update_lines)
    line
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
  }

  Input(ordering_rules, updates)
}

/// Build a lookup from page to the set of pages that must come before it
fn build_page_ordering_rules(
  single_rules: List(#(Int, Int)),
) -> PageOrderingRules {
  single_rules
  |> list.group(fn(rule) { rule.1 })
  |> dict.map_values(fn(_page: Page, rules: List(#(Page, Page))) {
    rules
    |> list.map(fn(rule) { rule.0 })
    |> set.from_list()
  })
}

// -- Solutions --->

fn count_valid_print_jobs(ordering_rules, print_jobs) -> Int {
  list.filter(print_jobs, fn(job) { is_print_job_valid(job, ordering_rules) })
  |> list.map(get_middle_number)
  |> int.sum()
}

/// Getting the middle number in a linked list sucks
fn get_middle_number(list: PrintJob) -> Int {
  let half_length = list.length(list) / 2
  let assert Ok(middle_number) = list |> list.drop(half_length) |> list.first()
  middle_number
}

type Accumulator {
  ValidPrintJob(printed: Set(Page))
  InvalidPrintJob(printed: Set(Page))
}

fn is_print_job_valid(
  print_job: PrintJob,
  ordering_rules: PageOrderingRules,
) -> Bool {
  let all_pages_in_print_job: Set(Page) = set.from_list(print_job)

  let result: Accumulator =
    list.fold_until(print_job, ValidPrintJob(printed: set.new()), fn(acc, page) {
      case dict.get(ordering_rules, page) {
        Error(_) ->
          // No pages need to come before this one
          Continue(ValidPrintJob(printed: set.insert(acc.printed, page)))
        Ok(raw_required_preceding_pages) -> {
          // First remove the pages that are not even in the print job
          let required_preceding_pages =
            set.filter(raw_required_preceding_pages, fn(page) {
              set.contains(all_pages_in_print_job, page)
            })

          // Are the requirements fulfilled?
          case set.is_subset(required_preceding_pages, of: acc.printed) {
            True ->
              Continue(ValidPrintJob(printed: set.insert(acc.printed, page)))
            False -> Stop(InvalidPrintJob(printed: acc.printed))
          }
        }
      }
    })

  case result {
    InvalidPrintJob(_) -> False
    ValidPrintJob(_) -> True
  }
}

//
// Part 2:
//
// Taking a look at the example input, it looks like every pair of numbers has a rule,
// and that each print job has exactly one correct order.
//
// So, hoping this is the case in the puzzle input too, we can fix it like this:
// First, remove all the correct print jobs. Then for the rest:
//
// 1. Make a set of all pages in the print job
// 2. Create a dict by mapping over the pages in the print job:
//   - Look up which pages must be printed before the page and remove the
//     pages that are not in the print job.
//   - If there are none, this number is first in the print job. Insert 0 => page in the dict.
//   - Basically, this means we can count how many pages are before a given page number
//     and that amount of pages will signify the position of the page in the print job.
//     Count how many pages come before the page, and insert x => page in the dict.
//   - Recreate the print job by sorting the dict by key and getting the values
//

fn sum_of_reordered_print_jobs(ordering_rules, print_jobs) -> Int {
  list.filter(print_jobs, fn(job) { !is_print_job_valid(job, ordering_rules) })
  |> list.map(fn(print_job) { reorder_print_job(print_job, ordering_rules) })
  |> list.map(get_middle_number)
  |> int.sum()
}

fn reorder_print_job(
  print_job: PrintJob,
  ordering_rules: PageOrderingRules,
) -> PrintJob {
  let all_pages_in_print_job: Set(Page) = set.from_list(print_job)

  let page_positions: Dict(Int, Page) =
    list.fold(print_job, dict.new(), fn(acc, page) {
      case dict.get(ordering_rules, page) {
        Error(_) ->
          // No pages need to come before this one
          dict.insert(acc, 0, page)
        Ok(raw_required_preceding_pages) -> {
          // First remove the pages that are not even in the print job
          let required_preceding_pages =
            set.filter(raw_required_preceding_pages, fn(page) {
              set.contains(all_pages_in_print_job, page)
            })

          dict.insert(acc, set.size(required_preceding_pages), page)
        }
      }
    })

  dict.to_list(page_positions)
  |> list.sort(by: fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(position_and_page) { position_and_page.1 })
}
