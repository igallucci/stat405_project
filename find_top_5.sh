#!/bin/bash


counter=1

while IFS= read -r file; do
  full_file_path="/home/jwcramer2/project/$file" # If you want to prepend the current directory path
  tail -n +2 "$full_file_path" | cut -d ',' -f1 | sort | uniq -c > "out${counter}.txt"
  ((counter++))
done < ./files.txt
