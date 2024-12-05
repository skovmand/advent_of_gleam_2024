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

  wishbox.print_solution(part: 1, answer: part1(input))
  // wishbox.print_solution(part: 2, answer: part2(input))
}

pub fn part1(input: String) -> Int {
  let Input(page_ordering_rules, print_jobs) = parse(input)
  count_valid_print_jobs(page_ordering_rules, print_jobs)
}

// pub fn part2(input: String) -> Int {
//   let assert Ok(parsed) = parse(input)
//   list.fold(parsed, 0, fn(a, b) { a + b })
// }

// -- Implementation --->

pub type Page =
  Int

pub type PageOrderingRules =
  Dict(Page, Set(Page))

pub type PrintJob {
  PrintJob(List(Page))
}

pub type Day05Input {
  Input(page_ordering_rules: PageOrderingRules, print_jobs: List(PrintJob))
}

pub fn parse(input: String) -> Day05Input {
  let assert [page_ordering_rule_lines, update_lines] =
    string.split(input, "\n\n")

  let page_ordering_rules =
    wishbox.parse_lines(page_ordering_rule_lines, parse_ordering_rule_line)
    |> build_page_ordering_rules()

  let assert Ok(updates) =
    wishbox.try_parse_lines(update_lines, parse_update_line)

  Input(page_ordering_rules, updates)
}

fn parse_ordering_rule_line(line: String) -> #(Int, Int) {
  let assert [a, b] = string.split(line, "|")
  let assert Ok(a) = int.parse(a)
  let assert Ok(b) = int.parse(b)

  #(a, b)
}

fn build_page_ordering_rules(
  single_rules: List(#(Int, Int)),
) -> PageOrderingRules {
  single_rules
  // Group by the page that is described
  |> list.group(fn(rule) { rule.1 })
  // Collect the pages that must come before in a set
  |> dict.map_values(fn(_page: Page, rules: List(#(Page, Page))) {
    rules
    |> list.map(fn(rule: #(Page, Page)) { rule.0 })
    |> set.from_list
  })
}

fn parse_update_line(line: String) -> Result(PrintJob, Nil) {
  line
  |> string.split(",")
  |> list.map(int.parse)
  |> result.all
  |> result.map(PrintJob)
}

fn count_valid_print_jobs(page_ordering_rules, print_jobs) -> Int {
  list.filter(print_jobs, fn(print_job) {
    is_print_job_valid(print_job, page_ordering_rules)
  })
  |> list.map(get_middle_number)
  |> int.sum()
}

fn get_middle_number(list: PrintJob) -> Int {
  let PrintJob(list) = list
  let length = list.length(list)
  let half_length = length / 2
  let assert Ok(e) = list |> list.drop(half_length) |> list.first()
  e
}

type Accumulator {
  ValidPrintJob(already_printed: Set(Page))
  InvalidPrintJob
}

fn is_print_job_valid(
  print_job: PrintJob,
  page_ordering_rules: PageOrderingRules,
) -> Bool {
  let PrintJob(pages) = print_job
  let all_pages_in_print_job: Set(Page) = set.from_list(pages)

  let result: Accumulator =
    list.fold_until(
      pages,
      ValidPrintJob(already_printed: set.new()),
      fn(acc, page) {
        let already_printed = case acc {
          InvalidPrintJob -> todo
          ValidPrintJob(already_printed) -> already_printed
        }

        case dict.get(page_ordering_rules, page) {
          // No requirements
          Error(_) ->
            Continue(
              ValidPrintJob(already_printed: set.insert(already_printed, page)),
            )
          Ok(pages_that_must_be_printed_before) -> {
            // Only match on the pages in the print job
            let filtered_set =
              set.filter(pages_that_must_be_printed_before, fn(page) {
                set.contains(all_pages_in_print_job, page)
              })

            case set.is_subset(filtered_set, of: already_printed) {
              True ->
                Continue(
                  ValidPrintJob(already_printed: set.insert(
                    already_printed,
                    page,
                  )),
                )
              False -> Stop(InvalidPrintJob)
            }
          }
        }
      },
    )

  case result {
    InvalidPrintJob -> False
    ValidPrintJob(_) -> True
  }
}
//
// Set 1: Already printed
// Set 2: All pages in the print job
// Dict of page number -> set of pages that must be printed before it
//
// Algo:
// Go over the list of pages
// For each page number, look up which pages must be printed before it. Discard the ones not in the print job.
// Check if the pages have already been printed. If not, fail. Otherwise, continue.
//
// Example:
// Set 1: []
// Set 2: [75, 47, 61, 53, 29]
// Dict: 75: [97], 47: [97, 75], ...
//
// 1)
// First number is 75
// Look up the list of pages that must be printed before 75, which is 97
// Check if 97 is in the print job. It is not, so discard it.
// Check if [] has pages that must be printed before it. Add 75 to already printed.
//
// 2)
// Second number is 47
// Look up the pages that must be printed before 47, which is 97 and 75
// Discard the ones not in the print job. Leaves us with 75.
// Check if 75 is already printed, which it is. Add 47 to the already printed.
//
// 3) Next is.....
