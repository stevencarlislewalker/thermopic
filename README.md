# Predicting and Visualizing Thermal Habitat: `thermopic`

The `thermopic` R package provides functionality for predicting and visualizing the seasonal availability of thermal habitat in lakes.

## Installation

Installation is easiest from an `R` commandline using the `devtools` package.

```r
devtools::install_github('stevencarlislewalker/thermopic')
```

It might be necessary to preceed this first step by installing `devtools`.

```r
install.packages('devtools')
```

Once the package is installed, it may be loaded using the `library` function.

```r
library(thermopic)
```

## Quick tour

The `thermopic` package runs within a project directory, which we create using the optional `temporary_thermopic_directory` function.

```r
root = temporary_thermopic_directory()
```

We now use `thermopic`'s `setup_directory` function to create the required directory structure for our project. For this quick tour we use sample input data contained within the package, which is the default behaviour of `setup_directory`.

```r
setup_directory(root, overwrite = TRUE)
```

To inspect the resulting directory structure one may use `thermopic`s `print_directory_tree` function.

```r
print_directory_tree(root)
```

```
## thermopic_project           
##  ¦--DataIn                  
##  ¦   ¦--0_User_Options.csv  
##  ¦   ¦--1_Lake.csv          
##  ¦   °--2_Climate.csv       
##  ¦--DataOut                 
##  ¦   °--ThermoPics          
##  ¦--ThermoPic_Dictionary.csv
##  ¦--ThermoPic_Guide.pdf     
##  °--ThermoPic_TechReport.pdf
```

Now that the structure is in place one may fit the thermopic model.

```r
fitted_thermopic_model = thermopic_model(
  path = root,
  Lake = '1_Lake.csv',
  Climate = '2_Climate.csv'
)
```

And create the report as well as the thermopic images themselves.

```r
thermopic_report_data = thermopic_report(
  path = root,
  STM_Parameters = '4_STM_Parameters.csv',
  Nlakes_test = 5,
  show_progress_bar = FALSE
)
```

Here we see the resulting outputs including the images in `jpeg` format files.

```
## thermopic_project                                          
##  ¦--DataIn                                                 
##  ¦   ¦--0_User_Options.csv                                 
##  ¦   ¦--1_Lake.csv                                         
##  ¦   °--2_Climate.csv                                      
##  ¦--DataOut                                                
##  ¦   ¦--3_Model_Inputs.csv                                 
##  ¦   ¦--4_STM_Parameters.csv                               
##  ¦   ¦--5_ThermalSpace4D.csv                               
##  ¦   ¦--ThermoPics                                         
##  ¦   ¦   ¦--4_Wingiskus Lake_15-3543-56122_P2001-2010.jpeg 
##  ¦   ¦   ¦--5_Cygnet Lake_15-3653-55394_P2001-2010.jpeg    
##  ¦   ¦   ¦--5_Malachi Lake_15-3559-55281_P2001-2010.jpeg   
##  ¦   ¦   ¦--5_South Scot Lake_15-3523-55336_P2001-2010.jpeg
##  ¦   ¦   °--5_Whitefish Lake_15-3532-55170_P2001-2010.jpeg 
##  ¦   ¦--tmp_ClimMetrics.csv                                
##  ¦   °--tmp_IceClimMetrics.csv                             
##  ¦--ThermoPic_Dictionary.csv                               
##  ¦--ThermoPic_Guide.pdf                                    
##  °--ThermoPic_TechReport.pdf
```



## Further information

For a more detailed introduction see this [tutorial](inst/doc/thermopic_tutorial.md).
