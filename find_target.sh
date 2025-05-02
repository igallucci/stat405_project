#!/bin/bash

# This script processes the given input file and produces a corresponding output.

# Take input filename as argument
input_file="$1"

# Extract a number from the filename (e.g., chess1.csv -> 1)
file_number=$(echo "$input_file" | grep -o '[0-9]\+')

# Define the output filename
output_file="target_chess_parallel${file_number}.txt"

awk -F',' '
NR == 1 { next }
{
    fen = $1
    depth = $3 + 0
    knodes = $4 + 0
    cp = $5 + 0
    mate = $6 + 0

    data[fen][++count[fen]] = $0
    depth_arr[fen, count[fen]] = depth
    knodes_arr[fen, count[fen]] = knodes
    cp_arr[fen, count[fen]] = cp
    mate_arr[fen, count[fen]] = mate

    if (!(fen in best) || (depth > best_depth[fen]) || (depth == best_depth[fen] && knodes > best_knodes[fen])) {
        best[fen] = count[fen]
        best_depth[fen] = depth
        best_knodes[fen] = knodes
        best_cp[fen] = cp
        best_mate[fen] = mate
    }
}
END {
    total_depth = 0
    total_knodes = 0
    total_fen = 0

    for (fen in best) {
        target_cp = cp_arr[fen, best[fen]]
        target_mate = mate_arr[fen, best[fen]]

        min_depth = ""
        min_knodes = ""
        found = 0

        for (i = 1; i <= count[fen]; i++) {
            if (i == best[fen]) continue

            cp_val = cp_arr[fen, i]
            mate_val = mate_arr[fen, i]

            cp_ok = (target_cp == 0) ? (cp_val == 0) : (cp_val >= 0.95 * target_cp)
            mate_ok = (target_mate == 0) ? (mate_val == 0) : (mate_val >= 0.95 * target_mate)

            if (cp_ok && mate_ok) {
                if (!found || (depth_arr[fen, i] < min_depth) || (depth_arr[fen, i] == min_depth && knodes_arr[fen, i] < min_knodes)) {
                    min_depth = depth_arr[fen, i]
                    min_knodes = knodes_arr[fen, i]
                    found = 1
                }
            }
        }

        if (found) {
            total_depth += min_depth
            total_knodes += min_knodes
            total_fen++
        }
    }

    if (total_fen > 0) {
        avg_depth = total_depth / total_fen
        avg_knodes = total_knodes / total_fen
        printf("%.2f,%.2f\n", avg_depth, avg_knodes) > "'$output_file'"
    } else {
        print "No valid positions found." > "'$output_file'"
    }
}
' "$input_file"
