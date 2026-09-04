# closurelab logo

This repository generates the closurelab organization logo from the ASCII art
inside [`src/logo.lisp`](src/logo.lisp). The program reads its own source at
runtime, extracts the marked artwork, and converts its character grid into
vector geometry. Changing the artwork's spacing or characters therefore
changes the rendered logo.

The source uses three palette characters:

| Character | Shape               | Color     |
| --------- | ------------------- | --------- |
| `C`       | Opening parenthesis | `#453A62` |
| `L`       | Greek lambda        | `#5E5086` |
| `R`       | Closing parenthesis | `#8F4E8B` |

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
