#!/bin/bash

if [[ -z $1 ]]; then
  echo "You must provide a date for the script"
  exit 1
fi
if [[ "$1" = "-h" ]]; then
  echo "This script undoes all pacman upgrades after a provided date. Provide a date up to 2 days ago as the first and only positional argument to this script"
  exit 0
fi

current_month_year="$(date '+%Y-%m')"
td="$(date '+%Y-%m-%d')"
fd=$(date -d "$1" '+%Y-%m-%d')
if [[ $? != 0 ]]; then
  echo "failed to parse date"
  exit 1
fi

function check_input_date_not_more_than_2_days_ago() {
  two_days_ago=$(date -d "$td -2 days" '+%Y-%m-%d')

  if [[ "$fd" < "$two_days_ago" ]]; then
    echo "This script blocks rolling back upgrades older than 2 days"
    exit 1
  fi
}

TEMPFILE="$(mktemp /tmp/rollback-XXXX)"
trap 'rm -f $TEMPFILE' EXIT

rg "$current_month_year" /var/log/pacman.log | rg upgraded >"$TEMPFILE"

function date_to_timestamp() {
  date -d "$1" +%s
}

function get_lines() {
  # Loop through each line in the file
  while IFS= read -r line; do
    # Extract date from the line (assuming it's the only date in the line)
    matched_date=$(echo "$line" | awk '{print $1}' | sed 's/\[//g' | sed 's/\]//g' | awk -F'T' '{print $1}')
    # Convert the matched date to a timestamp

    # Compare the matched date with the start date and current date
    if [[ "$matched_date" > "$fd" && ("$matched_date" < "$td" || "$matched_date" = "$td") ]]; then
      echo "$line" # Print the line if it matches the date range
    fi
  done <"$TEMPFILE"
}
lines="$(get_lines | awk '{print $4 $5}' | sed 's/(/-/' | sort | uniq)"
echo "$lines" | xargs -I{} sh -c 'find /var/cache/pacman/pkg/ -name "*{}*.zst"' | xargs -I{} sh -c 'sudo pacman -U {} --noconfirm'
