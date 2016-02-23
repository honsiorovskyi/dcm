#!/bin/sh

#
# USAGE:
#   ./build.sh          - to build
#   ./build.sh --clean  - to remove build results
#

in_file=dcm.sh
out_file=dcm

# cleaning
if [ "$1" = "--clean" ]; then
    rm $out_file
    exit
fi

# truncate output
truncate --size 0 $out_file

# rewrite output
while read line; do
    # matches only lines in format 'source ...'
    src=$(echo $line | sed -e 's/^\s*source\s*\(.*\)$/\1/gp;d')

    if [ -z $src ]; then
        # copy string 'as is'
        echo $line >> $out_file
    else
        # replace string with the file contents
        cat $src | grep -v '^#!' >> $out_file
    fi
done < $in_file
