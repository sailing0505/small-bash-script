
#!/bin/bash
E_BADDIR=85
var=nonexistent_directory
error()
{
printf "$@" >&2
# Formats positional params passed, and sends them to stderr.
echo
exit $E_BADDIR
}
#cd $var || error $"Can't cd to %s." "$var"


# printf demo
declare -r PI=3.14159265358979
declare -r DecimalConstant=31373
# Read-only variable, i.e., a constant.
Message1="Greetings,"
Message2="Earthling."
echo
printf "Pi to 2 decimal places = %1.2f" $PI
echo
printf "Pi to 9 decimal places = %1.9f" $PI
# It even rounds off correctly.
printf "\n" # Prints a line feed,
# Equivalent to 'echo' . . .
printf "Constant = \t%d\n" $DecimalConstant # Inserts tab (\t).
printf "%s %s \n" $Message1 $Message2
echo
# ==========================================#
# Simulation of C function, sprintf().
# Loading a variable with a formatted string.
echo
Pi12=$(printf "%1.12f" $PI)
echo "Pi to 12 decimal places = $Pi12"
# Roundoff error!
Msg=`printf "%s %s \n" $Message1 $Message2`
echo $Msg; echo $Msg
# As it happens, the 'sprintf' function can now be accessed
#+ as a loadable module to Bash,
#+ but this is not portable.
exit 0
