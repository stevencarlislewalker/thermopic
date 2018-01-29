## ---- eval=FALSE---------------------------------------------------------
## devtools::install_github('stevencarlislewalker/thermopic')

## ------------------------------------------------------------------------
library(thermopic)

## ------------------------------------------------------------------------
root = tempdir()

## ---- echo=FALSE---------------------------------------------------------
root

## ------------------------------------------------------------------------
setup_directory(root, overwrite = TRUE)

## ------------------------------------------------------------------------
list.files(root, recursive = TRUE, include.dirs = TRUE)

## ------------------------------------------------------------------------
fitted_thermopic_model = thermopic_model(
  path = root,
  laked = '1_lake.csv',
  sited = '2_Climate.csv'
)

## ------------------------------------------------------------------------
thermopic_report_data = thermopic_report(
  path = root,
  spaced = fitted_thermopic_model$STM,
  Options = '0_User_Options.csv',
  Nlakes_test = 5,
  show_progress_bar = TRUE
)

## ---- echo=FALSE---------------------------------------------------------
list.files(root, recursive = TRUE)

## ---- echo=FALSE---------------------------------------------------------
unlink(root)

