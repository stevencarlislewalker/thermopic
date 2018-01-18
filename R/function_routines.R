#' Interpolate Julian Dates
#' 
#' (Model) Interpolate Julian dates for reference temperatures 
#' in spring and fall from monthly mean temperatures.
#' 
#' @param tvec data frame with mean monthly temperatures from Dec (Y-1) 
#' through Jan-Dec (Y) to Jan(Y+1)
#' @param tref threshold temperature C
#' @param tdir value indicates whether the temperature is rising (1) or falling (-1)
#' @param yy calendar year (allows day counts to be adjusted for leap years)
tdatev <- function(tvec,tref,tdir,yy)
{
  tstore <- data.frame(postn = c(1:14),
                       dinm = c(31,31,28.25,31,30,31,30,31,31,30,31,30,31,31),
                       dcum = c(rep(0,14)), hdinm = c(rep(0,14)),hdcum = c(rep(0,14)))
  for (j in 2:14) 
  { 
    tstore$dcum[j] <- tstore$dcum[j-1] + tstore$dinm[j]
    tstore$hdcum[j] <- (tstore$dcum[j]+tstore$dcum[j-1])/2
  }
  tstore$hdcum[1] <- -tstore$dinm[1]/2
  tstore$value <- -99
  if (tdir > 0)
  {
    for (m in 2:13) 
    {
      mm <- m-1
      t1 <- tvec$tmp[mm];t2 <- tvec$tmp[m];d1 <- tstore$hdcum[mm];d2 <- tstore$hdcum[m]
      tstore$value[m] <- ifelse(t1 < tref,ifelse(t2 >= tref,d1+(d2-d1)*(tref-t1)/(t2-t1),-99),-99)
    }
  }
  else
  {
    for (m in 2:13) 
    {
      mp <- m+1
      t1 <- tvec$tmp[m];t2 <- tvec$tmp[mp];d1 <- tstore$hdcum[m];d2 <- tstore$hdcum[mp]
      tstore$value[m] <- ifelse(t1 > tref,ifelse(t2 <= tref,d1+(d2-d1)*(t1-tref)/(t1-t2),-99),-99)
    }
  }
  tdatev <- max(tstore$value)
}

