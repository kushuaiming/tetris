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

PLAYFIELD_W=10
PLAYFIELD_H=20
PLAYFIELD_X=30
PLAYFIELD_Y=1

# screen_buffer is variable, that accumulates all screen changes
# this variable is printed in controller once per game cycle.
puts() {
  screen_buffer+=$1
}

# reference: https://en.wikipedia.org/wiki/ANSI_escape_code#CSIsection Cursor Position
readonly CSI='\033[' # Control Sequence Introducer
xyprint() {
  puts "${CSI}${2};${1}H${3}"
}

set_foreground() {
  puts "${CSI}3${1}m"
}

set_background() {
  puts "${CSI}4${1}m"
}

reset_colors() {
  puts "${CSI}0m"
}

show_cursor() {
  echo -ne "${CSI}?25h"
}

hide_cursor() {
  # "echo -n" means do not output the trailing newline.
  # "echo -e" means enable interpretation of backslash escapes
  echo -ne "${CSI}?25l"
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
    # reference: 3.5.3 shell parameter expansion, ${parameter:offset:length}
    # reference: 3.5.5 arithmetic expansion, $((expression))
    ((x = $1 + ${piece[$3]:$((i + $4 * 8 + 1)):1} * 2))
    ((y = $2 + ${piece[$3]:$((i + $4 * 8)):1}))
    xyprint $x $y "$5"
  }
}


current_piece_x=0
current_piece_y=0
current_piece=0
current_piece_rotation=0
# Arguments:
#   1-string to draw single cell
draw_current() {
  # factor 2 for x because each cell is 2 characters wide
  draw_piece $((current_piece_x * 2 + PLAYFIELD_X)) $((current_piece_y + PLAYFIELD_Y)) $current_piece $current_piece_rotation "$1"
}

current_piece_color=0
show_current() {
  set_foreground $current_piece_color
  set_background $current_piece_color
  draw_current "${filled_cell}"
  reset_colors
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
# (ticker & reader) | controller
init
show_current
echo -e "$screen_buffer"

show_cursor