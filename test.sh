#!/bin/bash
if [[ $(type shellcheck) ]]; then
  find . -name "*.sh" -exec shellcheck '{}' \;
else 
  echo "Shellcheck not installed."
  echo "run: brew install shellcheck"
fi

