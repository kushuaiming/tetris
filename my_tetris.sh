#!/bin/bash

QUIT=0
RIGHT=1
LEFT=2
ROTATE=3
DOWN=4
DROP=5

DELAY=1          # initial delay between piece movements
DELAY_FACTOR=0.8 # this value controld delay decrease for each level up

ticker() {
  while true; do 
    echo -n $DOWN;
    sleep $DELAY;
  done
}

reader() {
  # "-u" means When the variable is assigned a value,
  # all lower-case characters are converted to upper-case.
  local -u key command
  # "-a" means each name is an indexed array variable.
  # "-A" means each name is an associative array variable.
  declare -A commands=([A]=$ROTATE [C]=$RIGHT [D]=$LEFT)
  # "-s" means read in silent mode.
  # "-n" num means read only num's characters of input.
  while read -s -n 1 key; do
    echo -n $key
  done
}

controller() {
  local command
  while true; do
    read -s -n 1 command
    echo $command
  done
}

# "&" means ticker runs as separate process
(ticker & reader) | controller
