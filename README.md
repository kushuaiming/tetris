# Tetris
## Pipeline
ticker: move down pieces automaticly  
reader: read command from keyboard  
controller: execute command  
## Read Command From Keyboard
- `read -s -n 1 command`: read in silent mode and read only one characters of input.
- Use *escape char* to process the arrow key.

|  Glyph  |  Char  |
|  :--:  | ----  |
| ESC | `^[`, `\x1b`, `\e[`, `\033[` |
| ↑ | `^[[A` |
| ↓ | `^[[B` |
| ← | `^[[D` |
| → | `^[[C` |
## Draw Piece
[ANSI escape code](https://en.wikipedia.org/wiki/ANSI_escape_code)  

Control Sequence
|  Code  |  Effect  |
|  :--:  |  :-----  |
| `ESC [` | CSI|
| `CSI n; m H` | Cursor Position, Moves the cursor to row n, column m. |
| `CSI ? 25 h` | Show the cursor. |
| `CSI ? 25 l` | Hide the cursor. |
| `CSI n m` | Sets colors and style of the characters following this code, see SGR for n |

SGR (Select Graphic Rendition) parameters
|*n*|Name|
|:--:|:--:|
|0|Reset or nomal|
|1|Bold|

The char below shows the default values sent to the DAC for some common hardware and software.
| FG | BG | Name |
|:--:|:--:|:--:|
| 30 | 40 | Black |
| 31 | 41 | Red |
| 32 | 42 | Green |
| 33 | 43 | Yellow |
| 34 | 44 | Blue |
| 35 | 45 | Magenta |
| 36 | 46 | Cyan |
| 37 | 47 | White |

The play field is a rectangle which has PLAYFIELD_W width and PLAYFIELD_H height add represented with a one dimensional array play_field which initialized with -1.  
The origin point is on the upper left corner of the rectangel.  
The x axis is from left to right, and y axis is from upper to down.  
0────────────────────x  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
│-1-1-1-1-1-1-1-1-1-1  
y  
## Shell Commands
- `echo -e`: enable interpretation of backslash escapes
- `echo -n`: echo without a newline
- `local -u`: when the variable is assigned a value, all lower-case characters are converted to upper-case.
- `declare -a name`: each name is an indexed array variable.
- `declare -A name`: each name is an associative array variable.
- array, see *6.7 Arrays*<sup>[1]</sup>.
  - Any element of an array may be referenced using `${name[subscript]}`.
  - If the subscript is ‘@’ or ‘*’, the word expands to all members of the array name.
  - `${name[@]}` expands each element of name to a separate word.
  - `${#name[subscript]}` expands to the length of `${name[subscript]}`. If subscript is ‘@’ or ‘*’, the expansion is the number of elements in the array.
  - *3.5.3 shell parameter expansion*<sup>[1]</sup>, `${parameter:offset:length}`
  - *3.5.5 arithmetic expansion*<sup>[1]</sup>, `$((expression))`
- *3.7.5 Exit Status*<sup>[1]</sup>, If a command fails because of an error during expansion or redirection, the exit status is greater than zero.
- *3.2.4 Lists of Commands*<sup>[1]</sup>
  - `command1 && command2`, command2 is executed if, and only if, command1 returns an exit status of **zero** (success).
  - `command1 || command2`, command2 is executed if, and only if, command1 returns a non-zero exit status.
- *3.5.3 Shell Parameter Expansion*<sup>[1]</sup>, `${parameter//pattern/string}`
- ($?) Expands to the exit status of the most recently executed foreground pipeline
## Signals
- You can use `kill -l` to display a complete list of signals.  
- Two signals are used in this script, SIGUSR1 to decrease delay after level up and SIGUSR2 to quit.  
- `awk` is a tool for text processing.  
- `awk pattern {action}`
- `trap` is used to trap signals and other envents.
## Reference
[1][Bash Reference Manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)  
[2][Shell Style Guide](https://google.github.io/styleguide/shellguide.html)