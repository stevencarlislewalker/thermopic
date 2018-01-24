# thermopic

The `thermopic` software provides functionality for predicting and visualizing the seasonal available of thermal habitat in lakes.

## Installation

Installation is easiest from an `R` commandline using the `devtools` package.

```r
devtools::install_github('stevencarlislewalker/thermopic')
```

Once the package is installed, it may be loaded using the `library` function.

```r
library(thermopic)
```

## Setting up the directory structure

The `thermopic` package runs within a project directory. Here we create a temporary directory for this tutorial using standard `R` tools.

```r
root = tempdir()
```

In this case the temporary directory is located here.

```
## [1] "/var/folders/rh/08l2nsx15zn4jtjr9vd9_qjr0000gn/T//RtmpDYJnZC"
```

We now use `thermopic`'s `setup_directory` function to create the required directory structure for our project.  This function allows some flexibility in how input data are specified.  Here we use the defaults, which extract sample data contained within the package.

```r
setup_directory(root, overwrite = TRUE)
```

We may inspect this structure using `R`s `list.files` function.

```r
list.files(root, recursive = TRUE, include.dirs = TRUE)
```

```
## [1] "DataIn"                    "DataIn/0_User_Options.csv"
## [3] "DataIn/1_Lake.csv"         "DataIn/2_Climate.csv"     
## [5] "DataOut"                   "DataOut/ThermoPics"       
## [7] "ThermoPic_Dictionary.csv"
```

## Running the model and report functions

Now that the structure is in place, one may fit the thermopic model.

```r
fitted_thermopic_model = thermopic_model(
  path = root,
  laked = '1_lake.csv',
  sited = '2_Climate.csv'
)
```

And finally create the report as well as the thermopic images themselves.  For speed we restrict the number of lakes to process to `5`.

```r
thermopic_report_data = thermopic_report(
  path = root,
  spaced = fitted_thermopic_model$STM,
  Options = '0_User_Options.csv',
  Nlakes_test = 5,
  show_progress_bar = FALSE
)
```

## Inspecting the updated directory structure

Here we see the resulting outputs including the images in `jpeg` format files, again using `list.files`.

```
##  [1] "DataIn/0_User_Options.csv"                                         
##  [2] "DataIn/1_Lake.csv"                                                 
##  [3] "DataIn/2_Climate.csv"                                              
##  [4] "DataOut/3_Model_Inputs.csv"                                        
##  [5] "DataOut/4_STM_Parameters.csv"                                      
##  [6] "DataOut/5_ThermalSpace4D.csv"                                      
##  [7] "DataOut/ThermoPics/4_Wingiskus Lake_15-3543-56122_P2001-2010.jpeg" 
##  [8] "DataOut/ThermoPics/5_Cygnet Lake_15-3653-55394_P2001-2010.jpeg"    
##  [9] "DataOut/ThermoPics/5_Malachi Lake_15-3559-55281_P2001-2010.jpeg"   
## [10] "DataOut/ThermoPics/5_South Scot Lake_15-3523-55336_P2001-2010.jpeg"
## [11] "DataOut/ThermoPics/5_Whitefish Lake_15-3532-55170_P2001-2010.jpeg" 
## [12] "DataOut/tmp_ClimMetrics.csv"                                       
## [13] "DataOut/tmp_IceClimMetrics.csv"                                    
## [14] "ThermoPic_Dictionary.csv"
```


