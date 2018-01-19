library(thermopic)
library(chron)
library(plyr)
library(rLakeAnalyzer)
library(rootSolve)
library(RColorBrewer)

root = tempdir()
setwd(root)
print(getwd())

setup_directory(root, overwrite = TRUE)

fitted_thermopic_model = thermopic_model(
  path = root,
  laked = '1_lake.csv',
  sited = '2_Climate.csv',
  UserOptions = '0_User_Options.csv'
)

thermopic_report_data = thermopic_report(
  path = root,
  spaced = fitted_thermopic_model$STM,
  Options = '0_User_Options.csv'
)

unlink(root)
