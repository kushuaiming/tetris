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
showtime=true    # controller runs while this flag is true

readonly PLAYFIELD_W=10
readonly PLAYFIELD_H=20
readonly PLAYFIELD_X=30
readonly PLAYFIELD_Y=1

# Location of "game over" in the end of the game
readonly GAMEOVER_X=1
readonly GAMEOVER_Y=$((PLAYFIELD_H + 3))

# screen_buffer is variable, that accumulates all screen changes
# this variable is printed in controller once per game cycle.
puts() {
  screen_buffer+=$1
}

# reference: https://en.wikipedia.org/wiki/ANSI_escape_code#CSIsection Cursor Position
readonly CSI='\033[' # Control Sequence Introducer
# Moves the cursor to row n, column m.
# m, n, cell content
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

next_piece=0
next_piece_rotation=0
next_piece_color=0

next_on=1 # if this flag is 1 next piece is shown

draw_next() {
    # Arguments: 1 - string to draw single cell
    ((next_on == -1)) && return
    draw_piece $NEXT_X $NEXT_Y $next_piece $next_piece_rotation "$1"
}

clear_next() {
    draw_next "${filled_cell//?/ }"
}

show_next() {
    set_fg $next_piece_color
    set_bg $next_piece_color
    draw_next "${filled_cell}"
    reset_colors
}

toggle_next() {
    case $next_on in
        1) clear_next; next_on=-1 ;;
        -1) next_on=1; show_next ;;
    esac
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

clear_current() {
    draw_current "${empty_cell}"
}

# Arguments:
#   1 - new x coordinate of the piece
#   2 - new y coordinate of the piece
new_piece_location_ok() {
    # test if piece can be moved to new location
    local j i x y x_test=$1 y_test=$2

    for ((j = 0, i = 1; j < 8; j += 2, i = j + 1)) {
        ((y = ${piece[$current_piece]:$((j + current_piece_rotation * 8)):1} + y_test)) # new y coordinate of piece cell
        ((x = ${piece[$current_piece]:$((i + current_piece_rotation * 8)):1} + x_test)) # new x coordinate of piece cell
        ((y < 0 || y >= PLAYFIELD_H || x < 0 || x >= PLAYFIELD_W )) && return 1         # check if we are out of the play field
        ((${play_field[y * PLAYFIELD_W + x]} != -1 )) && return 1                       # check if location is already ocupied
    }
    return 0
}

get_random_next() {
    # next piece becomes current
    current_piece=$next_piece
    current_piece_rotation=$next_piece_rotation
    current_piece_color=$next_piece_color
    # place current at the top of play field, approximately at the center
    ((current_piece_x = (PLAYFIELD_W - 4) / 2))
    ((current_piece_y = 0))
    # check if piece can be placed at this location, if not - game over
    new_piece_location_ok $current_piece_x $current_piece_y || cmd_quit
    show_current

    clear_next
    # now let's get next piece
    # reference 6.7 Arrays ${#name[subscript]}
    ((next_piece = RANDOM % ${#piece[@]}))
    ((next_piece_rotation = RANDOM % (${#piece[$next_piece]} / 8)))
    ((next_piece_color = RANDOM % ${#colors[@]}))
    show_next
}

# Move the piece to the new location if possible.
# Arguments:
#   new x coordinate, new y coordinate
move_piece() {
    if new_piece_location_ok $1 $2 ; then # if new location is ok
        clear_current                     # let's wipe out piece current location
        current_piece_x=$1                # update x ...
        current_piece_y=$2                # ... and y of new location
        show_current                      # and draw piece in new location
        return 0                          # nothing more to do here
    fi                                    # if we could not move piece to new location
    (($2 == current_piece_y)) && return 0 # and this was not horizontal move
    process_fallen_piece                  # let's finalize this piece
    get_random_next                       # and start the new one
    return 1
}

init() {
  local i x1 x2 y

  # playfield is initialized with -1s (empty cells)
  for ((i = 0; i < PLAYFIELD_H * PLAYFIELD_W; i++)) {
    play_field[$i]=-1
  }

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
  trap exit SIGUSR2 # this process exits on SIGUSR2
  trap '' SIGUSR1   # SIGUSR1 is ignored
  # "local -u" means when the variable is assigned a value,
  # all lower-case characters are converted to upper-case.
  local -u key a='' b='' cmd esc_ch=$'\x1b'
  # commands is associative array, which maps pressed keys to commands, sent to controller
  # "declare -a name" means each name is an indexed array variable.
  # "declare -A name" means each name is an associative array variable.
  declare -A commands=([A]=$ROTATE [C]=$RIGHT [D]=$LEFT
        [_S]=$ROTATE [_A]=$LEFT [_D]=$RIGHT
        [_]=$DROP [_Q]=$QUIT [_H]=$TOGGLE_HELP [_N]=$TOGGLE_NEXT [_C]=$TOGGLE_COLOR)
  # "read -s" means read in silent mode.
  # "read -n" num means read only num's characters of input.
  while read -s -n 1 key ; do
      case "$a$b$key" in
          "${esc_ch}["[ACD]) cmd=${commands[$key]} ;; # cursor key
          *${esc_ch}${esc_ch}) cmd=$QUIT ;;           # exit on 2 escapes
          *) cmd=${commands[_$key]:-} ;;              # regular key. If space was pressed $key is empty
      esac
      a=$b   # preserve previous keys
      b=$key
      [ -n "$cmd" ] && echo -n "$cmd"
  done
}

cmd_quit() {
    showtime=false                   # let's stop controller ...
    pkill -SIGUSR2 -f "/bin/bash $0" # ... send SIGUSR2 to all script instances to stop forked processes ...
    xyprint $GAMEOVER_X $GAMEOVER_Y "GAME OVER"
    echo -e "$screen_buffer"         # ... and print final message
}

cmd_right() {
    move_piece $((current_piece_x + 1)) $current_piece_y
}

cmd_left() {
    move_piece $((current_piece_x - 1)) $current_piece_y
}

cmd_rotate() {
    local available_rotations old_rotation new_rotation

    available_rotations=$((${#piece[$current_piece]} / 8))            # number of orientations for this piece
    old_rotation=$current_piece_rotation                              # preserve current orientation
    new_rotation=$(((old_rotation + 1) % available_rotations))        # calculate new orientation
    current_piece_rotation=$new_rotation                              # set orientation to new
    if new_piece_location_ok $current_piece_x $current_piece_y ; then # check if new orientation is ok
        current_piece_rotation=$old_rotation                          # if yes - restore old orientation
        clear_current                                                 # clear piece image
        current_piece_rotation=$new_rotation                          # set new orientation
        show_current                                                  # draw piece with new orientation
    else                                                              # if new orientation is not ok
        current_piece_rotation=$old_rotation                          # restore old orientation
    fi
}

cmd_down() {
    move_piece $current_piece_x $((current_piece_y + 1))
}

cmd_drop() {
    # move piece all way down
    # this is example of do..while loop in bash
    # loop body is empty
    # loop condition is done at least once
    # loop runs until loop condition would return non zero exit code
    while move_piece $current_piece_x $((current_piece_y + 1)) ; do : ; done
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
  while $showtime; do
    echo -ne "$screen_buffer" # output screen buffer ...
    screen_buffer=""          # ... and reset it
    read -s -n 1 command      # read next command from stdout
    ${commands[$command]}         # run command
  done
}

stty_g=`stty -g` # save terminal state

# output of ticker and reader is joined and piped into controller
# "&" means ticker runs as separate process
(
  ticker &
  reader
)|(
  controller
)

show_cursor
stty $stty_g # restore terminal state