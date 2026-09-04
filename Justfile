default:
    @just --list

# Regenerate the tracked SVG and PNG from the Common Lisp source.
generate output-directory="assets":
    closurelab-logo "{{ output-directory }}"

# Run every configured pre-commit hook.
check:
    pre-commit run --all-files