#' Get Solar Elevation and Azimuth 
#' 
#' (Model) Get solar elevation and azimuth for a specified date and location.
#' The implementation follows the Astronomer's Almanac algorithm.
#'
#' @param year TODO
#' @param month TODO
#' @param day TODO
#' @param hour TODO
#' @param min TODO
#' @param sec TODO
#' @param lat TODO
#' @param long TODO
#' 
#' @references 
#' Joseph J. Michalsky. 
#' The astronomical almanacs algorithm for approximate solar position (19502050). 
#' Solar Energy, 40(3):227235, 1988.
#' It's straightforward to translate it in any other language:
#' http://stackoverflow.com/questions/257717/position-of-the-sun-given-time-of-day-and-lat-long
#'
#' http://www.esrl.noaa.gov/gmd/grad/solcalc/
#' Checked against NOAA on-line calculator
#' 
SunPosition <- function(year, month, day, hour=12, min=0, sec=0,lat,long) 
{
  twopi <- 2 * pi
  deg2rad <- pi / 180
  
  # Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
  month.days <- c(0,31,28,31,30,31,30,31,31,30,31,30)
  day <- day + cumsum(month.days)[month]
  leapdays <- year %% 4 == 0 & (year %% 400 == 0 | year %% 100 != 0) & day >= 60
  day[leapdays] <- day[leapdays] + 1
  
  # Get Julian date - 2400000
  hour <- hour + min / 60 + sec / 3600 # hour plus fraction
  delta <- year - 1949
  leap <- trunc(delta / 4) # former leapyears
  jd <- 32916.5 + delta * 365 + leap + day + hour / 24
  
  # The input to the Atronomer's almanach is the difference between
  # the Julian date and JD 2451545.0 (noon, 1 January 2000)
  time <- jd - 51545.
  
  # Ecliptic coordinates
  
  # Mean longitude
  mnlong <- 280.460 + .9856474 * time
  mnlong <- mnlong %% 360
  mnlong[mnlong < 0] <- mnlong[mnlong < 0] + 360
  
  # Mean anomaly
  mnanom <- 357.528 + .9856003 * time
  mnanom <- mnanom %% 360
  mnanom[mnanom < 0] <- mnanom[mnanom < 0] + 360
  mnanom <- mnanom * deg2rad
  
  # Ecliptic longitude and obliquity of ecliptic
  eclong <- mnlong + 1.915 * sin(mnanom) + 0.020 * sin(2 * mnanom)
  eclong <- eclong %% 360
  eclong[eclong < 0] <- eclong[eclong < 0] + 360
  oblqec <- 23.429 - 0.0000004 * time
  eclong <- eclong * deg2rad
  oblqec <- oblqec * deg2rad
  
  # Celestial coordinates
  # Right ascension and declination
  num <- cos(oblqec) * sin(eclong)
  den <- cos(eclong)
  ra <- atan(num / den)
  ra[den < 0] <- ra[den < 0] + pi
  ra[den >= 0 & num < 0] <- ra[den >= 0 & num < 0] + twopi
  dec <- asin(sin(oblqec) * sin(eclong))
  
  # Local coordinates
  # Greenwich mean sidereal time
  gmst <- 6.697375 + .0657098242 * time + hour
  gmst <- gmst %% 24
  gmst[gmst < 0] <- gmst[gmst < 0] + 24.
  
  # Local mean sidereal time
  lmst <- gmst + long / 15.
  lmst <- lmst %% 24.
  lmst[lmst < 0] <- lmst[lmst < 0] + 24.
  lmst <- lmst * 15. * deg2rad
  
  # Hour angle
  ha <- lmst - ra
  ha[ha < -pi] <- ha[ha < -pi] + twopi
  ha[ha > pi] <- ha[ha > pi] - twopi
  
  # Latitude to radians
  lat <- lat * deg2rad
  
  # Azimuth and elevation
  el <- asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha))
  az <- asin(-cos(dec) * sin(ha) / cos(el))
  elc <- asin(sin(dec) / sin(lat))
  az[el >= elc] <- pi - az[el >= elc]
  az[el <= elc & ha > 0] <- az[el <= elc & ha > 0] + twopi
  
  el <- el / deg2rad
  az <- az / deg2rad
  lat <- lat / deg2rad
  
  return(list(elevation=el, azimuth=az))
}

#' Find Area
#' 
#' (Model and Report) Find the area between two depths in a lake
#' 
#' @param area TODO
#' @param zmn TODO
#' @param zmx TODO
#' @param ztarget TODO
FindArea <- function(area,zmn,zmx,ztarget) {
  zrat <- zmn/zmx
  rli <- (1-zrat)/zrat
  zarea <- area*(1-ztarget/zmx)^rli
  return(zarea)
}

#' Find Day
#' 
#' (Report) Calculate a julian day for a given temperature based on a known
#' day with known temperature and known slope of temperature change
#' 
#' @param endtemp TODO
#' @param startday TODO
#' @param starttemp TODO
#' @param tslope TODO
FindDay <- function (endtemp,startday,starttemp,tslope)
{
  dtemp <- endtemp-starttemp
  dday <- dtemp/tslope
  endday <- startday+dday
  return(endday)
}

#' Find Temperature
#' 
#' (Report) Calculate a temperature for a given day based on a known day
#' with known temperature and known slope of temperature change
#' 
#' @param endday TODO
#' @param startday TODO
#' @param starttemp TODO
#' @param tslope TODO
FindTemp <- function (endday,startday,starttemp,tslope)
{
  dday <- endday-startday
  dtemp <- dday*tslope
  endtemp <- starttemp+dtemp
  return(endtemp)
}

#' Find Volume
#' 
#' (Report) Find the volume between two depths in a lake 
#' 
#' @param area TODO
#' @param zmn TODO
#' @param zmx TODO
#' @param zstart TODO
#' @param zend TODO
#' @importFrom stats integrate
FindVol <- function(area,zmn,zmx,zstart,zend) {
  zrat <- zmn/zmx
  rli <- (1-zrat)/zrat
  integrand <- function(z) {area*(1-z/zmx)^rli}
  vol <- integrate(integrand,zstart,zend)$val
  return(vol)
}

