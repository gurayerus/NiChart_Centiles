#!/bin/bash +x

# This script is a wrapper to call the R script: util_calc_centiles.r

## Help function
print_help() {
  echo "Script to calculate centile values for the input data"
  echo "  First column of the input file is the ID column and it's discarded (example: MRID)"
  echo "  Second column of the input file is the reference value (example: Age)"
  echo "  Other columns of the input file are variables to calculate centiles (example: ROI1, ROI2, ...)"
  echo ""
  echo "Usage: $0 [-h] -i input_csv -o output_csv"
  echo "  -i, --in_csv (str)  : Path to input CSV file (REQUIRED)"
  echo "  -o, --out_csv (str)  : Path to output CSV file (REQUIRED)"
  echo "  -c, --cent_vals (int,...) : Comma-separated centile values (OPTIONAL, default: 25,50,75)"
  echo "  -b, --bin_size  (int)  : Bin size for the reference variable (OPTIONAL, default: 1)"
  echo "  -v, --verbose         : Display more verbose messages"
  echo "  -h, --help            : Display this help message"
  echo ""
  echo "Examples:"
  echo "# Calculate Age centiles at 5 different centile values with 2 year age bins"
  echo "Given in.csv with columns: Age,Var1,Var2,..."
  echo "> $0 -i in.csv -o out.csv -c 5,25,50,75,95 -b 2"
  echo ""
  exit 1
}

# Define default values
in_csv=""
out_csv=""
cent_vals="25,50,75"
bin_size=1

# Parse arguments using getopts
while getopts ":i:o:c:b:vh?" opt; do
  case $opt in
    i) in_csv="$OPTARG" ;;
    o) out_csv="$OPTARG" ;;
    c) cent_vals="$OPTARG" ;;
    b) bin_size="$OPTARG" ;;
    v) verbose=1 ;;    
    h|\?) print_help ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

## Shift arguments to remove parsed options
shift $((OPTIND-1))

## Check for required arguments
if [[ -z "$in_csv" || -z "$out_csv" ]]; then
  echo "Missing required arguments: -i input_csv and -o output_csv" >&2
  exit 1
fi

## Set verbose flag
if [ ! -z ${verbose} ]; then
    vflag='-v'
else
    vflag=''
fi

## Load R module ## FIXME: This is specific to cbica cluster
module load R/4.3
    
## Run centile creation R script
Rscript util_calc_centiles.r -i $in_csv -o $out_csv -c $cent_vals -b $bin_size $vflag

module unload R/4.3

