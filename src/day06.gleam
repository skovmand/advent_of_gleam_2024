import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/set.{type Set}
import gleam/string
import simplifile
import wishbox

pub fn main() {
  wishbox.header("Day 6: Guard Gallivant")
  let assert Ok(input) = simplifile.read("puzzle_inputs/06.txt")
  let data = parse(input)

  wishbox.print_solution(part: 1, answer: part_1(data))
  wishbox.print_solution(part: 2, answer: part_2(data))
}

pub type Direction {
  North
  East
  South
  West
}

pub type ThingInField {
  Empty
  Guard(Direction)
  Obstruction
}

pub type ParsedData {
  ParsedData(
    map: Dict(#(Int, Int), ThingInField),
    guard_position: #(Int, Int),
    guard_direction: Direction,
  )
}

// PARSING

pub fn parse(input: String) -> ParsedData {
  let coord_list = coordinates_with_things(input)
  let #(guard_position, guard_direction) = find_guard(coord_list)
  let map = dict.from_list(coord_list)

  ParsedData(map, guard_position, guard_direction)
}

fn coordinates_with_things(input: String) -> List(#(#(Int, Int), ThingInField)) {
  input
  |> string.split("\n")
  |> list.index_map(fn(line, line_number) {
    string.split(line, "")
    |> list.index_map(fn(char, col_number) {
      let thing: ThingInField = case char {
        "#" -> Obstruction
        "^" -> Guard(North)
        ">" -> Guard(East)
        "v" -> Guard(South)
        "<" -> Guard(West)
        _ -> Empty
      }

      #(#(col_number, line_number), thing)
    })
  })
  |> list.flatten()
}

fn find_guard(
  coord_list: List(#(#(Int, Int), ThingInField)),
) -> #(#(Int, Int), Direction) {
  let assert Ok(coord_and_direction) =
    list.find_map(coord_list, fn(elem) {
      case elem {
        #(coords, Guard(direction)) -> Ok(#(coords, direction))
        _ -> Error(Nil)
      }
    })

  coord_and_direction
}

// SOLUTION

type State {
  State(
    map: Dict(#(Int, Int), ThingInField),
    guard_position: #(Int, Int),
    guard_direction: Direction,
    visited: Set(#(Int, Int)),
    visited_with_direction: Set(#(Int, Int, Direction)),
  )
}

fn build_initial_state(input: ParsedData) -> State {
  State(
    input.map,
    input.guard_position,
    input.guard_direction,
    visited: set.new() |> set.insert(input.guard_position),
    visited_with_direction: set.new()
      |> set.insert(#(
        input.guard_position.0,
        input.guard_position.1,
        input.guard_direction,
      )),
  )
}

pub fn part_1(input: ParsedData) -> Int {
  let initial_state = build_initial_state(input)
  let final_state = step_while_guard_in_map(initial_state)

  set.size(final_state.visited)
}

fn step_while_guard_in_map(state: State) -> State {
  let new_state: State = step(state)

  case dict.get(state.map, new_state.guard_position) {
    Error(_) -> new_state
    Ok(_) -> step_while_guard_in_map(new_state)
  }
}

fn step(state: State) -> State {
  let #(x, y) = state.guard_position

  let next_coordinate = case state.guard_direction {
    North -> #(x, y - 1)
    East -> #(x + 1, y)
    South -> #(x, y + 1)
    West -> #(x - 1, y)
  }

  case dict.get(state.map, next_coordinate) {
    Error(_) ->
      // Guard is leaving the map
      State(
        ..state,
        map: dict.insert(state.map, state.guard_position, Empty),
        guard_position: next_coordinate,
      )
    Ok(field) -> {
      case field {
        Empty -> {
          State(
            ..state,
            map: dict.insert(state.map, state.guard_position, Empty),
            guard_position: next_coordinate,
            visited: set.insert(state.visited, next_coordinate),
            visited_with_direction: set.insert(state.visited_with_direction, #(
              next_coordinate.0,
              next_coordinate.1,
              state.guard_direction,
            )),
          )
        }
        Obstruction -> {
          let new_direction = turn_right(state.guard_direction)

          State(
            ..state,
            guard_direction: new_direction,
            map: dict.insert(
              state.map,
              state.guard_position,
              Guard(new_direction),
            ),
            visited_with_direction: set.insert(state.visited_with_direction, #(
              x,
              y,
              new_direction,
            )),
          )
        }
        // TODO: Maybe don't model the guard here, this should never happen...
        Guard(_) -> state
      }
    }
  }
}

fn turn_right(direction: Direction) -> Direction {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

pub fn part_2(input: ParsedData) -> Int {
  let initial_state = build_initial_state(input)

  // Let the guard walk the map like in step 1, to see all the covered positions
  let final_state = step_while_guard_in_map(initial_state)

  final_state.visited
  |> set.to_list()
  |> list.map(fn(coord) {
    let modified_state =
      State(
        ..initial_state,
        map: dict.insert(initial_state.map, coord, Obstruction),
      )

    step_and_detect_loop(modified_state)
  })
  |> list.filter(function.identity)
  |> list.length()
}

fn step_and_detect_loop(state: State) -> Bool {
  let new_state: State = step(state)

  case dict.get(new_state.map, new_state.guard_position) {
    // The guard went off-map. In that case there was no loop
    Error(_) -> {
      False
    }
    // The guard either changed direction or moved to a new position
    Ok(_) -> {
      case
        set.contains(state.visited_with_direction, #(
          new_state.guard_position.0,
          new_state.guard_position.1,
          new_state.guard_direction,
        ))
      {
        // We have a loop: The old state had already visited that position with that direction
        True -> True
        // We haven't been here before. Keep walkin'
        False -> step_and_detect_loop(new_state)
      }
    }
  }
}
