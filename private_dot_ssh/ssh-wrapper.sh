#!/bin/sh
# Workaround for Windows OpenSSH 9.5 bug:
# Non-interactive SSH exits with "close - IO is still pending on closed socket"
# after successful operations. This wrapper detects that message and returns
# exit code 0 unless a real auth failure (Permission denied) is also present.

ssh="C:/Windows/System32/OpenSSH/ssh.exe"
stderr_file=$(mktemp)

"$ssh" "$@" 2>"$stderr_file"
exit_code=$?

if [ $exit_code -ne 0 ]; then
  if grep -q 'close - IO is still pending on closed socket' "$stderr_file"; then
    if grep -q 'Permission denied' "$stderr_file"; then
      cat "$stderr_file" >&2
      rm -f "$stderr_file"
      exit $exit_code
    fi
    grep -v 'close - IO is still pending on closed socket' "$stderr_file" >&2
    rm -f "$stderr_file"
    exit 0
  fi
fi

cat "$stderr_file" >&2
rm -f "$stderr_file"
exit $exit_code
