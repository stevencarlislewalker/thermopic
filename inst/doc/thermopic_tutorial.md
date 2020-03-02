# Tutorial for using the `thermopic` package

## Introduction

A ThermoPic is a picture of thermal habitat in a lake.  Given that the seasonal temperature cycle is known or can be predicted  (Figure 1), one can calculate for each day of the year how much habitat exists within specified bands of temperature (e.g., 8-12 °C, 12-16 °C, 16-20 °C, etc.).  A ThermoPic can then be produced by plotting % volume (or area) of habitat versus day of year  (Figure 2).  Because fish species differ in terms their preferred temperatures, this plot is a very useful summary of the thermal habitat available for different species.
The ThermoPic software serves three purposes.  First, it predicts the seasonal temperature cycle in lakes based on easily measured variables (i.e., lake morphometry and climate).  Second, it calculates and reports thermal habitat statistics.  Third, it generates a ThermoPic plot.  The model used to predict temperature is referred to as the Seasonal Temperature Model (STM).  It was created by Minns et al. (2016) based on data from lakes in the province of Ontario (Canada).   The STM is based on seven parameters (see Figure 3), each of which can be predicted given the following lake data inputs:  location (latitude, longitude, elevation), morphometry (surface area, shoreline length,  maximum depth and mean depth),  water chemistry (Secchi, DOC), air temperature cycle (monthly means), and precipitation in August.  Formulae used to calculate the STM parameters are given in this Guide, including formulae for dealing with missing data (i.e., Secchi, DOC, Shoreline).

Figure C1.  Seasonal temperature cycle in a lake.

Figure C2.  Example of a ThermoPic

Figure C3.  The Seasonal Temperature Model (STM) parameters.
C2.  Installation

## Installation

Installation instructions may be found online at https://github.com/stevencarlislewalker/thermopic/blob/master/README.md.  At the time of writing these instructions involve the following steps:
    1.	Open an R session
    2.	Make sure you are connected to the internet
    3.	If the devtools package is not already installed, install it by entering the following command into the R prompt:  install.packages(‘devtools’)
    4.	Install the thermopic package by entering the following command into the R prompt:  devtools::install_github(‘stevencarlislewalker/thermopic’)

To begin using the thermopic package, enter the following command into the R prompt:  library(thermopic)


## Operation

The thermopic R package provides functions for creating and modifying a project directory with a particular structure. The setup_directory function automatically imposes this structure on a chosen directory and populates it with CSV files to be used as input.  The thermopic_model and thermopic_report functions modify and create files within this structure and produces JPEG or TIFF files of ThermoPic plots.  Once all three functions are called, the project directory structure will look something like this:


```
## tutorial_project                                           
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

The `DataIn` directory contains three csv files that provide the input data to the project. 

consists of:
    * a data dictionary (ThermoPic_Dictionary.csv)
    * 3 CSV data input files (0_User_Options, 1_Lake, 2_Climate)
    * 3 CSV output files (3_Model_Inputs, 4_STM_Parameters, 5_Thermal Space4D)
    * multiple JPEG files (one for each ThermoPic created)

The data dictionary is stored in a main folder for reference, and two sub-Folders (DataIn, DataOut), as illustrated below.  ThermoPic plots are stored as JPEG or TIFF files in a sub-folder of DataOut.  

The main folder also includes supplementary information:
    * ThermoPic_TechReport (report by Minns et al. that developed the Seasonal Temperature Model and demonstrates the application of ThermoPics)
    * ThermoPic_Guide.pdf (copy of this document, which is Appendix C in ThermoPic_TechReport.pdf)

### Setting up the project directory structure -- `setup_directory`

The `setup_directory` function takes two specially-formatted data frames as arguments.  The first describes the geography, morphometry, and water quality of lakes.  The second describes the climate of each lake over a particular time period.  There are examples of these files included in the `thermopic` package.  To obtain the location of these files within your installation of `thermopic`, one may use the `system.file` function.

```r
lake_csv = system.file('extdata/1_Lake.csv', package = 'thermopic')
climate_csv = system.file('extdata/2_Climate.csv', package = 'thermopic')
print(lake_csv)
```

```
## [1] "C:/Users/Steve_Walker/R/win-library/3.5/thermopic/extdata/1_Lake.csv"
```

```r
print(climate_csv)
```

```
## [1] "C:/Users/Steve_Walker/R/win-library/3.5/thermopic/extdata/2_Climate.csv"
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

### Fitting the seasonal temperature model -- `thermopic_model`


