# AGENTS.md

## Purpose

`logo` generates the closurelab organization logo from Common Lisp source. The
source program will contain and read its own ASCII artwork, making the source's
layout the source of truth for the rendered SVG and PNG files.

## Nix workflow

- Always stage every intended flake input with Git before evaluating the
  flake. Git-backed flakes do not include untracked files.
- Run any required flake commands against the repository's Git-backed flake
  from the repository root.
- Never use a `path:` or `path://` flake URL. Path-backed flakes can copy large
  untracked or ignored files into the Nix store and waste substantial space.
- Use the `system` package-set attribute. This project does not cross-compile.

## Logo source

- Keep the entire Common Lisp source formatted as the ASCII artwork. The
  generator must read every source line and render every non-space character;
  do not introduce a marked artwork block or a separate data file.
- Treat generated SVG and PNG files as derived artifacts. Change the Common
  Lisp source and regenerate them instead of editing them directly.
- Preserve a recognizable `( lambda )` composition: the opening parenthesis
  resembles `C`, the closing parenthesis resembles a reversed `C`, and the
  center mark is a Greek lambda.
- Keep the palette in the purple family associated with the Haskell logo.
- Keep dependencies reproducible. Prefer the Common Lisp standard and tools
  supplied by the pinned Nix flake; do not introduce unpinned Quicklisp
  dependencies.

## Quality

- Use `nix develop` for the project toolchain and Git hooks.
- Run the narrowest relevant check first, then run the configured pre-commit
  hooks before finishing a change. Do not also run `nix flake check` when it
  would only repeat those hooks.
- Use the configured hooks to format and validate Nix and Markdown files and
  to lint commit messages.
- Commit titles must be at most 72 characters, end in a period, and match
  `^(chore|doc|fix|feat|infra|refac|revert): .+\.$`.
- Report what passed and anything that could not run.
