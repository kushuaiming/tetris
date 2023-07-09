#!/bin/bash

QUIT=0
RIGHT=1
LEFT=2
ROTATE=3
DOWN=4
DROP=5

DELAY=1          # initial delay between piece movements
DELAY_FACTOR=0.8 # this value controld delay decrease for each level up

empty_cell=" ."  # how we draw empty cell
filled_cell="[]" # how we draw filled cell

# screen_buffer is variable, that accumulates all screen changes
# this variable is printed in controller once per game cycle
puts() {
  screen_buffer+=${1}
}

xyprint() {
    puts "\033[${2};${1}H${3}"
}

set_foreground() {
    puts "\033[3${1}m"
}

set_background() {
    puts "\033[4${1}m"
}

show_cursor() {
    echo -ne "\033[?25h"
}

hide_cursor() {
  # "echo -n" means do not output the trailing newline.
  # "echo -e" means enable interpretation of backslash escapes
  echo -ne "\033[?25l"
}

# this array holds all possible pieces that can be used in the game
# each piece consists of 4 cells
# each string is sequence of relative xy coordinates for different orientations
# depending on piece symmetry there can be 1, 2 or 4 orientations
piece=(
"00011011"                         # O piece
"0212223210111213"                 # I piece
"0001111201101120"                 # S piece
"0102101100101121"                 # Z piece
"01021121101112220111202100101112" # L piece
"01112122101112200001112102101112" # J piece
"01111221101112210110112101101112" # T piece
)

# Arguments:
#   x, y, type, rotation, cell content
draw_piece() {
  local i x y

  # loop through piece cells: 4 cells, each has 2 coordinates
  for ((i = 0; i < 8; i += 2)) {
      # relative coordinates are retrieved based on orientation and added to absolute coordinates
      ((x = $1 + ${piece[$3]:$((i + $4 * 8 + 1)):1} * 2))
      ((y = $2 + ${piece[$3]:$((i + $4 * 8)):1}))
      xyprint $x $y "$5"
  }
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

cmd_down() {
  xyprint 0 0 $filled_cell
}

controller() {
  init
  local command commands
  commands[$QUIT]=cmd_quit
  commands[$RIGHT]=cmd_right
  commands[$LEFT]=cmd_left
  commands[$ROTATE]=cmd_rotate
  commands[$DOWN]=cmd_down
  commands[$DROP]=cmd_drop
  commands[$TOGGLE_HELP]=toggle_help
  commands[$TOGGLE_NEXT]=toggle_next
  commands[$TOGGLE_COLOR]=toggle_color
  while true; do
    echo -ne "$screen_buffer" # output screen buffer ...
    screen_buffer=""          # ... and reset it
    read -s -n 1 command      # read next command from stdout
    ${commands[$command]}         # run command
  done
}

# "&" means ticker runs as separate process
(ticker & reader) | controller
