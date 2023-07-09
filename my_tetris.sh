#!/bin/bash

QUIT=0
RIGHT=1
LEFT=2
ROTATE=3
DOWN=4
DROP=5

DELAY=1          # initial delay between piece movements
DELAY_FACTOR=0.8 # this value controld delay decrease for each level up

hide_cursor() {
  # "echo -n" means do not output the trailing newline.
  # "echo -e" means enable interpretation of backslash escapes
  echo -ne "\033[?25l"
}

init() {
  clear
  hide_cursor
}

ticker() {
  while true; do 
    echo -n $DOWN;
    sleep $DELAY;
  done
}

reader() {
  # "local -u" means when the variable is assigned a value,
  # all lower-case characters are converted to upper-case.
  local -u key command
  # "declare -a name" means each name is an indexed array variable.
  # "declare -A name" means each name is an associative array variable.
  declare -A commands=([A]=$ROTATE [C]=$RIGHT [D]=$LEFT)
  # "read -s" means read in silent mode.
  # "read -n" num means read only num's characters of input.
  while read -s -n 1 key; do
    echo -n $key
  done
}

controller() {
  init
  local command
  while true; do
    read -s -n 1 command
    echo $command
  done
}

# "&" means ticker runs as separate process
(ticker & reader) | controller
