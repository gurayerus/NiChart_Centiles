###############################################################
## Script to calculate centile values for the ROI values
## Returns one csv file per roi
##
## Input:
## - f_in: full path to input csv file
## - p_out: full path to output csv file prefix (output folder should exist)
## - ROIs (optional): comma separated list of ROIs
##
## Output:
##   For each ROI a csv file is created with centile values. Out file is named as "{p_out}_{ROI}"
##
## Notes:
##   - The input csv file should include the columns: "Age,ROI1,ROI2,..."
##   - If ROIs arg is not provided, all columns other than the Age column is considered as an ROI column
##   - The resolution of the output (step size for age and step size for centiles) is hardcoded (see below)
##       Users need to edit it to get output with different resolution
##
## Contact:
## guray.erus@pennmedicine.upenn.edu , 07/11/2023
##

##

if (!require(gamlss)) {

  install.packages('gamlss')

}

library(gamlss) # lms()

# Define the expected number of arguments
expected_args <- 4

# Check if the correct number of arguments is provided
args <- commandArgs(trailingOnly <- TRUE)
length(args)
if (length(args) < expected_args) {
  print('Usage: Rscript rois_to_centiles [in_file_name] [out_file_prefix] [ROIs (comma separated list of ROIs)] [cent_vals (comma separated list of centile values)] [age_step]', )
  stop("Incorrect number of arguments. Please provide ", expected_args, " arguments.")
}

# Retrieve arguments
f_in <- args[1]
f_out <- args[2]
sel_rois <- strsplit(args[3], ",")[[1]]
cent_vals <- as.numeric(strsplit(args[4], ",")[[1]])
age_step <- as.numeric(args[5])

# # # f_in <- '../../output/test_step2_mergeData/NiChart_SelVars.csv'
# # # f_out <- '../../output/test_step2_mergeData/centiles/NiChart_SelVars_centiles'
# # # sel_rois <- strsplit('ICV,TBR,GM,WM,VN,HippoL,ThalL', ",")[[1]]
# # # cent_vals <- as.numeric(strsplit('10,25,50,75,90', ",")[[1]])
# # # age_step <- 1

# Print arguments
print('Running with arguments:')
cat(' Input file: ', f_in, '\n')
cat(' Output file: ', f_out, '\n')
cat(' Sel ROIs: ', sel_rois, '\n')
cat(' Centile values: ', cent_vals, '\n')
cat(' Age step: ', age_step, '\n')

## Read data
df <- read.csv(f_in)
names(df) <- make.names(names(df))
roi_cols <- names(df)[startsWith(names(df), 'ROI')]

## Get a vector of [min -> max] age
minAge <- min(df[,'Age'])
maxAge <- max(df[,'Age'])

# # # minAge = 30
# # # maxAge = 50

vec_age  <- seq(minAge, maxAge, age_step)

# #######################################
# ## Subsample data (FIXME this is tmp)
# set.seed(0126)
# selind <- sample.int(dim(df)[1], 2000, replace<-FALSE)
# df  <- df[selind,]
# #######################################

df_out <- data.frame()

for (sel_roi in sel_rois) {
  cat('Calculating centile values for:',sel_roi,'**', '\n')

  ## Select input roi var
  df_sel <- df[,c('Age', sel_roi)]
  
  names(df_sel) <- c('Age','ROI')

  ## Calculate centile model
  m0 <- lms(ROI, Age, families = c("BCCGo","BCPEo","BCTo"), data = df_sel, k = 3, calibration = F, trans.x = F, legend = T, plot = F)
  
  ## Extract centile values to matrix
  centiles(m0, xvar<-df_sel$Age, cent_vals)
  cent_vals_mat <- centiles.pred(m0, xname = "Age", xvalues = vec_age, cent = cent_vals, plot = T)

  ## Set column names
  colnames(cent_vals_mat) <- c('Age', paste('centile', cent_vals, sep='_'))
  
  ## Add ROI
  ROI_Name <- rep(sel_roi, nrow(cent_vals_mat))
  cent_vals_mat <- cbind(ROI_Name, cent_vals_mat)
  
  ## Create dataframe
  cent_vals_df <- as.data.frame(cent_vals_mat)

  df_out <- rbind(df_out, cent_vals_df)
}

## Save dataframe
write.csv(df_out, file = f_out, row.names = FALSE)
