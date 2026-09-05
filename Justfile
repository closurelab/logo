default:
    @just --list

# Regenerate the SVG and PNG from the current Common Lisp source.
generate output-directory="assets":
    nix run . -- "{{ output-directory }}"

# Run every configured pre-commit hook.
check:
    pre-commit run --all-files
