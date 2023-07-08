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
  while true; do echo -n $DOWN; sleep $DELAY; done
}

reader() {
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

(ticker & reader) | controller
