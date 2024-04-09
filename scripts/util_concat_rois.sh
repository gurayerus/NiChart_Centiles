#!/bin/bash +x

# This script concatenates CSV files with MUSE values from individual scans

# Define variables with default values (optional)

# Function to display help message
print_help() {
  echo
  echo "Script to concatenate MUSE CSV files"
  echo "Usage: $0 [-h] -i input_dir -o output_csv -s file_suffix"
  echo "  -i, --input_dir (str)    : Path to input folder (REQUIRED)"
  echo "  -o, --output_csv (str)   : Path to output CSV file (REQUIRED)"
  echo "  -s, --suffix   (str)    : Suffix of input csv files (REQUIRED)"
  echo
  exit 1
}

# Parse arguments using getopts
while getopts ":i:o:s:h?" opt; do
  case $opt in
    i) in_dir="$OPTARG" ;;
    o) out_csv="$OPTARG" ;;
    s) suffix="$OPTARG" ;;
    h|\?) print_help ;;  # Call the help function
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Shift arguments to remove parsed options
shift $((OPTIND-1))

# Check for missing required arguments
if [[ -z "$in_dir" || -z "$out_csv"  || -z "$suffix" ]]; then
    print_help
fi

# Check in file
if [ ! -e $in_dir ]; then
    echo "In folder missing, aborting"
    exit 1
fi

# Check out file
if [ -e $out_csv ]; then
    echo "Out file exists, aborting. Remove the file and rerun to recreate: $out_csv"
    exit 1
fi

# Create out dir
mkdir -pv `dirname ${out_csv}`

# Find input csv files and concatenate
for fname in `find $in_dir -name "*${suffix}"`; do
    if [ ! -e ${out_csv} ]; then
        cat $fname > $out_csv
    else
        sed 1d $fname >> $out_csv    
    fi
done

