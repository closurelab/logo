# closurelab logo

This repository generates the closurelab organization logo from
[`src/logo.lisp`](src/logo.lisp). The complete file is both executable Common
Lisp and ASCII art: the program reads its own source and converts every
non-space character into vector geometry. There is no separately marked
artwork block, so changing the source formatting changes the rendered logo.

Color is assigned by source-code region:

| Source columns | Shape               | Color     |
| -------------- | ------------------- | --------- |
| Left third     | Opening parenthesis | `#453A62` |
| Middle third   | Greek lambda        | `#5E5086` |
| Right third    | Closing parenthesis | `#8F4E8B` |

The SVG has a square view box derived from the source-art dimensions. The PNG
is a transparent 1024 by 1024 RGBA rendering of that SVG.

## Generate the logo

Enter the pinned development environment and generate the files under the
ignored `assets` directory:

```console
$ nix develop
$ just generate
```

The generator can also be run directly without entering the shell. Its sole
optional argument is the output directory, which defaults to `build`:

```console
$ nix run . -- build
```

Run `nix build` to generate the artifacts in the Nix store and expose them
through the `result` symlink.

Run every configured formatting and lint hook with:

```console
$ just check
```

All runtime and development dependencies are supplied by the locked Nix flake;
the Common Lisp source has no Quicklisp dependencies.
