# Naive Parsing of Context-Free Grammars

## Overview
This project implements a simple parser generator for context-free grammars (CFGs). The goal is to test proposed grammars by generating a parser function that can verify whether a given input string conforms to a specified grammar. This parser uses a matcher-based approach to test multiple rules and backtrack if necessary. The key components are a matcher and a parser, both of which traverse a grammar's structure to determine if an input string matches it. Project for UCLA CS 131 class.

## Features
- **Grammar Conversion (`convert_grammar`)**: Converts a Homework 1-style grammar into the format used in this assignment, enabling compatibility with the parsing functions.
- **Parse Tree Leaves (`parse_tree_leaves`)**: Extracts the terminal symbols (leaves) from a parse tree, traversing it in a preorder fashion.
- **Matcher (`make_matcher`)**: Generates a matcher for a given grammar, which checks whether a prefix of a given string matches any rules in the grammar.
- **Parser (`make_parser`)**: Generates a parser for a given grammar, which checks if an entire input string matches the grammar, returning a parse tree if successful.

## Functions
### `convert_grammar`
Converts a grammar from Homework 1 format to Homework 2 format. The converted grammar is used by `make_matcher` and `make_parser`.

#### Example Usage:
```ocaml
let awksub_grammar = (Expr, [Expr, [[N Term; N Binop; N Expr]; [N Term]]])
let awksub_grammar_2 = convert_grammar awksub_grammar
```

### `parse_tree_leaves`
Traverses a parse tree and returns a list of terminal symbols (leaves) encountered, in left-to-right order.

#### Example Usage:
```ocaml
parse_tree_leaves (Node ("+", [Leaf 3; Node ("*", [Leaf 4; Leaf 5])]))
(* Output: [3; 4; 5] *)
```

### `make_matcher`
Generates a matcher function for a given grammar. The matcher checks whether a prefix of a string matches any of the grammar's rules. If it finds a match, it returns the remaining suffix; otherwise, it returns `None`.

#### Example Usage:
```ocaml
let accept_all = Some
let awkish_grammar = (* as defined in the assignment *)
make_matcher awkish_grammar accept_all ["9"; "+"; "$"; "1"; "+"]
(* Output: Some ["+"] *)
```

### `make_parser`
Generates a parser for a given grammar. The parser checks whether an entire input string matches the grammar and returns an optional parse tree.

#### Example Usage:
```ocaml
let small_awk_frag = ["$"; "1"; "++"; "-"; "2"]
make_parser awkish_grammar small_awk_frag
(* Output: Some (Node (Expr, [Node (Term, ...)])) *)
```

### Test Functions
- **`make_matcher_test`**: A custom test case to validate the `make_matcher` function on a unique grammar.
- **`make_parser_test`**: A custom test case for the `make_parser` function, ensuring that the parse tree leaves match the input fragment.

## Files
1. **`hw2.ml`**: Contains the main implementation, including `convert_grammar`, `parse_tree_leaves`, `make_matcher`, and `make_parser`.
2. **`hw2test.ml`**: Contains test cases for the `make_matcher` and `make_parser` functions.
3. **`hw2.txt`**: A plain text file with an after-action report, explaining design choices, weaknesses, and the reasoning behind the implementation.

## Running the Code
To test the implementation:
1. Ensure OCaml is installed.
2. Load the files in the OCaml REPL:
   ```bash
   ocaml
   # #use "hw2.ml";;
   # #use "hw2test.ml";;
   ```

This will execute the test cases and validate the behavior of the parser and matcher functions.

## Notes
- **Grammar Rules**: The matcher tries rules left-to-right and backtracks when necessary. The parser generates a parse tree if the entire input matches the grammar.
- **Limitations**: The parser may struggle with ambiguous grammars or those with significant backtracking requirements. These limitations are discussed further in the after-action report.

## Example Grammar: Awkish Grammar
The following is an example grammar for a small subset of Awk-like syntax:
```ocaml
type awksub_nonterminals = Expr | Term | Lvalue | Incrop | Binop | Num

let awkish_grammar = 
  (Expr, function
     | Expr -> [[N Term; N Binop; N Expr]; [N Term]]
     | Term -> [[N Num]; [N Lvalue]; [N Incrop; N Lvalue]; [N Lvalue; N Incrop]; [T "("; N Expr; T ")"]]
     | Lvalue -> [[T "$"; N Expr]]
     | Incrop -> [[T "++"]; [T "--"]]
     | Binop -> [[T "+"]; [T "-"]]
     | Num -> [[T "0"]; [T "1"]; [T "2"]; [T "3"]; [T "4"]; [T "5"]; [T "6"]; [T "7"]; [T "8"]; [T "9"]])
```