#' Find Depth
#' 
#' (Report) Find the depth at a particular temperature in a lake
#' 
#' @param zmx TODO
#' @param tx TODO
#' @param tn TODO
#' @param js TODO
#' @param jm TODO
#' @param je TODO
#' @param zm TODO
#' @param zj TODO
#' @param sp TODO
#' @param jd TODO
#' @param targettemp TODO
FindDepth <- function(zmx,tx,tn,js,jm,je,zm,zj,sp,jd,targettemp) {
  topdepth <- 0
  bottomdepth <- zmx
  middepth <- ifelse( jd > js, zm*(jd-js)/(zj+jd-js),(topdepth+bottomdepth)/2)
  while (bottomdepth - topdepth > 0.005) {
    toptemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,topdepth)
    midtemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,middepth)
    bottomtemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,bottomdepth)
    if (targettemp >= midtemp && targettemp <= toptemp) {
      topdepth <- topdepth
      bottomdepth <- middepth
      middepth <- (topdepth+bottomdepth)/2}
    if (targettemp < midtemp && targettemp >= bottomtemp) {
      topdepth <- middepth
      bottomdepth <- bottomdepth
      middepth <- (topdepth+bottomdepth)/2}
    if (targettemp > toptemp || targettemp < bottomtemp) {
      middepth <- NA
      break}}
  finaldepth <- ifelse (middepth < 0.5,0,middepth)
  return(finaldepth)}

#' Find Habitat Volume and Area
#' 
#' (Report) Find the volume and area between two temperatures in a lake
#' 
#' @param tx TODO
#' @param tn TODO
#' @param js TODO
#' @param jm TODO
#' @param je TODO
#' @param zm TODO
#' @param zj TODO
#' @param sp TODO
#' @param jd TODO
#' @param zmx TODO
#' @param area TODO
#' @param zmn TODO
#' @param lakevol TODO
#' @param upperlimit TODO
#' @param lowerlimit TODO
FindHabitat <- function(tx,tn,js,jm,je,zm,zj,sp,jd,zmx,area,zmn,lakevol,upperlimit,lowerlimit){
  maxtemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,0)
  mintemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,zmx)
  if (lowerlimit <= mintemp) {upperdepth <- NA
  } else {
    if (upperlimit >= maxtemp) {upperdepth <- 0
    } else {upperdepth <- FindDepth(zmx,tx,tn,js,jm,je,zm,zj,sp,jd,upperlimit)}}
  if (lowerlimit >= maxtemp) {lowerdepth <- NA
  } else {
    if (lowerlimit <= mintemp) {lowerdepth <- zmx
    } else {lowerdepth <- FindDepth(zmx,tx,tn,js,jm,je,zm,zj,sp,jd,lowerlimit)}}
  HabitatVol <- ifelse (is.na(upperdepth) || is.na(lowerdepth),0,FindVol(area,zmn,zmx,upperdepth,lowerdepth))
  HabitatSpace <- round(HabitatVol/lakevol, digits = 3)
  return(c(HabitatSpace,upperdepth,lowerdepth))}


#' Find Habitat Depth
#' 
#' (Report) Find the depth for a given temperature in a lake
#' 
#' @param tx TODO
#' @param tn TODO
#' @param js TODO
#' @param jm TODO
#' @param je TODO
#' @param zm TODO
#' @param zj TODO
#' @param sp TODO
#' @param jd TODO
#' @param zmx TODO
#' @param area TODO
#' @param zmn TODO
#' @param T1 TODO
#' @param T2 TODO
FindHabZ <- function(tx,tn,js,jm,je,zm,zj,sp,jd,zmx,area,zmn,T1,T2){
  maxtemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,0)
  mintemp <- stm(tx,tn,js,jm,je,zm,zj,sp,jd,zmx)
  if ( mintemp < T1 && maxtemp < T1) {Tdepth <- NA}
  if ( mintemp >= T2 && maxtemp >= T2) {Tdepth <- NA}
  if ( mintemp < T1 && maxtemp >= T1) {Tdepth <- FindDepth(zmx,tx,tn,js,jm,je,zm,zj,sp,jd,T1)}
  if ( mintemp < T2 && maxtemp >= T2) {Tdepth <- zmx}
  if ( mintemp < T1 && maxtemp >= T2) {Tdepth <- FindDepth(zmx,tx,tn,js,jm,je,zm,zj,sp,jd,T1)}
  if ( mintemp >= T1 && maxtemp < T2) {Tdepth <- zmx}
  return(Tdepth)
}

