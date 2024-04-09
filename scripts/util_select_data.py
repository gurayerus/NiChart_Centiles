import pandas as pd
import argparse
import json

def filter_data(df, filter_info):
    """
    Filters data based on json data
    """
    # Construct filtering condition based on json values
    filter_str = ""
    for filter_dict in filter_info:
        field_name = filter_dict["field_name"]

        ## Filter for min val
        min_val = filter_dict.get("min_val")
        if min_val is not None:
            filter_str += " & " + f"{field_name} >= {min_val}"

        ## Filter for max val
        max_val = filter_dict.get("max_val")
        if max_val is not None:
            filter_str += " & " + f"{field_name} <= {max_val}"

        ## Filter for equal
        eq_val = filter_dict.get("equals")
        if eq_val is not None:
            filter_str += " & " + f"{field_name} == {eq_val}"
            
        ## Filter for isin
        isin_val = filter_dict.get("isin")
        if isin_val is not None:
            filter_str += " & " + f"{field_name}.isin({isin_val})"

        ## Filter for isin
        contains_val = filter_dict.get("contains")
        if contains_val is not None:
            filter_str += " & " + f"{field_name}.str.contains({contains_val})"
            
    ##filter_str = filter_str.removeprefix(" & ")
    if filter_str.startswith(" & "):
        filter_str = filter_str[3:]

    print(filter_str)

    # Apply filters
    df_out = df.query(filter_str, engine='python')
    
    # Return out file
    return df_out

def main():
    
    ## Default values
    mri_vars=''
    
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Create centile data", add_help=False)
    parser.add_argument("-i", "--input_data", help="Path to CSV file with data", required=True)
    parser.add_argument("-f", "--input_filter", help="Path to json file with filter info", required=True)
    parser.add_argument("-o", "--out_csv", help="Path to the output CSV file", required=True)
    parser.add_argument("-h", "--help", action='help', default=argparse.SUPPRESS, help='Show this help message and exit.')    
    args = parser.parse_args()

    # Read CSV files into DataFrames
    try:
        df = pd.read_csv(args.input_data)

        with open(args.input_filter, "r") as f:
            filter_info = json.load(f)
    except Exception as e:
        print(f"Error: {e}")

    # Filter data
    df_out = filter_data(df, filter_info)
    
    # Save the merged DataFrame to a new CSV file
    df_out.to_csv(args.out_csv, index=False)

if __name__ == "__main__":
  main()
