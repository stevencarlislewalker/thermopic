# Tutorial for using the `thermopic` package


```r
library(thermopic)
```

## Setting up the project directory structure -- `setup_directory`

The `setup_directory` function takes two specially-formatted data frames as arguments.  The first describes the geography, morphometry, and water quality of lakes.  The second describes the climate of each lake over a particular time period.  There are examples of these files included in the `thermopic` package.  To obtain the location of these files within your installation of `thermopic`, one may use the `system.file` function.

```r
lake_csv = system.file('extdata/1_Lake.csv', package = 'thermopic')
climate_csv = system.file('extdata/2_Climate.csv', package = 'thermopic')
print(lake_csv)
```

```
## [1] "C:/Users/swalker/R/win-library/3.4/thermopic/extdata/1_Lake.csv"
```

```r
print(climate_csv)
```

```
## [1] "C:/Users/swalker/R/win-library/3.4/thermopic/extdata/2_Climate.csv"
```


Here we read these example data frames and print out the first six records of each.

```r
lake_example = read.csv(lake_csv)
climate_example = read.csv(climate_csv)
head(lake_example)
```

```
##   FMZ Group       Lake_Name       Wby_Lid Latitude Longitude Elevation
## 1   1     0       Pine Lake 16-6284-60018    54.15    -85.04       108
## 2   1     0 Shamattawa Lake 16-5856-60025    54.17    -85.69        86
## 3   1     0     Spruce Lake 16-6292-60223    54.33    -85.01       109
## 4   2     0  Big Trout Lake 15-6978-59597    53.75    -90.00       219
## 5   2     0     Cairns Lake 15-3974-57298    51.71    -94.49       373
## 6   2     0    Echoing Lake 15-5492-60415    54.52    -92.24       199
##   Area_ha Shoreline Depth_Max Depth_Mn Secchi  DOC
## 1     299       2.0      12.7      4.7    1.9  8.6
## 2     963       8.8       7.2      1.6    1.2 15.2
## 3    1082       3.8      16.0      4.5    2.0  7.8
## 4   63883     108.0      36.6     10.3    5.8  6.4
## 5    5220      26.1      18.5      7.0    5.7  5.5
## 6    5389       9.4      30.0      8.9    7.7  6.0
```

```r
head(climate_example)
```

```
##         Wby_Lid    Period   Tjan   Tfeb  Tmar Tapr  Tmay  Tjun  Tjul  Taug
## 1 15-3523-55336 2001-2010 -15.23 -13.77 -5.73 4.10 10.01 16.28 19.41 18.09
## 2 15-3532-55170 2001-2010 -15.17 -13.70 -5.67 4.16 10.05 16.33 19.46 18.14
## 3 15-3543-56122 2001-2010 -15.81 -14.42 -6.25 3.56  9.62 15.82 18.92 17.67
## 4 15-3559-55281 2001-2010 -15.19 -13.73 -5.70 4.14 10.04 16.32 19.46 18.13
## 5 15-3653-55394 2001-2010 -15.21 -13.73 -5.71 4.15 10.04 16.33 19.49 18.15
## 6 15-3654-55172 2001-2010 -15.13 -13.64 -5.64 4.24 10.11 16.41 19.58 18.24
##    Tsep Toct  Tnov   Tdec Tann  Paug
## 1 13.36 5.02 -2.76 -12.22 3.15 88.72
## 2 13.41 5.06 -2.71 -12.16 3.20 88.75
## 3 12.87 4.61 -3.21 -12.82 2.65 89.22
## 4 13.40 5.05 -2.74 -12.18 3.19 88.97
## 5 13.42 5.05 -2.75 -12.20 3.19 89.47
## 6 13.51 5.12 -2.69 -12.12 3.27 89.81
```

The `setup_directory` function is used to produce the required directory structure for a thermopic project, and inject the lake and climate data into the appropriate place within this structure.

```r
setup_directory(path = '../misc/tutorial_project', 
                Lake = lake_csv,
                Climate = climate_csv,
                overwrite = TRUE)
print_directory_tree('../misc/tutorial_project')
```

```
## tutorial_project            
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

## Fitting the seasonal temperature model -- `thermopic_model`


```r
thermopic_model(path = '../misc/tutorial_project')
```

```
## Error in get_thermopic_data(laked, path, "DataIn"): argument "laked" is missing, with no default
```

## Visualizing thermal habitat in lakes -- `thermopic_report`
