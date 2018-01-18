#' Thermopic Report
#' 
#' @param path Character string containing the path to the root of a thermopic project
#' @param spaced TODO
#' @param Options TODO
#' @param show_progress_bar Should progress bar be displayed to show 
#' percentage of lakes analyzed?  Note that this should be FALSE unless
#' running in interactive mode at a console.
#' @export
#' @importFrom RColorBrewer brewer.pal
#' @importFrom utils txtProgressBar
#' @importFrom utils setTxtProgressBar
#' @importFrom stats na.omit
#' @importFrom grDevices tiff
#' @importFrom grDevices jpeg
#' @importFrom grDevices dev.off
#' @importFrom graphics plot
#' @importFrom graphics axis
#' @importFrom graphics lines
#' @importFrom graphics polygon
#' @importFrom graphics text
#' @importFrom graphics box
thermopic_report = function(path, spaced, Options, show_progress_bar = FALSE) {
  
  spaced = get_thermopic_data(spaced, path, 'DataOut')
  Options = get_thermopic_data(Options, path, 'DataIn')
  
  #==================================================================
  #Process User Options
  #------------------------------------------------------------------
  Nlakes_test<-as.numeric(as.character(Options$User[5]))
  
  
  # Switch for turning off all plotting
  ThermoPic_on <- ifelse(Options$User[1]=="Yes",TRUE,FALSE)
  if (!ThermoPic_on) {spaced$Do_ThermoPic <- FALSE}
  
  TP_interval  <- as.numeric(as.character(Options$User[2]))
  TP_text      <- as.character(TP_interval)
  TP_interval  <- as.numeric(TP_interval)
  TP_interval  <- ifelse(TP_interval>4,4,TP_interval)
  TP_interval  <- ifelse(TP_interval<1,4,TP_interval)
  
  # Choose format = TIFF or JPEG
  TP_format    <- Options$User[3]
  
  # Change default folder for ThermoPics
  TP_folder    <- Options$User[4]
  
  #----------------------------------------------------------------------------
  # Set Paramaters and Labels for Space Calculations
  #----------------------------------------------------------------------------
  #
  # Temperature Boundaries (Only Inner Temperature Ranges are Analyzed)
  # Default TP_interval is 4 degrees
  
  TmpBnds <- c(0,8,12,16,20,24,28,32,50)
  
  if (TP_interval<4)
  {
    if (TP_interval == 1) {TmpBnds <- c(0,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,50)}
    if (TP_interval == 2) {TmpBnds <- c(0,8,10,12,14,16,18,20,22,24,26,28,30,32,50)}
    if (TP_interval == 3) {TmpBnds <- c(0,8,11,15,18,21,24,27,30,33,50)}
    file_outsheet4<- paste("5_ThermalSpace",TP_text,"D",sep="")
    TP_root  <- paste(TP_folder,"/TP",TP_interval,"_",sep="")
  }
  NTmps <- length(TmpBnds)
  NTmpI <- NTmps-1
  NTInt <- NTmpI-2
  TmpCHARS <- as.character(TmpBnds)
  TmpCHARS <- ifelse(nchar(TmpCHARS) < 2,paste("0",TmpCHARS,sep=""),TmpCHARS)
  
  # The generation of these col names could be automated
  Ztype <- paste("Z",TmpCHARS,sep="")
  Ttype <- rep("Txxxx",NTmpI)
  Vtype <- rep("V:xx-xxC",NTmpI)
  Atype <- rep("V:xx-xxC",NTmpI)
  for (i in 1:NTmpI)
  {
    Ttype[i] <- paste("T",TmpCHARS[i],TmpCHARS[i+1],sep="")
    Vtype[i] <- paste("V:",TmpCHARS[i],"-",TmpCHARS[i+1],"C",sep="")
    Atype[i] <- paste("A:",TmpCHARS[i],"-",TmpCHARS[i+1],"C",sep="")
  }
  Vtype[1] <- paste("V:LT ",TmpCHARS[2],"C",sep="")
  Vtype[NTmpI] <- paste("V:GT ",TmpCHARS[NTmpI],"C",sep="")
  Atype[1] <- paste("A:LT ",TmpCHARS[2],"C",sep="")
  Atype[NTmpI] <- paste("A:GT ",TmpCHARS[NTmpI],"C",sep="")
  
  Speccols <- rev(brewer.pal(n = NTmpI-2, name = 'Spectral'))
  Tmpcol <-c("grey75",Speccols,"grey25")
  
  #Tmpcol <-c("grey75","blue2","green2","yellow2","orange2","red2","grey25")
  #Tmpcol <-c("grey75","blue2","xx","green2","xx","yellow2","xx","orange2","xx","red2","xx","grey25")
  
  #
  #--------------------------------------------------------
  # Computing Daily Thermal Habitat (Volume and Area)
  # Calculate Annual Summary Statistics
  #--------------------------------------------------------
  #
  ii <- 0;# Internal Counter For Tracking Accumulation of Summary Statistics
  HdSpSum.Accum <- NULL  #Initialize summary data collecting dataframe
  
  Nlakes <- length(spaced$Lake_Name)
  if (Nlakes_test > 0)
  {
    Nlakes <- Nlakes_test
  }
  
  lake_progress_bar = txtProgressBar(max = Nlakes, style = 3)
  for (i in 1:Nlakes)
    # Begin: Lake loop
  {
    if (spaced$Do_Space[i] == TRUE )
      # Begin: If Do_Space
    {
      ii <- ii+1
      # Prepare DF for descriptive data
      Lake.info <- data.frame(FMZ=spaced$FMZ[i], Wby_Lid=spaced$Wby_Lid[i],Lake_Name=spaced$Lake_Name[i],Area_ha=spaced$Area_ha[i],Depth_Max=spaced$Depth_Max[i],Depth_Mn=spaced$Depth_Mn[i],Stratified=spaced$Stratified[i],Period=spaced$Period[i],TRange=NA)
      # Set column number of WinSt
      cstart <- 11
      
      # Extract Lake and STM Characteristics
      Area_ha <- spaced$Area_ha[i]
      Depth_Mn <- spaced$Depth_Mn[i]
      Depth_Max <- spaced$Depth_Max[i]
      TX <- spaced$TX[i]
      TN <- spaced$TN[i]
      JS <- spaced$JS[i]
      JM <- spaced$JM[i]
      JE <- spaced$JE[i]
      ZM <- spaced$ZM[i]
      ZJ <- spaced$ZJ[i]
      SP <- spaced$SP[i]
      # Compute 4C dates
      JS4 <- round(JS - (JM - JS)*(TN - 4)/(TX - TN),0)
      JE4 <- round(JE + (JE-JM)*(TN - 4)/(TX - TN),0)
      # Extract Predicted Ice Dates
      IBU <- spaced$IceBU[i]
      IFU <- spaced$IceFU[i]
      # Prepare variables and DF for computation
      duration <- JE4-JS4+1
      hs <- matrix(data=NA,nrow = duration,ncol = (1+NTmps+2*NTmpI), byrow = FALSE, dimnames = NULL)
      habsp <- as.data.frame(hs)
      colnames(habsp) <- c("Doy",Ztype,Vtype,Atype)
      habsp$Doy <- c(JS4:JE4)
      
      # Determine total lake volume
      LakeV <- FindVol(Area_ha,Depth_Mn,Depth_Max,0,Depth_Max)
      
      if (spaced$Stratified[i] == TRUE)
      {
        # Begin: Stratified lake
        for (j in 1:duration)
          # Begin: Day loop (Strat=Yes)
        {
          # Loop to find habitat suitability from JE4 to JS4 for each Doy
          # Begin: Temperature loop
          for (k in 1:NTmpI)
          {
            # Finds depths for temperatures
            DoyTz <- FindHabZ(TX,TN,JS,JM,JE,ZM,ZJ,SP,habsp$Doy[j],Depth_Max,Area_ha,Depth_Mn,TmpBnds[k],TmpBnds[k+1])
            habsp[j,(1+k)] <- DoyTz
          }
          # Compute volumes and areas
          for (l in 1:NTmpI)
          {
            DoyHVol <- NA
            DoyHArea <- NA
            if (is.na(habsp[j,(1+l)])|| habsp[j,(1+l)] <= 0)
            {
              if (is.na(habsp[j,(2+l)]) || habsp[j,(2+l)] <= 0)
              {
                DoyHVol <- NA
                DoyHArea <- NA
              }
              else
              {
                DoyHVol <- FindVol(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+2)],Depth_Max)
                DoyHArea <- FindArea(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+2)])
              }
            }
            else
            {
              if (is.na(habsp[j,(2+l)]))
              {
                DoyHVol <- FindVol(Area_ha,Depth_Mn,Depth_Max,0,habsp[j,(l+1)])
                DoyHArea <- Area_ha-FindArea(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+1)])
              }
              else
              {
                DoyHVol <- FindVol(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+2)],habsp[j,(l+1)])
                DoyHArea <- FindArea(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+2)])-FindArea(Area_ha,Depth_Mn,Depth_Max,habsp[j,(l+1)])
              }
            }
            habsp[j,NTmps+l+1] <- round(100.0*DoyHVol/LakeV,digits=2)
            habsp[j,NTmps+NTmpI+l+1] <- round(100.0*DoyHArea/Area_ha,digits=2)
          }
          # End: Temperature loop
        }
        # End: Stratified lake
      }
      else
      {
        # Begin: Non-Stratified lake
        for (j in 1:duration)
        {
          # Begin: Day loop (Non-Stratified)
          # Loop to find habitat suitability from JE4 to JS4 for each Doy
          DJ <- habsp$Doy[j]
          TJ <- ifelse( DJ <= JM, 4+(TX-4)*(DJ-JS4)/(JM-JS4),4+(TX-4)*(JE4-DJ)/(JE4-JM))
          
          for (l in 1:NTmpI)
          {
            if ( TJ >= TmpBnds[l] && TJ < TmpBnds[l+1])
            {
              # Assign volumes and areas if present
              habsp[j,NTmps+l+1] <- round(100.0,digits=2)
              habsp[j,NTmps+NTmpI+l+1] <- round(100.0,digits=2)
            }
          }
          # End: Non-Stratified lake
        }
        # End: If/Else for Stratified (back 73 lines)
      }
      
      #----------------------------------------------------------------------------
      # Compute Lake Summary Space Statistics
      #----------------------------------------------------------------------------
      
      # Temperature range loop begins
      for (k in 2:(NTmps-2))
      {
        # Select Temp Range Results
        Lake.info$TRange <- as.character(Ttype[k])
        hssub <- na.omit(habsp[ ,c(1,(1+NTmps+k),(1+NTmps+NTmpI+k))])
        if (length(hssub$Doy)> 0)
        {
          colnames(hssub) <- c("Doy","V","A")
          # Compute Statistics
          SpSum <- SpStats(hssub,JM)
          SpSum <- as.data.frame(SpSum)
          colnames(SpSum) <- c("WinV","WinSt","WinEn","Vmean","Vsd","Vmax","Vmin","VJM","Amean","Asd","Amax","Amin","AJM","Seas","PSpr","SprEn","AutSt")
        }
        else
        {
          SpSum <- data.frame(WinV=c(0),WinSt=NA,WinEn=NA,Vmean=c(0),Vsd=NA,Vmax=NA,Vmin=NA,VJM=c(0),Amean=c(0),Asd=NA,Amax=NA,Amin=NA,AJM=c(0),Seas=c(0),
                              PSpr=NA,SprEn=NA,AutSt=NA)
        }
        # Add Header
        HdSpSum <- data.frame(Lake.info,SpSum)
        #--------------------------------------------------------
        # Accumulate Results
        
        if (ii == 1 && k == 2)
        {HdSpSum.Accum <- HdSpSum}
        else {HdSpSum.Accum <- rbind(HdSpSum.Accum,HdSpSum)}
      }
      
      #----------------------------------------------------------------------------
      # Plotting Occupancy Polygons
      #----------------------------------------------------------------------------
      # Only do ThermoPics for cases with Do_ThermoPic = TRUE
      
      if (spaced$Do_ThermoPic[i] == TRUE )
        # Begin: if Do_Thermopic
      {
        # Create Label for a lake
        FMZ<- spaced$FMZ[i]
        Wby_Lid <- spaced$Wby_Lid[i]
        Lake_Name <- spaced$Lake_Name[i]
        Period <- spaced$Period[i]
        figure_label <- paste(FMZ," ",Lake_Name," (",Wby_Lid,"): ",Period,sep="")
        #TP_root <- "Data/TP4_"
        # Write TIFF or JPEG File for a Lake (Or plot on screen)
        #--------------------------------------------------------
        if(TP_format == "TIFF")
        {TIFFName <- paste(TP_root,FMZ,"_",Lake_Name,"_",Wby_Lid,"_P",Period,".tiff",sep="")
        #tiff(filename = TIFFName, width = 5, height = 8, units = "in", compression= "lzw",,bg = "white",res=400)
        tiff(filename = TIFFName, width = 5, height = 7, units = "in", pointsize=18, compression= "lzw",bg = "white",res=400)
        }
        if(TP_format == "JPEG")
        {JPEGName <- paste(TP_root,FMZ,"_",Lake_Name,"_",Wby_Lid,"_P",Period,".jpeg",sep="")
        jpeg(filename = JPEGName, width = 400, height = 600, units = "px", pointsize=20, bg="white", res=NA, family="")
        }
        
        # Plot Instructions Begin
        opar <- par
        par(mfrow=c(1,1), mar=c(2.5,3.0,0.5,0.5),mgp=c(2,0.5,0),cex=0.8)
        
        for (ifish in 2:(NTmpI-1))
        {
          fhcol <- Tmpcol[ifish]
          #Doy.St <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,11]
          #Doy.En <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,12]
          # cstart is 11 to access column with WinSt
          Doy.St <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,cstart]
          Doy.En <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,cstart+1]
          if (is.na(Doy.St) == "FALSE" )
          {
            x <- c(Doy.St:Doy.En)
            Doy.min <- min(habsp$Doy)
            x.rows <- c((Doy.St-Doy.min+1):(Doy.En-Doy.min+1))
            y.low <- rep((0+(ifish-2)*100),(Doy.En-Doy.St+1))
            # base is y.low or NA
            y.high <- ifelse(is.na(habsp[x.rows ,NTmps+1+ifish]),y.low,y.low+habsp[x.rows ,NTmps+1+ifish])
            pldt <- na.omit(data.frame(Doy=x,Vlo=y.low,Vhi=y.high))
            
            if (ifish == 2)
            {
              plot(Vhi~Doy,pldt,type = 'n', ylim = c(-25,650),xlim=c(1,365),las=1,
                   ylab = "Percentage of lake volume", xlab = NA,axes=FALSE)
              xticks = c(0, 32, 60, 91, 121, 152, 182,213,244,274,305,335,366)
              xtlabs = c("  Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan")
              axis(side = 1, at = xticks,labels=xtlabs,cex.axis=0.8)
              yticks = c(0,50,100,150,200,250,300,350,400,450,500,550,600)
              ytlabs = c("  0","50","100","50","100","50","100","50","100","50","100", "50", "100")
              axis(side = 2,at = yticks,labels=ytlabs,cex.axis=0.8,las=1)
            }
            
            if(HdSpSum.Accum[(ii-1)*NTInt+ifish-1,cstart+12]== 1)
            {
              #One Season
              lines(pldt$Doy,pldt$Vlo, col = fhcol)
              lines(pldt$Doy,pldt$Vhi, col = fhcol)
              polygon(c(pldt$Doy, rev(pldt$Doy)), c(pldt$Vhi, rev(pldt$Vlo)),
                      col = fhcol, border = NA)
            }
            else
            {
              #Two Seasons
              #Spring
              #Doy.SprEn <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,25]
              Doy.SprEn <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,cstart+14]
              x.rows <- c(1:(Doy.SprEn-Doy.St+1))
              lines(pldt$Doy[x.rows],pldt$Vlo[x.rows], col = fhcol)
              lines(pldt$Doy[x.rows],pldt$Vhi[x.rows], col = fhcol)
              polygon(c(pldt$Doy[x.rows], rev(pldt$Doy[x.rows])), c(pldt$Vhi[x.rows], rev(pldt$Vlo[x.rows])),
                      col = fhcol, border = NA)
              #Autumn
              Doy.AutSt <- HdSpSum.Accum[(ii-1)*NTInt+ifish-1,cstart+15]
              x.rows <- c((Doy.AutSt-Doy.St+1):(Doy.En-Doy.St+1))
              lines(pldt$Doy[x.rows],pldt$Vlo[x.rows], col = fhcol)
              lines(pldt$Doy[x.rows],pldt$Vhi[x.rows], col = fhcol)
              polygon(c(pldt$Doy[x.rows], rev(pldt$Doy[x.rows])), c(pldt$Vhi[x.rows], rev(pldt$Vlo[x.rows])),
                      col = fhcol, border = NA)
            }
          }
          if (ifish > 1 && ifish < NTmpI)
          {
            #text(50,(ifish-1)*100-7.5,substr(Vtype[ifish],3,8),adj=0,col=fhcol,cex=0.7)
            text(20,(ifish-2)*100+15,substr(Vtype[ifish],3,8),adj=0,col="black",cex=0.7)
          }
          xx <- c(0,365)
          yy <- rep((ifish-2)*100,2)
          lines(xx,yy,col="grey50",lwd=1,lty="dotted")
        }
        
        lines(xx,c(600,600),col="grey50",lwd=1,lty="dotted")
        lines(c(JM,JM),c(0,600),col="grey50",lwd=1,lty="dotted")
        text(JM,615,label="JM",col="grey50",adj=0.5,cex=0.7)
        lines(c(JS4,JS4),c(0,600),col="darkblue",lwd=2)
        lines(c(JE4,JE4),c(0,600),col="darkblue",lwd=2)
        text(JS4-7,615,label="4C",col="darkblue",adj=0,cex=0.7)
        text(JE4-7,615,label="4C",col="darkblue",adj=0,cex=0.7)
        lines(c(IBU,IBU),c(0,600),col="darkgreen",lwd=2)
        lines(c(IFU,IFU),c(0,600),col="darkgreen",lwd=2)
        text(IBU-7,-15,label="BU",col="darkgreen",adj=0,cex=0.7)
        text(IFU-7,-15,label="FU",col="darkgreen",adj=0,cex=0.7)
        text(186.5,640,label=figure_label,col="black",adj=0.5,cex=0.9)
        
        box()
        par <- opar
        dev.off()
      }
      # End: If Do_ThermoPic
    }
    # End: If Do_Space
    setTxtProgressBar(lake_progress_bar, i)
  }
  # End: Lake loop
  
  #============================================================================
  # Prepare for creating CSV outputs
  #----------------------------------------------------------------------------
  rownames(HdSpSum.Accum) <- c(1:(nrow(HdSpSum.Accum)))
  
  # ADD Annual Yield Index Values as %Year*%Spacemean
  HdSpSum.Accum$YVol <- round(HdSpSum.Accum$WinV*HdSpSum.Accum$Vmean,digits=2)
  HdSpSum.Accum$YArea <- round(HdSpSum.Accum$WinV*HdSpSum.Accum$Amean,digits=2)
  
  #Rename Thermal Habitat Variables
  habnew <- data.frame(PD_year=c(0),PD_icefree=NA,TSeasons=c(0),Jstart_Spr=NA,Jend_Spr=NA,Jstart_Aut=NA,Jend_Aut=NA,PV_JM=c(0),PV_mean=c(0),PV_sd=NA,PV_min=NA,PV_max=NA,PV_year=c(0),PA_JM=c(0),PA_mean=c(0),PA_sd=NA,PA_min=NA,PA_max=NA,PA_year=c(0))
  habitat <- data.frame(HdSpSum.Accum[,c(1:9)],habnew)
  habitat$PD_year <- HdSpSum.Accum$WinV
  habitat$PD_icefree <- HdSpSum.Accum$PSpr
  habitat$TSeasons <- HdSpSum.Accum$Seas
  habitat$Jstart_Spr <- HdSpSum.Accum$WinSt
  habitat$Jend_Spr <- HdSpSum.Accum$SprEn
  habitat$Jstart_Aut <- HdSpSum.Accum$AutSt
  habitat$Jend_Aut <- HdSpSum.Accum$WinEn
  habitat$PV_JM <- HdSpSum.Accum$VJM
  habitat$PV_mean <- HdSpSum.Accum$Vmean
  habitat$PV_sd <- HdSpSum.Accum$Vsd
  habitat$PV_min <- HdSpSum.Accum$Vmin
  habitat$PV_max <- HdSpSum.Accum$Vmax
  habitat$PV_year<- HdSpSum.Accum$YVol
  habitat$PA_JM <- HdSpSum.Accum$AJM
  habitat$PA_mean <- HdSpSum.Accum$Amean
  habitat$PA_sd <- HdSpSum.Accum$Asd
  habitat$PA_min <- HdSpSum.Accum$Amin
  habitat$PA_max <- HdSpSum.Accum$Amax
  habitat$PA_year<- HdSpSum.Accum$YArea
  # head(habitat)
  
  # Clean up output
  #spaced$DOC <- round(spaced$DOC,digits=1)
  
  return(habitat)
  # write.csv(habitat, file = file_out5, row.names = FALSE)
}
