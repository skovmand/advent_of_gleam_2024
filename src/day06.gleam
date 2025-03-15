import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/option.{None, Some}
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

pub type Point2D =
  #(Int, Int)

pub type Guard {
  Guard(position: Point2D, direction: Direction)
}

pub type Map =
  Dict(Point2D, Thing)

pub type Thing {
  Empty
  Obstruction
}

// PARSING

pub fn parse(input: String) -> #(Map, Guard) {
  let assert #(map, Some(guard)) =
    input
    |> string.split("\n")
    |> list.index_fold(
      from: #(dict.new(), None),
      with: fn(map_and_guard, line, y) {
        line
        |> string.split("")
        |> list.index_fold(
          from: map_and_guard,
          with: fn(map_and_guard, char, x) {
            let #(map, guard) = map_and_guard

            case char {
              "#" -> #(dict.insert(map, #(x, y), Obstruction), guard)
              "." -> #(dict.insert(map, #(x, y), Empty), guard)
              "^" -> #(
                dict.insert(map, #(x, y), Empty),
                Some(Guard(#(x, y), North)),
              )
              _ -> #(map, guard)
            }
          },
        )
      },
    )

  #(map, guard)
}

// PART 1

type State {
  State(map: Map, guard: Guard, seen_positions: Set(Point2D))
}

fn build_initial_state(map: Map, guard: Guard) -> State {
  State(map, guard, seen_positions: set.insert(set.new(), guard.position))
}

pub fn part_1(parsed_data: #(Map, Guard)) -> Int {
  let #(map, guard) = parsed_data

  let final_state =
    build_initial_state(map, guard)
    |> step_while_guard_in_map()

  set.size(final_state.seen_positions)
}

fn step_while_guard_in_map(state: State) -> State {
  let new_state: State = step(state)

  case dict.get(state.map, new_state.guard.position) {
    Error(_) -> new_state
    Ok(_) -> step_while_guard_in_map(new_state)
  }
}

fn step(state: State) -> State {
  let next_coordinate = next_coordinate_from_direction(state.guard)

  case dict.get(state.map, next_coordinate) {
    Error(_) ->
      // Guard is leaving the map
      State(..state, guard: Guard(..state.guard, position: next_coordinate))
    Ok(field) -> {
      case field {
        Empty -> {
          State(
            ..state,
            guard: Guard(..state.guard, position: next_coordinate),
            seen_positions: set.insert(state.seen_positions, next_coordinate),
          )
        }
        Obstruction -> {
          State(..state, guard: turn_right(state.guard))
        }
      }
    }
  }
}

fn next_coordinate_from_direction(guard: Guard) -> Point2D {
  let #(x, y) = guard.position
  case guard.direction {
    North -> #(x, y - 1)
    East -> #(x + 1, y)
    South -> #(x, y + 1)
    West -> #(x - 1, y)
  }
}

fn turn_right(guard: Guard) -> Guard {
  let new_direction = case guard.direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }

  Guard(..guard, direction: new_direction)
}

// PART 2

type State2 {
  State2(map: Map, guard: Guard, seen_guards: Set(Guard))
}

fn build_initial_state_2(map: Map, guard: Guard) {
  State2(map: map, guard: guard, seen_guards: set.insert(set.new(), guard))
}

pub fn part_2(parsed_data: #(Map, Guard)) -> Int {
  let #(map, guard) = parsed_data

  // Let the guard walk the map like in step 1, to see all the covered positions
  let initial_state: State = build_initial_state(map, guard)
  let seen_positions: Set(Point2D) =
    step_while_guard_in_map(initial_state).seen_positions

  seen_positions
  |> set.to_list()
  |> list.map(fn(coord) {
    let modified_map = dict.insert(map, coord, Obstruction)
    let modified_state = build_initial_state_2(modified_map, guard)

    is_loop(modified_state)
  })
  |> list.filter(function.identity)
  |> list.length()
}

fn is_loop(state: State2) -> Bool {
  let new_state: State2 = step_2(state)

  case dict.get(new_state.map, new_state.guard.position) {
    // The guard went off-map. In that case there was no loop
    Error(_) -> {
      False
    }
    // The guard either changed direction or moved to a new position
    Ok(_) -> {
      // Look if the previous state had already seen this Guard? (Not the new state, since that obviously has)
      case set.contains(state.seen_guards, new_state.guard) {
        // We have a loop: The old state had already visited that position with that direction
        True -> True
        False -> is_loop(new_state)
      }
    }
  }
}

// Just like step 1, but keep track of guards instead of positions
fn step_2(state: State2) -> State2 {
  let next_coordinate = next_coordinate_from_direction(state.guard)

  case dict.get(state.map, next_coordinate) {
    Error(_) ->
      // Guard is leaving the map
      State2(..state, guard: Guard(..state.guard, position: next_coordinate))
    Ok(field) -> {
      case field {
        Empty -> {
          let next_guard = Guard(..state.guard, position: next_coordinate)

          State2(
            ..state,
            guard: next_guard,
            seen_guards: set.insert(state.seen_guards, next_guard),
          )
        }
        Obstruction -> {
          let new_guard = turn_right(state.guard)

          State2(
            ..state,
            guard: turn_right(state.guard),
            seen_guards: set.insert(state.seen_guards, new_guard),
          )
        }
      }
    }
  }
}
