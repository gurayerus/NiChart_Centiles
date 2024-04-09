##############################################################
## Script to calculate centile values for the ROI values
##
## Args:
## - f_in: full path to input csv file
##    - first column is used as the reference column
##    - centiles are calculated for all remaining columns 
## - f_out: full path to output csv
## - cent_vals: centile values to calculate (example: 25,50,75)
## - bin_size: bin size for the reference variable (example: 1)
##
## Contact:
## guray.erus@pennmedicine.upenn.edu , 04/18/2024
##

## Required packages
if (!require(gamlss)) {
  install.packages('gamlss')
}
library(gamlss) # lms()
library('getopt')

## Script was creating Rplots.pdf file - fix to bypass this behavior
pdf(NULL)

## Set script name (FIXME: hard-coded for now)
scr_name="util_calc_centiles.r"

## Help function
print_help <- function() {
  cat("Script to calculate centile values for the input data\n")
  cat("  First column of the input file is the ID column and it's discarded (example: MRID)\n")
  cat("  First column of the input file is the reference value (example: Age)\n")
  cat("  Other columns of the input file are variables to calculate centiles (example: ROI1, ROI2, ...)\n\n")
  cat("Usage: Rscript ", scr_name, " [-h] -i input_csv -o output_csv\n")
  cat("  -i, --in_csv (str)  : Path to input CSV file (REQUIRED)\n")
  cat("  -o, --out_csv (str) : Path to output CSV file (REQUIRED)\n")
  cat("  -c, --cent_vals (int,...) : Comma-separated centile values (OPTIONAL, default: 25,50,75)\n")
  cat("  -b, --bin_size  (int)  : Bin size for the reference variable (OPTIONAL, default: 1)\n")
  cat("  -v, --verbose          : Display more verbose messages (OPTIONAL)\n")  
  cat("  -h, --help             : Display this help message (OPTIONAL)\n")
  cat("\n")
  cat("Examples:\n")
  cat("# Calculate Age centiles at 5 different centile values with 2 year age bins\n")
  cat("Given in.csv with columns:  Age,Var1,Var2,...\n")
  cat("> ", scr_name, " -i in.csv -o out.csv -c 5,25,50,75,95 -b 2\n")
  cat("\n")
  quit(status = 0)
}

## Get options 
library(getopt)
spec = matrix(c(
    'verbose', 'v', 2, "integer",
    'in_csv','i',1,"character",
    'out_csv','o',1,"character",
    'cent_vals','c',1,"character",
    'bin_size','b',1,"integer",  
    'help','h',0,"logical"
), byrow=TRUE, ncol=4)
opt = getopt(spec)

## Print help message
if (!is.null(opt$help)) {
    print_help()
}

## Set default options
if (is.null(opt$cent_vals)) opt$cent_vals <- "25,50,75"
if (is.null(opt$bin_size)) opt$bin_size <- 1
if (is.null(opt$verbose)) opt$verbose <- FALSE

## Check for required arguments
if (is.null(opt$in_csv) | is.null(opt$out_csv)) {
    print_help()
    stop("Missing required arguments ...")
}

## Process centile values (convert comma-separated string to numeric vector)
opt$cent_vals <- as.numeric(strsplit(opt$cent_vals, ",")[[1]])

## Print args 
if (opt$verbose) {
    print('Running with arguments:')
    cat(' Input file: ', opt$in_csv, '\n')
    cat(' Output file: ', opt$out_csv, '\n')
    cat(' Centile values: ', opt$cent_vals, '\n')
    cat(' Bin size: ', opt$bin_size, '\n')
}

## Read data and detect variables
df <- read.csv(opt$in_csv)
names(df) <- make.names(names(df))
ref_var <- names(df)[[2]]
cent_vars <- tail(names(df), -2L)


## Create out dir
out_dir <- dirname(opt$out_csv)
if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive=TRUE)
    if (opt$verbose) {
        cat("Created dir:", out_dir, "\n")
    }
}

## Get a vector of [min -> max] for the ref var
minRef <- min(df[,ref_var])
maxRef <- max(df[,ref_var])
vec_ref  <- seq(minRef, maxRef, opt$bin_size)

## Create dataframe with centile values
df_out <- data.frame()
for (cent_var in cent_vars) {
  cat('Calculating centile values for:',cent_var,'**', '\n')

  ## Select input var
  df_sel <- df[,c(ref_var, cent_var)]
  names(df_sel) <- c('RefVar','CentVar')

  ## Calculate centile model
# #   m0 <- lms(CentVar, RefVar, families = c("BCCGo","BCPEo","BCTo"), data = df_sel, k = 3, calibration = F, trans.x = F, legend = T, plot = F)
  m0 <- lms(CentVar, RefVar, families = c("BCCGo","BCTo"), data = df_sel, k = 3, calibration = F, trans.x = F, legend = T, plot = F)
  
  ## Extract centile values to matrix
  centiles(m0, xvar<-df_sel$RefVar, opt$cent_vals)
  cent_vals_mat <- centiles.pred(m0, xname = "RefVar", xvalues = vec_ref, cent = opt$cent_vals, plot = T)

  ## Set column names
  colnames(cent_vals_mat) <- c(ref_var, paste('centile', opt$cent_vals, sep='_'))
  
  ## Add Var
  VarName <- rep(cent_var, nrow(cent_vals_mat))
  cent_vals_mat <- cbind(VarName, cent_vals_mat)
  
  ## Create dataframe
  cent_vals_df <- as.data.frame(cent_vals_mat)

  df_out <- rbind(df_out, cent_vals_df)
}

## Save dataframe
write.csv(df_out, file = opt$out_csv, row.names = FALSE)
