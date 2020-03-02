## ---- eval=FALSE---------------------------------------------------------
## devtools::install_github('stevencarlislewalker/thermopic')

## ------------------------------------------------------------------------
library(thermopic)

## ------------------------------------------------------------------------
# Generate a temporary directory for saving the results of the analysis
root = tempdir()

## ---- echo=FALSE---------------------------------------------------------
# Here is the path to your demo directory -- try going there and watch
# it fill up as you run the code below
root

## ------------------------------------------------------------------------
# Build the required directory structure automatically
setup_directory(root, overwrite = TRUE)

## ------------------------------------------------------------------------
# An appropriate directory structure has been built for you
list.files(root, recursive = TRUE, include.dirs = TRUE)

## ------------------------------------------------------------------------
# Fit the model
fitted_thermopic_model = thermopic_model(
  path = root,
  Lake = '1_lake.csv',
  Climate = '2_Climate.csv'
)

## ------------------------------------------------------------------------
# Build the report
thermopic_report_data = thermopic_report(
  path = root,
  STM_Parameters = fitted_thermopic_model$STM,
  Options = '0_User_Options.csv',
  Nlakes_test = 5,
  show_progress_bar = TRUE
)

## ---- echo=FALSE---------------------------------------------------------
# There are many files now! You can check them out
list.files(root, recursive = TRUE)

## ---- echo=FALSE---------------------------------------------------------
# Get rid of the temporary directory
unlink(root)

