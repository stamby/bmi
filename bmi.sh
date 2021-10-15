#!/bin/sh

### BMI Calculator

usage() {
    cat << EOF
Usage: $0 FEET INCHES POUNDS
       $0 --metric CM KG
       $0 --uk FEET INCHES STONE POUNDS
EOF
    exit 1
}

case "$1" in
    --metric)
        SYSTEM=1
        [ $# = 3 ] || usage
        printf '%s' "$@" | grep -qxE '.-metric[0-9]+' || usage
        ;;
    --uk)
        SYSTEM=3
        [ $# = 5 ] || usage
        printf '%s' "$@" | grep -qxE '.-uk[0-9]+' || usage
        ;;
    *)
        SYSTEM=2
        [ $# = 3 ] || usage
        printf '%s' "$@" | grep -qxE '[0-9]+' || usage
        ;;
esac

set -- $@ 0 0

LANG=C LC_ALL=C exec bc << EOF
scale = 7

define lb_to_kg(x) {
    return 0.453592 * x
}

define stone_to_kg(x, y) {
    return lb_to_kg(14 * x + y)
}

define ft_in_to_cm(x, y) {
    return 2.54 * (12 * x + y)
}

if ($SYSTEM == 1) {
    height = $2
    weight = $3
}

if ($SYSTEM == 2) {
    height = ft_in_to_cm($1, $2)
    weight = lb_to_kg($3)
}

if ($SYSTEM == 3) {
    height = ft_in_to_cm($2, $3)
    weight = stone_to_kg($4, $5)
}

height /= 100

weight / height ^ 2
EOF