```r
fitted_model = thermopic_model(path = '../misc/tutorial_project',
                               Lake = '1_Lake.csv',
                               Climate = '2_Climate.csv')
lapply(fitted_model, head)
```

```
## $tmp_ClimMetrics
##         Wby_Lid    Period   Tjan   Tfeb  Tmar Tapr  Tmay  Tjun  Tjul  Taug
## 1 15-3523-55336 2001-2010 -15.23 -13.77 -5.73 4.10 10.01 16.28 19.41 18.09
## 2 15-3532-55170 2001-2010 -15.17 -13.70 -5.67 4.16 10.05 16.33 19.46 18.14
## 3 15-3543-56122 2001-2010 -15.81 -14.42 -6.25 3.56  9.62 15.82 18.92 17.67
## 4 15-3559-55281 2001-2010 -15.19 -13.73 -5.70 4.14 10.04 16.32 19.46 18.13
## 5 15-3653-55394 2001-2010 -15.21 -13.73 -5.71 4.15 10.04 16.33 19.49 18.15
## 6 15-3654-55172 2001-2010 -15.13 -13.64 -5.64 4.24 10.11 16.41 19.58 18.24
##    Tsep Toct  Tnov   Tdec Tann  Paug   Tdjf Tmam  Tjja Tson J_Spr0 J_Aut0
## 1 13.36 5.02 -2.76 -12.22 3.15 88.72 -13.74 2.78 17.94 5.20   92.5  308.4
## 2 13.41 5.06 -2.71 -12.16 3.20 88.75 -13.68 2.83 17.99 5.25   92.3  308.6
## 3 12.87 4.61 -3.21 -12.82 2.65 89.22 -14.35 2.30 17.49 4.76   94.2  306.7
## 4 13.40 5.05 -2.74 -12.18 3.19 88.97 -13.70 2.81 17.99 5.23   92.4  308.5
## 5 13.42 5.05 -2.75 -12.20 3.19 89.47 -13.71 2.81 18.01 5.24   92.4  308.5
## 6 13.51 5.12 -2.69 -12.12 3.27 89.81 -13.63 2.89 18.09 5.31   92.2  308.7
##   J_Aut4 T_Spr0 T_Aut0 YY_Spr0 MM_Spr0 DD_Spr0 YY_Aut0 MM_Aut0 DD_Aut0
## 1  292.7   2.78  -3.33    2010       4       2    2010      11       4
## 2  292.9   2.83  -3.28    2010       4       2    2010      11       4
## 3  291.1   2.30  -3.81    2010       4       4    2010      11       2
## 4  292.9   2.81  -3.30    2010       4       2    2010      11       4
## 5  292.9   2.81  -3.31    2010       4       2    2010      11       4
## 6  293.1   2.89  -3.24    2010       4       2    2010      11       4
##   A40CR
## 1 0.255
## 2 0.255
## 3 0.256
## 4 0.256
## 5 0.256
## 6 0.256
## 
## $tmp_IceClimMetrics
##         Wby_Lid    Period Tann  Tjja Tson  Tmar  Tmay  Tjun  Tjul  Taug
## 1 15-3523-55336 2001-2010 3.15 17.94 5.20 -5.73 10.01 16.28 19.41 18.09
## 2 15-3532-55170 2001-2010 3.20 17.99 5.25 -5.67 10.05 16.33 19.46 18.14
## 3 15-3543-56122 2001-2010 2.65 17.49 4.76 -6.25  9.62 15.82 18.92 17.67
## 4 15-3559-55281 2001-2010 3.19 17.99 5.23 -5.70 10.04 16.32 19.46 18.13
## 5 15-3653-55394 2001-2010 3.19 18.01 5.24 -5.71 10.04 16.33 19.49 18.15
## 6 15-3654-55172 2001-2010 3.27 18.09 5.31 -5.64 10.11 16.41 19.58 18.24
##    Tsep  Paug J_Spr0 MM_Spr0 DD_Spr0 J_Aut0 T_Aut0
## 1 13.36 88.72   92.5       4       2  308.4  -3.33
## 2 13.41 88.75   92.3       4       2  308.6  -3.28
## 3 12.87 89.22   94.2       4       4  306.7  -3.81
## 4 13.40 88.97   92.4       4       2  308.5  -3.30
## 5 13.42 89.47   92.4       4       2  308.5  -3.31
## 6 13.51 89.81   92.2       4       2  308.7  -3.24
## 
## $Model_Inputs
##         Wby_Lid FMZ Group       Lake_Name Latitude Longitude Elevation
## 1 15-3523-55336   5     0 South Scot Lake    49.94    -95.06       343
## 2 15-3532-55170   5     0  Whitefish Lake    49.79    -95.04       366
## 3 15-3543-56122   4     0  Wingiskus Lake    50.65    -95.06       335
## 4 15-3559-55281   5     0    Malachi Lake    49.89    -95.01       333
## 5 15-3653-55394   5     0     Cygnet Lake    49.99    -94.88       331
## 6 15-3654-55172   5     0   Pickerel Lake    49.79    -94.87       366
##   Area_ha Shoreline Depth_Max Depth_Mn Secchi  DOC elnShoreline eShoreline
## 1     397       4.4      10.0      3.5   1.45 12.4     3.083576   21.83635
## 2     216       3.4      20.1      7.0   2.50  6.8     2.643962   14.06883
## 3     692       5.1      19.0      7.7   3.20 12.1     3.351578   28.54775
## 4    1054       6.7      19.8      7.9   3.10  8.4     3.653993   38.62859
## 5    1318       8.8      11.0      4.1   1.80  9.9     3.872757   48.07473
## 6     602       6.1      27.5      7.4   4.25  6.2     3.525955   33.98621
##   ShorelineFlag elnSecchi_DOC elnSecchi_noDOC elnSecchi  eSecchi
## 1           Yes     0.8574987        1.255296 0.8574987 2.357257
## 2           Yes     1.4161457        1.645058 1.4161457 4.121205
## 3           Yes     0.9906697        1.535185 0.9906697 2.693038
## 4           Yes     1.2611416        1.517063 1.2611416 3.529448
## 5           Yes     1.0369341        1.205364 1.0369341 2.820556
## 6           Yes     1.5391393        1.678318 1.5391393 4.660577
##   SecchiFlag      eDOC DOCFlag    Period Tann  Tjja Tson  Tmar  Tmay  Tjun
## 1        Yes 10.873436     Yes 2001-2010 3.15 17.94 5.20 -5.73 10.01 16.28
## 2        Yes  8.259198     Yes 2001-2010 3.20 17.99 5.25 -5.67 10.05 16.33
## 3        Yes  7.250926     Yes 2001-2010 2.65 17.49 4.76 -6.25  9.62 15.82
## 4        Yes  7.365766     Yes 2001-2010 3.19 17.99 5.23 -5.70 10.04 16.32
## 5        Yes  9.977394     Yes 2001-2010 3.19 18.01 5.24 -5.71 10.04 16.33
## 6        Yes  5.833026     Yes 2001-2010 3.27 18.09 5.31 -5.64 10.11 16.41
##    Tjul  Taug  Tsep  Paug J_Spr0 MM_Spr0 DD_Spr0 J_Aut0 T_Aut0 Ang_Spr0
## 1 19.41 18.09 13.36 88.72   92.5       4       2  308.4  -3.33 44.86742
## 2 19.46 18.14 13.41 88.75   92.3       4       2  308.6  -3.28 45.01770
## 3 18.92 17.67 12.87 89.22   94.2       4       4  306.7  -3.81 44.93927
## 4 19.46 18.13 13.40 88.97   92.4       4       2  308.5  -3.30 44.92156
## 5 19.49 18.15 13.42 89.47   92.4       4       2  308.5  -3.31 44.83452
## 6 19.58 18.24 13.51 89.81   92.2       4       2  308.7  -3.24 45.03343
##   Area_km IceBU IceFU_part1 IceFU Icefree Icecover Icethick
## 1    3.97 123.9       71.74 324.7   200.8    164.2    94.03
## 2    2.16 123.5       77.39 330.5   207.0    158.0    90.87
## 3    6.92 126.0       78.33 329.4   203.4    161.6    94.29
## 4   10.54 123.5       78.59 331.6   208.1    156.9    90.57
## 5   13.18 123.8       72.86 325.9   202.1    162.9    93.54
## 6    6.02 123.4       77.93 331.2   207.8    157.2    90.50
## 
## $STM_Parameters
##   FMZ Group       Wby_Lid       Lake_Name Latitude Longitude Elevation
## 1   5     0 15-3523-55336 South Scot Lake    49.94    -95.06       343
## 2   5     0 15-3532-55170  Whitefish Lake    49.79    -95.04       366
## 3   4     0 15-3543-56122  Wingiskus Lake    50.65    -95.06       335
## 4   5     0 15-3559-55281    Malachi Lake    49.89    -95.01       333
## 5   5     0 15-3653-55394     Cygnet Lake    49.99    -94.88       331
## 6   5     0 15-3654-55172   Pickerel Lake    49.79    -94.87       366
##   Area_ha Shoreline Depth_Max Depth_Mn Secchi  DOC    Period    TX   TN
## 1     397       4.4      10.0      3.5   1.45 12.4 2001-2010 25.01 8.16
## 2     216       3.4      20.1      7.0   2.50  6.8 2001-2010 25.26 6.85
## 3     692       5.1      19.0      7.7   3.20 12.1 2001-2010 24.35 7.39
## 4    1054       6.7      19.8      7.9   3.10  8.4 2001-2010 24.67 7.60
## 5    1318       8.8      11.0      4.1   1.80  9.9 2001-2010 24.58 8.59
## 6     602       6.1      27.5      7.4   4.25  6.2 2001-2010 25.10 6.37
##      JS    JM    JE   ZTH    ZM ZJ   SP IceBU IceFU Icefree DataGood
## 1 120.9 218.4 290.9  9.68  9.68  0 4.51 123.9 324.7   200.8     TRUE
## 2 125.4 218.4 301.7  8.90  8.90  0 4.49 123.5 330.5   207.0     TRUE
## 3 123.1 218.1 301.6 11.09 11.09  0 4.55 126.0 329.4   203.4     TRUE
## 4 151.1 218.3 303.4 11.91 11.91  0 4.52 123.5 331.6   208.1     TRUE
## 5 156.1 218.1 293.2 11.80 11.80  0 4.58 123.8 325.9   202.1     TRUE
## 6 131.1 218.1 306.7 10.90 10.90  0 4.56 123.4 331.2   207.8     TRUE
##   LakeNumber Stratified Do_Space Do_ThermoPic
## 1         NA      FALSE     TRUE         TRUE
## 2     12.781       TRUE     TRUE         TRUE
## 3      7.001       TRUE     TRUE         TRUE
## 4      6.033       TRUE     TRUE         TRUE
## 5         NA      FALSE     TRUE         TRUE
## 6      9.655       TRUE     TRUE         TRUE
```


