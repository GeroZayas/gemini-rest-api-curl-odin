# Demo Topic Index

Use this index to jump directly to the most relevant section of the bundled [demo.odin](./demo.odin) before scanning the full file.

## How to Use
- Match the user question to the closest topic below.
- Use the procedure name as the primary search key inside `demo.odin`.
- Use the listed approximate line range as the expected section anchor.
- Prefer the printed heading text when the procedure name is not obvious from the user prompt.

The ranges below are specific to the bundled copy of `demo.odin` in this skill and should be refreshed if that file changes.

## Core Language Sections

| Topic | Procedure | Heading | Approx. lines |
|---|---|---|---|
| Basics, literals, constants, assignment | `the_basics` | `the basics` | 45-145 |
| Control flow, loops, switch, defer, when | `control_flow` | `control flow` | 146-448 |
| Named return values | `named_proc_return_parameters` | `named proc return parameters` | 449-469 |
| Variadic procedures | `variadic_procedures` | `variadic procedures` | 470-491 |
| Explicit overloading | `explicit_procedure_overloading` | `explicit procedure overloading` | 492-525 |
| Structs | `struct_type` | `struct type` | 526-578 |
| Unions and `any` | `union_type` | `union type` | 579-752 |
| `using` statement and subtype-style composition | `using_statement` | `using statement` | 753-830 |
| Implicit context, allocators, context propagation | `implicit_context_system` | `implicit context system` | 831-883 |
| Parametric polymorphism, specialization, `where` | `parametric_polymorphism` | `parametric polymorphism` | 884-1150 |

## Collections, Data Types, and Operators

| Topic | Procedure | Heading | Approx. lines |
|---|---|---|---|
| Array programming and swizzles | `array_programming` | `array programming` | 1229-1279 |
| Maps | `map_type` | `map type` | 1280-1300 |
| Implicit selector expressions | `implicit_selector_expression` | `implicit selector expression` | 1301-1330 |
| Partial switch | `partial_switch` | `partial_switch` | 1331-1369 |
| `cstring` | `cstring_example` | `cstring_example` | 1370-1389 |
| Bit sets | `bit_set_type` | `bit_set type` | 1390-1452 |
| Deferred procedure associations | `deferred_procedure_associations` | `deferred procedure associations` | 1453-1470 |
| Reflection and struct tags | `reflection` | `reflection` | 1471-1505 |
| Quaternions | `quaternions` | `quaternions` | 1506-1554 |
| `#unroll for` | `unroll_for_statement` | `#'unroll for' statements` | 1555-1589 |
| `where` clauses | `where_clauses` | `procedure 'where' clauses` | 1590-1671 |
| Ranged array compound literals | `ranged_fields_for_array_compound_literals` | `ranged fields for array compound literals` | 1711-1755 |
| `@(deprecated)` usage | `deprecated_attribute` | no printed heading | 1756-1768 |
| Range statements with multi-return iterators | `range_statements_with_multiple_return_values` | `range statements with multiple return values` | 1769-1823 |
| SOA layouts, `soa_zip`, `soa_unzip` | `soa_struct_layout` | `SOA Struct Layout` | 1824-1946 |
| Constant literal expressions | `constant_literal_expressions` | `constant literal expressions` | 1947-2010 |
| Union-based maybe | `union_maybe` | `union based maybe` | 2011-2036 |
| `or_else` | `or_else_operator` | `'or_else'` | 2049-2078 |
| `or_return` | `or_return_operator` | `'or_return'` | 2079-2175 |
| `or_break` and `or_continue` | `or_break_and_or_continue_operators` | `'or_break' and 'or_continue'` | 2176-2238 |
| Arbitrary-precision math, `core:math/big` | `arbitrary_precision_mathematics` | `core:math/big` | 2239-2318 |
| Matrices | `matrix_type` | `matrix type` | 2319-2535 |
| Bit fields | `bit_field_type` | `bit_field type` | 2536-2579 |

## Systems, FFI, and Runtime Topics

| Topic | Procedure | Heading | Approx. lines |
|---|---|---|---|
| Threads and thread pools | `threading_example` | `threading_example` | 1151-1228 |
| Foreign system and external linkage | `foreign_system` | `foreign system` | 1672-1710 |
| Explicit context in non-`odin` calling conventions | `explicit_context_definition` | `explicit context definition` | 2041-2048 |

## Special Cases and Search Hints

- For thread pool questions, search within `threading_example` for `Thread Pool` around line 1196.
- For basic thread lifecycle questions, search within `threading_example` for `Basic Threads` around line 1160.
- For deprecation questions, search by the procedure name `deprecated_attribute`; that section does not print its own heading.
- For matrix intrinsics or storage details, prefer `matrix_type` and then inspect the explanatory comments in that section.
- For allocator and runtime context questions, start with `implicit_context_system`, then compare with `explicit_context_definition`.
- For polymorphism questions, choose `parametric_polymorphism`, `using_statement`, or `union_type` depending on whether the user means generics, embedding, or tagged unions.

## Coverage Note

This index is derived from the bundled demo file in this skill and is intended as a precise jump table, not a replacement for reading the actual section.