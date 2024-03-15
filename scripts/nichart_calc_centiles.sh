#!/bin/bash

# This script calculates percentiles for data variables in a CSV file
# It utilizes an R package to perform the calculations.

# Define variables with default values (optional)
in_csv=""
ref_var="Age"
sel_vars=""
vals_cent="25,50,75"
bin_size="1"
out_csv=""

# Function to display help message
print_help() {
  echo "Script to calculate centile values for the input data"
  echo "Usage: $0 [-h] -i input_csv -r ref_var -s sel_vars -c centile_vals -b bin_size -o output_csv"
  echo "  -i, --input_csv (str)    : Path to input CSV file (REQUIRED)"
  echo "  -o, --output_csv (str)   : Path to the output CSV file (REQUIRED)"
  echo '  -r, --ref_var   (str)    : Reference variable (OPTIONAL, default: "Age")'
  echo "  -s, --sel_vars  (str,str,...): Selected variables (OPTIONAL, default: all columns except the reference variable)"
  echo "  -c, --centile_vals (int,int,...): Percentile values to calculate (OPTIONAL, default: 25,50,75)"
  echo "  -b, --bin_size  (int)    : Bin size for the reference variable (OPTIONAL, default: 1)"
  echo "  -h, --help               : Display this help message"
  echo ""
  echo "Examples:"
  echo "## Calculate Age centiles with 1 year age bins for all columns"
  echo "> $0 -i in.csv -o out.csv"
  echo "## Calculate MMSE score centiles at 10,50 and 90 percentiles with 0.5 MMSE bin size for GM, WM and CSF columns"
  echo "> $0 -i in.csv -r MMSE -s GM,WM,CSF -c 10,50,90 -b 0.5 -o out.csv"
  exit 0
}

# Parse arguments using getopts
while getopts ":r:i:o:s::v:a:h?" opt; do
  case $opt in
    i) in_csv="$OPTARG" ;;
    o) out_csv="$OPTARG" ;;
    s) var_out="$OPTARG" ;;
    v) vals_cent="$OPTARG" ;;
    a) bin_size="$OPTARG" ;;
    h|\?) print_help ;;  # Call the help function
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Shift arguments to remove parsed options
shift $((OPTIND-1))

# Check for missing required arguments
if [[ -z "$rundir" || -z "$in_csv" || -z "$out_csv" || -z "$vals_cent" || -z "$bin_size" ]]; then
  echo "Usage: $0 -r run_dir -i input_csv -o output_csv [-s input_var(s)] -v centile_var(s) -a bin_size"
  echo "Example: $0 -r . -i in.csv -o out.csv -v 25,50,75 -a 2 (no -s option)"
  echo "Example: $0 -r . -i in.csv -o out.csv -s ROI1,ROI2 -v 25,50,75 -a 2"
  exit 1
fi
# Load R module
module load R/4.3

# Run centile creation R script
Rscript "${rundir}/util_calc_centiles.r" "$in_csv" "$out_csv" "$var_out" "$vals_cent" "$bin_size"