#' Spatial Habitat Statistics
#' 
#' (Report) Calculate Annual Summary Habitat Space Statistics
#' based on Daily Predictions from the STM model for the period
#' Spring isothermal at 4C to Fall/Autumn isothermal at 4C
#' Detects Presence of One Continuous  or Two Seasons of Availability
#' For Stratified and Unstratified Lakes Respectively
#' 
#' @param hssub TODO
#' @param JM TODO
#' @importFrom stats sd
SpStats <-  function(hssub,JM){
  # Seasonal Component
  Ct <- length(hssub$Doy)
  WinV  <-  ifelse(length(hssub$Doy) <= 1,0,round(length(hssub$Doy)/365, digits = 3))
  WinSt <-  hssub$Doy[1]
  WinEn <-  hssub$Doy[Ct]
  hssub$Seas <- c(0:(Ct-1))
  hssub$Seas <- hssub$Seas +WinSt - hssub$Doy
  hssub$Seas <- ifelse(hssub$Seas < 0,2,1)
  ts <- as.data.frame(table(hssub$Seas))
  Seas <- nrow(ts)
  PSpr <- round(ts$Freq[1]/Ct,digits=3)
  SprEn <- NA
  AutSt <- NA
  if(Seas > 1) {
    SprEn <- hssub$Doy[ts$Freq[1]]
    AutSt <- hssub$Doy[ts$Freq[1]+1]
  }
  # Annual Volume Stats
  Vmean <-  round(mean(hssub$V), digits = 2)
  Vsd   <-  round(sd(hssub$V), digits = 2)
  Vmax  <-  round(max(hssub$V),digits = 2)
  Vmin  <-  round(min(hssub$V),digits = 2)
  # Annual Area Stats
  Amean <-  round(mean(hssub$A), digits = 2)
  Asd   <-  round(sd(hssub$A), digits = 2)
  Amax  <-  round(max(hssub$A),digits = 2)
  Amin  <-  round(min(hssub$A),digits = 2)
  # Midsummer Metrics
  if( Seas == 1 && round(JM) > min(hssub$Doy) && round(JM) < max(hssub$Doy)) {
    VJM   <-  round(hssub$V[hssub$Doy == round(JM)],digits=2)
    AJM   <-  round(hssub$A[hssub$Doy == round(JM)],digits=2)
  } else {
    VJM <- NA
    AJM <- NA
  }
  list(WinV,WinSt,WinEn,Vmean,Vsd,Vmax,Vmin,VJM,Amean,Asd,Amax,Amin,AJM,Seas,PSpr,SprEn,AutSt)
}

#' Seasonal Temperature Model
#' 
#' (Model and Report) Find the water temperature at a given depth on a given day in a lake
#' 
#' @param tx STM parameter maximum surface temperature on JM
#' @param tn STM parameter hypolimnetic temperature at onset of stratification JS
#' @param js STM parameter day of onset of stratification
#' @param jm STM parameter day of peak surface temperature
#' @param je STM parameter day of end of stratification
#' @param zm STM parameter maximum thermocline depth
#' @param zj STM parameter number of days after JS when ZTH attains ZM/2
#' @param sp STM parameter steepness of transition from epi- to hypo-limnion
#' @param jd FIXME: Julian day?
#' @param z FIXME: depth?
stm <- function(tx,tn,js,jm,je,zm,zj,sp,jd,z)
{
  zt <- ifelse( jd > js, zm*(jd-js)/(zj+jd-js),0.0)
  pz <- ifelse( zt > 0.0,zt^sp/(zt^sp+z^sp),1.0)# Proportional scaling with depth
  jx <- (je*(jm-js)+pz*js*(je-jm))/((jm-js)+pz*(je-jm))# Julian date of peak temperature at depth z
  tp <- tn+(tx-tn)*(je-jx)/(je-jm)# Peak temperature at depth z
  spr <- (tp - tn)/(jx - js) # daily warming rate at surface in spring
  fall <- (tx - tn)/(je - jm)# daily cooling rate at all depth after peak in fall
  tmoda <- tp -spr*(jd <= jx)*(jx - jd) - fall*(jd > jx)*(jd-jx)# predicted temperature given jd and z
  tmodb <- tx - (tx - tn)*(jm-jd)/(jm-js)
  tmodc <- tx - (tx - tn)*(jd-jm)/(je-jm)
  stm <- ifelse( jd <= js,tmodb,ifelse( jd >= je,tmodc,tmoda))
}
