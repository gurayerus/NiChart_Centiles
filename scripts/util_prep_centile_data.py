import pandas as pd
import argparse

def prep_centile_data(df1, df2, df3, key_var, data_var, mri_var_list):
    """
    Merge data files to create centile data
    """
    # Select data
    df1 = df1[[key_var]]
    df2 = df2[[key_var, data_var]]
    if len(mri_var_list) > 0:
        df3 = df3[[key_var] + mri_var_list]

    # Merge data
    df_out = df1.merge(df2, on=key_var)
    df_out = df_out.merge(df3, on=key_var)
    
    return df_out

def main():
    
    ## Default values
    mri_vars=''
    
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Create centile data", add_help=False)
    parser.add_argument("-i1", "--input_list", help="Path to CSV file with selected  IDs", required=True)
    parser.add_argument("-i2", "--input_data", help="Path to CSV file with non-imaging data", required=True)
    parser.add_argument("-i3", "--input_mri", help="Path to CSV file with mri data", required=True)
    parser.add_argument("-k", "--key_var", help="Variable used as primary key", required=True)
    parser.add_argument("-d", "--data_var", help="Variable selected from the data file", required=True)
    parser.add_argument("-m", "--mri_vars", default='', help="Variables selected from the mri file", required=False)
    parser.add_argument("-h", "--help", action='help', default=argparse.SUPPRESS, help='Show this help message and exit.')    
    parser.add_argument("-o", "--out_csv", help="Path to the output CSV file", required=True)
    args = parser.parse_args()

    # Read CSV files into DataFrames
    try:
        df1 = pd.read_csv(args.input_list)
        df2 = pd.read_csv(args.input_data)
        df3 = pd.read_csv(args.input_mri)
    except Exception as e:
        print(f"Error: {e}")

    # Read mri variables to list
    if  args.mri_vars == '':
        mri_var_list = []
    else:
        mri_var_list = args.mri_vars.split(',')

    # Create out df
    df_out = prep_centile_data(df1, df2, df3, args.key_var, args.data_var, mri_var_list)

    # Save the merged DataFrame to a new CSV file
    df_out.to_csv(args.out_csv, index=False)

if __name__ == "__main__":
  main()
