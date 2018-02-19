#' thermopic: Predicting and visualizing the seasonal available of thermal habitat in lakes
#' 
#' A ThermoPic is a picture of thermal habitat in a lake. This software serves
#' three purposes. First, it predicts the seasonal temperature cycle in lakes
#' based on easily measured variables. Second, it calculates and reports thermal
#' habitat statistics. Third, it generates a ThermoPic plot. The model used to 
#' predict temperature is referred to as the Seasonal Temperature Model (STM). 
#' It was created by Minns et al. (2016) based on data from lakes in the province 
#' of Ontario (Canada).
#' 
#' The thermopic package works with thermopic projects, which are filesystem directories
#' with a special structure
#' 
#' TODO: describe how to use the package with reference to the original pdf document
#' @docType package
#' @name thermopic
#' @importFrom utils write.csv
#' 
#' @section Introduction:
#' 
#' A ThermoPic is a picture of thermal habitat in a lake.  Given that the seasonal temperature cycle is known or can be predicted  (Figure 1), one can calculate for each day of the year how much habitat exists within specified bands of temperature (e.g., 8-12 °C, 12-16 °C, 16-20 °C, etc.).  A ThermoPic can then be produced by plotting \% volume (or area) of habitat versus day of year  (Figure 2).  Because fish species differ in terms their preferred temperatures, this plot is a very useful summary of the thermal habitat available for different species.
#' 
#' The ThermoPic software serves three purposes.  First, it predicts the seasonal temperature cycle in lakes based on easily measured variables (i.e., lake morphometry and climate).  Second, it calculates and reports thermal habitat statistics.  Third, it generates a ThermoPic plot.  The model used to predict temperature is referred to as the Seasonal Temperature Model (STM).  It was created by Minns et al. (2016) based on data from lakes in the province of Ontario (Canada).   The STM is based on seven parameters (see Figure 3), each of which can be predicted given the following lake data inputs:  location (latitude, longitude, elevation), morphometry (surface area, shoreline length,  maximum depth and mean depth),  water chemistry (Secchi, DOC), air temperature cycle (monthly means), and precipitation in August.  Formulae used to calculate the STM parameters are given in this Guide, including formulae for dealing with missing data (i.e., Secchi, DOC, Shoreline).
#' 
#' \figure{seasonal_temperature_cycles.png}{Cycles}
#' \figure{thermopic_example.png}{Thermopic}
#' \figure{seasonal_temperature_model.png}{Model}
NULL
