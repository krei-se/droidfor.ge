# 🤖 Droidfor.ge 🩻

Bash Tutorial that actually makes sense

Dont use camelCase in bash, error prone in weak quoting.

Use small_snake vars if you don't plan to export outside the function or script

use UPPER_SNAKE vars if you export later.

source script.sh will include the script in the same context / process

./script.sh will spawn a new thread, thus not import any exports

## Functions

you cannot return Variables in bash, only return values 1 (error) and 0 (success). Echo all output and parse
an array if needed. See IFS for more on that

## Types

Bash is string only, all integer comparism with -gt and -lt are type-coercions

## Conditions

### Integers

    [ "$a" -eq "$b" ]   # Equal (==)
    [ "$a" -ne "$b" ]   # Not equal (!=)
    [ "$a" -lt "$b" ]   # Less than (<)
    [ "$a" -le "$b" ]   # Less than or equal (<=)
    [ "$a" -gt "$b" ]   # Greater than (>)
    [ "$a" -ge "$b" ]   # Greater than or equal (>=)

### Strings

    [ -z "$a" ]  # String is empty ("zero length")
    [ -n "$a" ]  # String is NOT empty
    [ "$a" = "$b" ]  # Strings are equal
    [ "$a" != "$b" ]  # Strings are NOT equal

### Files

    [ -f "$file" ]  # File exists AND is a regular file
    [ -d "$dir" ]   # Directory exists
    [ -e "$path" ]  # File or directory exists (anything)
    [ -s "$file" ]  # File exists AND is NOT empty
    [ -x "$file" ]  # File exists AND is executable
    [ -r "$file" ]  # File exists AND is readable
    [ -w "$file" ]  # File exists AND is writable

## Combos

    [ "$a" -gt 10 ] && [ "$b" -lt 5 ]   # AND condition
    [ "$a" -gt 10 ] || [ "$b" -lt 5 ]   # OR condition

### More readable combo

    if [[ "$a" -gt 10 && "$b" -lt 5 ]]; then
        echo "Both conditions are true"
    fi

## Vars

    echo $var   # Simple way
    echo ${var} # Best practice (prevents ambiguity)

    name="John"
    echo "Hello, $nameSmith"    # WRONG (looks for variable $nameSmith)
    echo "Hello, ${name}Smith"  # RIGHT (expands correctly)

### Expansion

    echo "\$HOME"  # Prints: $HOME (not expanded)
    echo '$HOME'   # Same: $HOME (no expansion)
    echo "$HOME"   # Expands to: /home/user

### Command substitution

    result=$(echo "Hello, World!")  # Captures "Hello, World!" into result


### Fallbacks

    echo ${var:-"default"}  # If var is empty, use "default"
    echo ${var:="default"}  # Same, but also assigns "default" to var

    unset var
    echo ${var:-"Hello"}  # Outputs: Hello
    echo $var             # Still empty

    echo ${var:="World"}  # Outputs: World
    echo $var             # Now it's set to "World"

### String Manipulation

    str="hello world"
    echo ${str/world/universe}   # Replace: "hello universe"
    echo ${str:6}                # Substring: "world"
    echo ${str:0:5}              # First 5 chars: "hello"

    echo ${#var}  # Outputs the length of $var
    name="Alice"
    echo ${#name}  # Outputs: 5

### Replace

    file="backup.tar.gz"        % shortest match at end, %% longest
    echo ${file%.gz}  # Remove .gz (suffix): backup.tar
    echo ${file##*.}  # Get file extension: gz
    echo ${file%%.*}  # Get base name: backup
    
    fullpath="folder/subfolder/file.txt" # shortest match at beginning, ## longest
    echo "${fullpath#*/}" # Output: subfolder/file.txt
    echo "${fullpath##*/} # Output: file.txt
    

# Multidimensional Arrays

### Bash 4 has declare -A

    declare -A matrix

    # Assign values like a 2D array
    matrix[0,0]="A"
    matrix[0,1]="B"
    matrix[1,0]="C"
    matrix[1,1]="D"

    # Access values
    echo "${matrix[0,0]}"  # A
    echo "${matrix[1,1]}"  # D

    # Loop through elements
    for key in "${!matrix[@]}"; do
        echo "$key = ${matrix[$key]}"
    done

### Ash on openwrt is very limited, use double indexed

    # Define row arrays
    row0=("A" "B")
    row1=("C" "D")

    # Create a "matrix" of references
    matrix=(row0 row1)

    # Access elements
    echo "${!matrix[0]}"        # Name of first row array (row0)
    echo "${matrix[0]}"         # row0 (array name)
    echo "${!matrix[1]}"        # row1

    # Access actual values
    echo "${row0[1]}"           # B
    echo "${row1[0]}"           # C
    echo "${!matrix[0]}[1]"     # row0[1] (as string)
    echo "${!matrix[0]}[@]"     # row0[@] (as string)

    # Proper way to access dynamically
    row_name="${matrix[0]}"      # Get row name
    echo "${row_name[1]}"        # FAILS: No multi-dimensional support
    echo "${!row_name[1]}"       # Correct: Indirect access

#### if you feel leet use eval for one-liners, like:

    secondvaluerow0=$(eval echo \${${matrix[0]}[1]}) # outputs B