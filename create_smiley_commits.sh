#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# 53-week contribution window start (Sunday) through current week.
dow=$(date +%w)
end_sunday=$(date -d "$dow days ago" +%F)
start_sunday=$(date -d "$end_sunday -52 weeks" +%F)

# Place smiley in a mostly empty area toward the right half of the graph.
offset_col=34
commits_per_pixel=5

# Pixel coordinates for a 13x7 smiley: col,row with row 0=Sunday .. 6=Saturday.
pixels=(
  "0,2" "0,3" "0,4"
  "1,1" "1,5"
  "2,0" "2,6"
  "3,0" "3,6"
  "4,0" "4,6"
  "5,0" "5,6"
  "6,0" "6,6"
  "7,0" "7,6"
  "8,0" "8,6"
  "9,0" "9,6"
  "10,0" "10,6"
  "11,1" "11,5"
  "12,2" "12,3" "12,4"
  "4,2" "4,3"
  "8,2" "8,3"
  "3,4" "4,5" "5,5" "6,5" "7,5" "8,5" "9,4"
)

# Create initial commit if repository has no commits yet.
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  first_date=$(date -d "$start_sunday +$((offset_col * 7 + 2)) days" +%F)
  export GIT_AUTHOR_DATE="$first_date 12:00:00"
  export GIT_COMMITTER_DATE="$first_date 12:00:00"
  printf "seed %s\n" "$first_date" >> smiley_canvas.txt
  git add smiley_canvas.txt
  git commit -m "seed: initialize smiley canvas"
fi

for pixel in "${pixels[@]}"; do
  rel_col=${pixel%,*}
  row=${pixel#*,}
  abs_col=$((offset_col + rel_col))
  day_index=$((abs_col * 7 + row))
  date_str=$(date -d "$start_sunday +${day_index} days" +%F)

  for i in $(seq 1 "$commits_per_pixel"); do
    export GIT_AUTHOR_DATE="$date_str 12:00:00"
    export GIT_COMMITTER_DATE="$date_str 12:00:00"
    printf "smiley %s col=%d row=%d commit=%d\n" "$date_str" "$abs_col" "$row" "$i" >> smiley_canvas.txt
    git add smiley_canvas.txt
    git commit -m "smiley: c${abs_col} r${row} (${i}/${commits_per_pixel})" >/dev/null
  done
done

echo "Created smiley commits with ${commits_per_pixel} commits per pixel day."