```r
fitted_model = thermopic_model(path = '../misc/tutorial_project',
                                Lake = lake_example,
                                Climate = climate_example)
```

### Visualizing thermal habitat in lakes -- `thermopic_report`


```r
report_data = thermopic_report(path = '../misc/tutorial_project',
                               STM_Parameters = '4_STM_Parameters.csv',
                               Options = '0_User_Options.csv',
                               Nlakes_test = 5)
head(report_data)
```

```
##   FMZ       Wby_Lid       Lake_Name Area_ha Depth_Max Depth_Mn Stratified
## 1   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
## 2   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
## 3   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
## 4   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
## 5   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
## 6   5 15-3523-55336 South Scot Lake     397        10      3.5      FALSE
##      Period TRange PD_year TSeasons PD_season1 Jstart_Spr Jend_Spr
## 1 2001-2010  T0812   0.110        2      0.575        121      143
## 2 2001-2010  T1216   0.110        2      0.575        144      166
## 3 2001-2010  T1620   0.110        2      0.575        167      189
## 4 2001-2010  T2024   0.112        2      0.561        190      212
## 5 2001-2010  T2428   0.027        1      1.000        213       NA
## 6 2001-2010  T2832   0.000        0         NA         NA       NA
##   Jstart_Aut Jend_Aut PV_JM PV_mean PV_sd PV_min PV_max PV_year PA_JM
## 1        275      291    NA     100     0    100    100    11.0    NA
## 2        258      274    NA     100     0    100    100    11.0    NA
## 3        241      257    NA     100     0    100    100    11.0    NA
## 4        223      240    NA     100     0    100    100    11.2    NA
## 5         NA      222   100     100     0    100    100     2.7   100
## 6         NA       NA     0       0    NA     NA     NA     0.0     0
##   PA_mean PA_sd PA_min PA_max PA_year
## 1     100     0    100    100    11.0
## 2     100     0    100    100    11.0
## 3     100     0    100    100    11.0
## 4     100     0    100    100    11.2
## 5     100     0    100    100     2.7
## 6       0    NA     NA     NA     0.0
```


```r
report_data = thermopic_report(path = '../misc/tutorial_project',
                               STM_Parameters = fitted_model$STM_Parameters)
```

### Looking at the thermopics


```r
print_directory_tree('../misc/tutorial_project')
```

```
## tutorial_project                                           
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


![](https://github.com/stevencarlislewalker/thermopic/blob/master/inst/misc/tutorial_project/DataOut/ThermoPics/4_Wingiskus%20Lake_15-3543-56122_P2001-2010.jpeg)
