#!/usr/bin/env bash
################################################################################
# Preview PS1 color pairs: INFO ascending, CONTEXT descending
################################################################################

RST='\033[0m'
GRY='\033[90m'
USER=$(whoami)
HOST=${DTC_FRIENDLY_NAME:-random-buildhost}
ARROW='└──>'

# Full spectrum: blue → cyan → green → yellow → orange → red
colors=(27 33 39 45 44 37 34 40 76 114 150 186 222 220 214 208 202 196 161 129)

n=${#colors[@]}
echo ""
for i in "${!colors[@]}"; do
    j=$(( n - 1 - i ))
    c=${colors[$i]}; w=${colors[$j]}
    I="\033[38;5;${c}m"; C="\033[38;5;${w}m"
    printf "  ${GRY}%2d${RST}) info=${I}%-3s${RST} ctx=${C}%-3s${RST}  " "$((i+1))" "$c" "$w"
    printf "%s@${I}%s${RST}:~ ${C}[main] (.venv)${RST} ${I}%s${RST}\n" "$USER" "$HOST" "$ARROW"
    echo ""
done
echo ""
