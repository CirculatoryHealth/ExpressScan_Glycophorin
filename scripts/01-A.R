# Shortening dataframe names 
imagedata <- X20211126.GLYCC.AE.TIF.ImageExp
rm(X20211126.GLYCC.AE.TIF.ImageExp)
imagedata_add1 <- X20211126.GLYCC.AE.NDPI.ImageExp
rm(X20211126.GLYCC.AE.NDPI.ImageExp)
imagedata_add2 <- X20211129.GLYCC.AE.NDPI_with20x_error.ImageExp
rm(X20211129.GLYCC.AE.NDPI_with20x_error.ImageExp)

mfNDPI <- manualfixNDPI.Sheet1 
rm(manualfixNDPI.Sheet1)
mfNDPI20x <- manualfixNDPI20xerror.Sheet1
rm(manualfixNDPI20xerror.Sheet1)
mfTIFF <- manualfixTIFF.Sheet1
rm(manualfixTIFF.Sheet1)

# Pre-processing Glycophorin data
SCANNERTYPE1="Roche Ventana iScan HT"
SCANNERTYPE2="Hamamatsu C12000-22"

RAWDATA_FILENAME="X20211126.GLYCC.AE.TIF.ImageExp.csv.gz"
ADDRAWDATA_FILENAME="X20211126.GLYCC.AE.NDPI.ImageExp.csv.gz"
ADDRAWDATA2_FILENAME="X20211129.GLYCC.AE.NDPI_with20x_error.ImageExp.csv.gz"

# Pixels per unit
# These numbers were taken from the TIF and NDPI files:
# - Roche: 0.040157500654459
# - Hamamatsu: (76/10000) 
# However, as per email (2020-07-20) from Nikolas Stathonikos, the correct numbers should be:
# - Roche: ±0.25 micron (um) per pixel @40x
# - Hamamatsu: ±0.23 micron (um) per pixel @40x

# To quote: 
# "Roche has a scan resolution of ~0.25 um per pixel @ 40x and the Hamamatsu ~0.23 um per pixel @ 40x. 
# At 20x, the scan resolution doubles so for Roche it's ~0.5 um per pixel.
# So a cell that's 10um x 10um, would be 40 x 40 pixels @ 40x and at 20x 20 pixels @ 20x on Roche."
UNITPIXEL_VENTANA=0.25 # Roche, ~0.25 um per pixel @ 40x
UNITPIXEL_HAMAMATSU=0.23 # Hamamatsu, ~0.23 um per pixel @ 40x

# Convert the plaque size variables from pixels by pixels to microm^2 using the following correction factor:
CORRECTIONFACTOR_V = (UNITPIXEL_VENTANA/(20/40))^2 # TIFF files
CORRECTIONFACTOR_H = (UNITPIXEL_HAMAMATSU/(20/40))^2 # NDPI files

## Convert pixels to micrometer^2
# Imagedata (TIFF files)
imagedata$AreaOccupied_AreaOccupied_DAB_object_corr <- imagedata$AreaOccupied_AreaOccupied_DAB_object*CORRECTIONFACTOR_V
imagedata$AreaOccupied_AreaOccupied_Tissue_object_corr <- imagedata$AreaOccupied_AreaOccupied_Tissue_object*CORRECTIONFACTOR_V
imagedata$AreaOccupied_Perimeter_DAB_object_corr <- imagedata$AreaOccupied_Perimeter_DAB_object*CORRECTIONFACTOR_V
imagedata$AreaOccupied_Perimeter_Tissue_object_corr <- imagedata$AreaOccupied_Perimeter_Tissue_object*CORRECTIONFACTOR_V

# Imagedata_add (NDPI files)
imagedata_add1$AreaOccupied_AreaOccupied_DAB_object_corr <- imagedata_add1$AreaOccupied_AreaOccupied_DAB_object*CORRECTIONFACTOR_H
imagedata_add1$AreaOccupied_AreaOccupied_Tissue_object_corr <- imagedata_add1$AreaOccupied_AreaOccupied_Tissue_object*CORRECTIONFACTOR_H
imagedata_add1$AreaOccupied_Perimeter_DAB_object_corr <- imagedata_add1$AreaOccupied_Perimeter_DAB_object*CORRECTIONFACTOR_H
imagedata_add1$AreaOccupied_Perimeter_Tissue_object_corr <- imagedata_add1$AreaOccupied_Perimeter_Tissue_object*CORRECTIONFACTOR_H

# Imagedata_add (NDPI files)
imagedata_add2$AreaOccupied_AreaOccupied_DAB_object_corr <- imagedata_add2$AreaOccupied_AreaOccupied_DAB_object*CORRECTIONFACTOR_H
imagedata_add2$AreaOccupied_AreaOccupied_Tissue_object_corr <- imagedata_add2$AreaOccupied_AreaOccupied_Tissue_object*CORRECTIONFACTOR_H
imagedata_add2$AreaOccupied_Perimeter_DAB_object_corr <- imagedata_add2$AreaOccupied_Perimeter_DAB_object*CORRECTIONFACTOR_H
imagedata_add2$AreaOccupied_Perimeter_Tissue_object_corr <- imagedata_add2$AreaOccupied_Perimeter_Tissue_object*CORRECTIONFACTOR_H

imagedata$Metadata_NR <- sub("\\..*", "", imagedata$FileName_Original)
imagedata_add1$Metadata_NR <- sub("\\..*", "", imagedata_add1$FileName_Original)
imagedata_add2$Metadata_NR <- sub("\\..*", "", imagedata_add2$FileName_Original)

l = list(imagedata, imagedata_add1,imagedata_add2)
setattr(l, 'names', c("TIFF", "NDPI","NDPI"))
imagedata <- rbindlist(l, fill = TRUE, idcol = "ImageType")
imagedata$FileName_Original <- gsub(".normalized.tile.tissue.png","",imagedata$FileName_Original)
#rm(imagedata_add1, imagedata_add2,l)

## GLYCOPHORIN MANUAL CHECKED DATASET (FIXED TILES)
# NDPI
mfNDPI$FileName_Original <- mfNDPI$Tile
imagedata_NDPI <- merge(imagedata, mfNDPI[,c("FileName_Original","ManualKeep","Checked")], by="FileName_Original")
imagedata_NDPI$ManualKeep <- to_factor(imagedata_NDPI$ManualKeep)
imagedata_NDPI <- as.data.frame(subset(imagedata_NDPI, ManualKeep == "1", drop=TRUE))

# NDPI 20xerror
mfNDPI20x$FileName_Original <- mfNDPI20x$Tile
imagedata_NDPI20xerror <- merge(imagedata, mfNDPI20x[,c("FileName_Original","ManualKeep","Checked")], by="FileName_Original")
imagedata_NDPI20xerror$ManualKeep <- to_factor(imagedata_NDPI20xerror$ManualKeep)
imagedata_NDPI20xerror <- as.data.frame(subset(imagedata_NDPI20xerror, ManualKeep == "1", drop=TRUE))

# TIFF
mfTIFF$FileName_Original <- mfTIFF$Tile
imagedata_TIFF <- merge(imagedata, mfTIFF[,c("FileName_Original","ManualKeep","Checked")], by="FileName_Original")
imagedata_TIFF$ManualKeep <- to_factor(imagedata_TIFF$ManualKeep)
imagedata_TIFF <- as.data.frame(subset(imagedata_TIFF, ManualKeep == "1", drop=TRUE))

# Combining into one dataframe
f = list(imagedata_NDPI, imagedata_NDPI20xerror, imagedata_TIFF)
setattr(f, 'names', c("NDPI", "NDPI","TIFF"))
imagedata_mf <-rbindlist(f, fill=TRUE, idcol = "ImageType")
summary(factor(imagedata_mf$ImageType))
#rm(mfNDPI, imagedata_NDPI, mfNDPI20x, imagedata_NDPI20xerror, mfTIFF, imagedata_TIFF,f)

# Aggregate plaque size and stain surface
totalplaquesize = setNames(aggregate((imagedata_mf$AreaOccupied_AreaOccupied_Tissue_object_corr), 
                                     by = list(imagedata_mf$Metadata_NR), FUN = sum), c("STUDY_NUMBER", "TotalTissue"))
STAINtissuesize = setNames(aggregate((imagedata$AreaOccupied_AreaOccupied_DAB_object_corr), 
                                     by = list(imagedata$Metadata_NR),FUN = sum), c("STUDY_NUMBER", "TotalSTAINTissue"))
# Merge plaque size (TotalTissue) and total glycophorin stain (TotalSTAINTissue) in one data.table
Glycophorin_manual = data.table(merge(STAINtissuesize, totalplaquesize))

# Add ImageType to data.table
d <- unique(subset(imagedata_mf, select = c("Metadata_NR", "ImageType")))
Glycophorin_manual <- merge(Glycophorin_manual, d, by.x = "STUDY_NUMBER", by.y = "Metadata_NR")

# Create a ratio and percentage
Glycophorin_manual$RatioSTAIN = (Glycophorin_manual$TotalSTAINTissue / Glycophorin_manual$TotalTissue)
Glycophorin_manual$PercentageSTAIN = ((Glycophorin_manual$TotalSTAINTissue / Glycophorin_manual$TotalTissue)*100)

# Remove 'AE' from STUDY_NUMBER variable
Glycophorin_manual$STUDY_NUMBER <- gsub("AE*", "", Glycophorin_manual$STUDY_NUMBER, perl = TRUE)

# Remove unused data
rm(d, totalplaquesize, STAINtissuesize,imagedata_mf)

#fwrite(Glycophorin_manual, file = "~/surfdrive/2. Projecten/2. Glycophorin manuscript/_Manuscript Glycophorin revised/Glycophorin_manual.data.txt.gz",quote = FALSE, sep = " ", na = "-999", row.names = FALSE, col.names = TRUE,showProgress = TRUE, verbose = TRUE)

# GLYCOPHORIN MAIN DATASET
# Aggregate plaque size and stain surface
totalplaquesize = setNames(aggregate((imagedata$AreaOccupied_AreaOccupied_Tissue_object_corr), 
                                     by = list(imagedata$Metadata_NR), FUN = sum), c("STUDY_NUMBER", "TotalTissue"))
STAINtissuesize = setNames(aggregate((imagedata$AreaOccupied_AreaOccupied_DAB_object_corr), 
                                     by = list(imagedata$Metadata_NR),FUN = sum), c("STUDY_NUMBER", "TotalSTAINTissue"))
# Merge plaque size (TotalTissue) and total glycophorin stain (TotalSTAINTissue) in one data.table
Glycophorin2021 = data.table(merge(STAINtissuesize, totalplaquesize))

# Add ImageType to data.table
d <- unique(subset(imagedata, select = c("Metadata_NR", "ImageType")))
Glycophorin2021 <- merge(Glycophorin2021, d, by.x = "STUDY_NUMBER", by.y = "Metadata_NR")

# Create a ratio and percentage
Glycophorin2021$RatioSTAIN = (Glycophorin2021$TotalSTAINTissue / Glycophorin2021$TotalTissue)
Glycophorin2021$PercentageSTAIN = ((Glycophorin2021$TotalSTAINTissue / Glycophorin2021$TotalTissue)*100)

# Remove 'AE' from STUDY_NUMBER variable
Glycophorin2021$STUDY_NUMBER <- gsub("AE*", "", Glycophorin2021$STUDY_NUMBER, perl = TRUE)

# Remove unused data
rm(d, totalplaquesize, STAINtissuesize,imagedata)

#fwrite(Glycophorin2021, file = "~/surfdrive/2. Projecten/2. Glycophorin manuscript/_Manuscript Glycophorin revised/Glycophorin2021.data.txt.gz", quote = FALSE, sep = " ", na = "-999", row.names = FALSE, col.names = TRUE, showProgress = TRUE, verbose = TRUE)

## Manual check
fix <- fix.Sheet1
rm(fix.Sheet1)
multiplaque <- multiplaque.Sheet1
rm(multiplaque.Sheet1)
remove <- remove.Sheet1
rm(remove.Sheet1)

fix$WSI_Filename_TIFF <- gsub("tilecrossed_AE", "", fix$WSI_Filename_TIFF)
fix$WSI_Filename_TIFF <- gsub("\\..*$","", fix$WSI_Filename_TIFF)
names(fix)[names(fix) == 'WSI_Filename_TIFF'] <- 'STUDY_NUMBER'

remove$WSI_Filename_TIFF <- gsub("tilecrossed_AE", "", remove$WSI_Filename_TIFF)
remove$WSI_Filename_TIFF <- gsub("\\..*$","", remove$WSI_Filename_TIFF)
names(remove)[names(remove) == 'WSI_Filename_TIFF'] <- 'STUDY_NUMBER'

multiplaque$WSI_Filename_TIFF <- gsub("tilecrossed_AE", "", multiplaque$WSI_Filename_TIFF)
multiplaque$WSI_Filename_TIFF <- gsub("\\..*$","", multiplaque$WSI_Filename_TIFF)
names(multiplaque)[names(multiplaque) == 'WSI_Filename_TIFF'] <- 'STUDY_NUMBER'

# Merging for final Glycophorin dataset
Glycophorin2021 <- anti_join(Glycophorin2021,fix, by ="STUDY_NUMBER") #2630 -415 = 2215
Glycophorin2021 <- anti_join(Glycophorin2021,remove, by ="STUDY_NUMBER") #2215 -51 = 2165

f = list(Glycophorin2021, Glycophorin_manual)
GLYCC <-rbindlist(f) 

# Add multiplaque to data.table
GLYCC<- merge(GLYCC, multiplaque, by= "STUDY_NUMBER", all=TRUE)
GLYCC[is.na(GLYCC)] <- 0
summary(GLYCC)
#rm(f, Glycophorin_manual, Glycophorin2021, fix, remove,multiplaque)
fwrite(GLYCC, file = "~/surfdrive/2. Projecten/2. Glycophorin manuscript/_Manuscript Glycophorin revised/Glycophorin_2022.data.txt.gz",quote = FALSE, sep = " ", na = "-999", row.names = FALSE, col.names = TRUE,showProgress = TRUE, verbose = TRUE)
Clinicaldata <- AEDB_March_2022
rm(X2021.09.10.AtheroExpress.Database,AEDB_March_2022)


# Keeping the value labels of informed consent and Artery_summary is vital for the code below
Clinicaldata$informedconsent <- to_factor(Clinicaldata$informedconsent)
Clinicaldata$Artery_summary <- to_factor(Clinicaldata$Artery_summary)
summary(Clinicaldata$Artery_summary)

# Only selecting patients with a written informed consent.
Clinicaldata.IC <- subset(Clinicaldata,
                          (informedconsent != "missing" & # we are really strict in selecting based on 'informed consent'!
                             informedconsent != "no, died" &
                             informedconsent != "yes, no tissue, no commerical business" &
                             informedconsent != "yes, no tissue, no questionnaires, no medical info, no commercial business" &
                             informedconsent != "yes, no tissue, no questionnaires, no health treatment, no commerical business" &
                             informedconsent != "yes, no tissue, no questionnaires, no health treatment, no medical info, no commercial business" &
                             informedconsent != "yes, no tissue, no health treatment" &
                             informedconsent != "yes, no tissue, no questionnaires" &
                             informedconsent != "yes, no tissue, health treatment when possible" &
                             informedconsent != "yes, no tissue" &
                             informedconsent != "yes, no tissue, no questionnaires, no health treatment, no medical info" &
                             informedconsent != "yes, no tissue, no questionnaires, no health treatment, no commercial business" &
                             informedconsent != "no, doesn't want to" &
                             informedconsent != "no, unable to sign" &
                             informedconsent != "no, no reaction" &
                             informedconsent != "no, lost" &
                             informedconsent != "no, too old" &
                             informedconsent != "yes, no medical info, health treatment when possible" &
                             informedconsent != "no (never asked for IC because there was no tissue)" &
                             informedconsent != "no, endpoint" &
                             informedconsent != "nooit geincludeerd"))

# Only selecting patients that received a carotid endarterectomy
Clinicaldata.CEA <- subset(Clinicaldata.IC,(Artery_summary == "carotid (left & right)" | Artery_summary == "other carotid arteries (common, external)")) # Only select "carotid (left & right)" and "other carotid arteries (common, external)"

# NOTE: sometimes Artery_summary doesn't use the labels but only the value's, in that case use the code below. I did not identify the cause for this.
#Clinicaldata.CEA <- subset(Clinicaldata.IC,(Artery_summary == "1" | Artery_summary == "3")) # Only select "carotid (left & right)" and "other carotid arteries (common, external)"

## Merging the Clinicaldata frame with the Staining data
GLYCC$STUDY_NUMBER <- as.numeric(GLYCC$STUDY_NUMBER)
ExpressScan <- merge(GLYCC,Clinicaldata.CEA, by= "STUDY_NUMBER", all=FALSE)

#rm(Clinicaldata,Clinicaldata.IC,Clinicaldata.CEA,Glycophorin2021,remove,fix,multiplaque,GLYCC,GLYCC_complete,Glycophorin_manual,f)

# Preparation of ExpressScan - fixing/creating some variables
# Fix symptoms
attach(ExpressScan)
ExpressScan$sympt[is.na(ExpressScan$sympt)] <- -999
# Symptoms.5G
ExpressScan[,"Symptoms.5G"] <- NA
# ExpressScan$Symptoms.5G[sympt == "NA"] <- "Asymptomatic"
ExpressScan$Symptoms.5G[sympt == -999] <- NA
ExpressScan$Symptoms.5G[sympt == 0] <- "Asymptomatic"
ExpressScan$Symptoms.5G[sympt == 1 | sympt == 7 | sympt == 13] <- "TIA"
ExpressScan$Symptoms.5G[sympt == 2 | sympt == 3] <- "Stroke"
ExpressScan$Symptoms.5G[sympt == 4 | sympt == 14 | sympt == 15 ] <- "Ocular"
ExpressScan$Symptoms.5G[sympt == 8 | sympt == 11] <- "Retinal infarction"
ExpressScan$Symptoms.5G[sympt == 5 | sympt == 9 | sympt == 10 | sympt == 12 | sympt == 16 | sympt == 17] <- "Other"

# AsymptSympt
ExpressScan[,"AsymptSympt"] <- NA
ExpressScan$AsymptSympt[sympt == -999] <- NA
ExpressScan$AsymptSympt[sympt == 0] <- "Asymptomatic"
ExpressScan$AsymptSympt[sympt == 1 | sympt == 7 | sympt == 13 | sympt == 2 | sympt == 3] <- "Symptomatic"
ExpressScan$AsymptSympt[sympt == 4 | sympt == 14 | sympt == 15 | sympt == 8 | sympt == 11 | sympt == 5 | sympt == 9 | sympt == 10 | sympt == 12 | sympt == 16 | sympt == 17] <- "Ocular and others"

# AsymptSympt
ExpressScan[,"AsymptSympt2G"] <- NA
ExpressScan$AsymptSympt2G[sympt == -999] <- NA
ExpressScan$AsymptSympt2G[sympt == "Asymptomatic"] <- "Asymptomatic"
ExpressScan$AsymptSympt2G[sympt == "TIA" | sympt == "Vertebrobasilary TIA" | sympt == "minor stroke" | sympt == "Major stroke" | sympt == "Amaurosis fugax" | sympt == "Ocular ischemic syndrome" | sympt == "Retinal infarction" | sympt == "retinal infarction" | sympt == "Four vessel disease" | sympt == "Symptomatic, but aspecific symtoms" | sympt == "Contralateral symptomatic occlusion" | sympt == "subclavian steal syndrome"] <- "Symptomatic"
ExpressScan$AsymptSympt2G <- to_factor(ExpressScan$AsymptSympt2G)
detach(ExpressScan)
#table(ExpressScan$DM.composite)
#table(ExpressScan$DiabetesStatus)

#ExpressScan.temp <- subset(ExpressScan,  select = c("STUDY_NUMBER", "UPID", "Age", "Gender", "Hospital", "Artery_summary", "DM.composite", "DiabetesStatus"))
#require(labelled)
#ExpressScan.temp$Gender <- to_factor(ExpressScan.temp$Gender)
#ExpressScan.temp$Hospital <- to_factor(ExpressScan.temp$Hospital)
#ExpressScan.temp$Artery_summary <- to_factor(ExpressScan.temp$Artery_summary)
#ExpressScan.temp$DiabetesStatus <- to_factor(ExpressScan.temp$DiabetesStatus) 
#DT::datatable(ExpressScan.temp[1:10,], caption = "Excerpt of the whole ExpressScan.", rownames = FALSE)
# rm(ExpressScan.temp)

require(labelled)
ExpressScan$diet801 <- to_factor(ExpressScan$diet801)
ExpressScan$diet802 <- to_factor(ExpressScan$diet802)
ExpressScan$diet805 <- to_factor(ExpressScan$diet805)
ExpressScan$SmokingReported <- to_factor(ExpressScan$SmokingReported)
ExpressScan$SmokerCurrent <- to_factor(ExpressScan$SmokerCurrent)
ExpressScan$SmokingYearOR <- to_factor(ExpressScan$SmokingYearOR)

attach(ExpressScan)
ExpressScan[,"SmokerStatus"] <- NA
ExpressScan$SmokerStatus[diet802 == "don't know"] <- "Never smoked"
ExpressScan$SmokerStatus[diet802 == "I still smoke"] <- "Current smoker"
ExpressScan$SmokerStatus[SmokerCurrent == "no" & diet802 == "no"] <- "Never smoked"
ExpressScan$SmokerStatus[SmokerCurrent == "no" & diet802 == "yes"] <- "Ex-smoker"
ExpressScan$SmokerStatus[SmokerCurrent == "yes"] <- "Current smoker"
ExpressScan$SmokerStatus[SmokerCurrent == "no data available/missing"] <- NA
# ExpressScan$SmokerStatus[is.na(SmokerCurrent)] <- "Never smoked"
detach(ExpressScan)

#cat("\n* Current smoking status.\n")
#table(ExpressScan$SmokerCurrent,
#      useNA = "ifany", 
#      dnn = c("Current smoker"))

#cat("\n* Updated smoking status.\n")
#table(ExpressScan$SmokerStatus,
#      useNA = "ifany", 
#      dnn = c("Updated smoking status"))

#cat("\n* Comparing to 'SmokerCurrent'.\n")
#table(ExpressScan$SmokerStatus, ExpressScan$SmokerCurrent, 
#      useNA = "ifany", 
#      dnn = c("Updated smoking status", "Current smoker"))

# Fix Artery_summary (2 groups)
ExpressScan$Artery_summary <- to_factor(ExpressScan$Artery_summary)
attach(ExpressScan)
ExpressScan[,"ArteryOperated"] <- NA
ExpressScan$ArteryOperated [Artery_summary == "carotid (left & right)"] <- "Carotid"
ExpressScan$ArteryOperated [Artery_summary == 'femoral/iliac (left, right or both sides)'] <- 'Femoral/iliac'
detach(ExpressScan)

# Fix diabetes
attach(ExpressScan)
ExpressScan[,"DiabetesStatus"] <- NA
ExpressScan$DiabetesStatus[DM.composite == -999] <- NA
ExpressScan$DiabetesStatus[DM.composite == "no"] <- "Control (no Diabetes Dx/Med)"
ExpressScan$DiabetesStatus[DM.composite == "yes"] <- "Diabetes"
detach(ExpressScan)

# Inverse-rank transformation of Glycophorin Staining and Plaque size of Glycophorin plaque's
ExpressScan$Total_GLYCC_Tissue_rank <- qnorm((rank(ExpressScan$TotalSTAINTissue, na.last = "keep") - 0.5)/sum(!is.na(ExpressScan$TotalSTAINTissue)))
ExpressScan$TotalTissue_rank <- qnorm((rank(ExpressScan$TotalTissue, na.last = "keep") - 0.5) / sum(!is.na(ExpressScan$TotalTissue)))

# Changing the name of one of the Hypertension variables
names(ExpressScan)[names(ExpressScan) == "Hypertension1"] <- "Hypertension.selfreport"

# Changing the class of variables to numeric and factors
numeric <- c("Age", "diastoli", "systolic", "GFR_MDRD", "BMI","TC_final", "LDL_final", "HDL_final", "TG_final")
categorical <- c("Gender", "Hospital", "DiabetesStatus", "SmokerStatus", "Hypertension.selfreport", "risk614","Med.Statin.LLD", "Hypertension.drugs","Med.all.antiplatelet", "Med.anticoagulants", "CAD_history", "PAOD", "Peripheral.interv", "StrokeTIA_history", "Stenosis_ipsilateral", "stenosis_con_bin","Symptoms.4g","restenos","ArteryOperated","SmokerCurrent","AsymptSympt2G")

ExpressScan <-as.data.frame(ExpressScan)
ExpressScan[,categorical] <- lapply(ExpressScan[categorical], as.factor)
# ExpressScan[,numeric] <- lapply(ExpressScan[,numeric], as.numeric) # For some reason this is not working correctly (https://stackoverflow.com/questions/6917518/r-as-numeric-function-not-returning-correct-from-data-frame)
# Use the following instead
ExpressScan$Age <- as.numeric(as.character(ExpressScan$Age))
ExpressScan$systolic <- as.numeric(as.character(ExpressScan$systolic))
ExpressScan$diastoli <- as.numeric(as.character(ExpressScan$diastoli))
ExpressScan$BMI <- as.numeric(as.character(ExpressScan$BMI))
ExpressScan$GFR_MDRD <- as.numeric(as.character(ExpressScan$GFR_MDRD))
ExpressScan$TC_final <- as.numeric(as.character(ExpressScan$TC_final))
ExpressScan$LDL_final <- as.numeric(as.character(ExpressScan$LDL_final))
ExpressScan$HDL_final <- as.numeric(as.character(ExpressScan$HDL_final))
ExpressScan$TG_final <- as.numeric(as.character(ExpressScan$TG_final))

## Transform variables for MICE
ExpressScan$TC_final_LN <- log(ExpressScan$TC_final)
ExpressScan$LDL_final_LN <- log(ExpressScan$LDL_final)
ExpressScan$HDL_final_LN <- log(ExpressScan$HDL_final)
ExpressScan$TG_final_LN <- log(ExpressScan$TG_final)
ExpressScan$BMI_LN <- log(ExpressScan$BMI)

# Creating a new 30d and 90 MACE time-variable and event variable
cutt.off.30days = (1/365.25) * 30
cutt.off.90days = (1/365.25) * 90

# Fix maximum FU of 30 and 90 days
ExpressScan <- ExpressScan %>%
  mutate(
    FU.cutt.off.30days = ifelse(max.followup <= cutt.off.30days, max.followup, cutt.off.30days)) 

ExpressScan <- ExpressScan %>%
  mutate(
    FU.cutt.off.90days = ifelse(max.followup <= cutt.off.90days, max.followup, cutt.off.90days)) 

avg_days_in_year = 365.25
cutt.off.30days.scaled <- cutt.off.30days * 365.25
cutt.off.90days.scaled <- cutt.off.90days * 365.25

# Event times
ExpressScan <- ExpressScan %>%
  mutate(
    ep_major_t_30days = ifelse(ep_major_t_3years * avg_days_in_year <= cutt.off.30days.scaled, 
                               ep_major_t_3years * avg_days_in_year, cutt.off.30days.scaled)) 
ExpressScan <- ExpressScan %>%
  mutate(
    ep_major_t_90days = ifelse(ep_major_t_3years * avg_days_in_year <= cutt.off.90days.scaled, 
                               ep_major_t_3years * avg_days_in_year, cutt.off.90days.scaled)) 

attach(ExpressScan)
ExpressScan[,"epmajor.30days"] <- NA
ExpressScan$epmajor.30days[epmajor.3years == "Included" & ep_major_t_3years > cutt.off.30days] <- 0
ExpressScan$epmajor.30days[epmajor.3years == "Excluded" & ep_major_t_3years < cutt.off.30days] <- 1

ExpressScan[,"epmajor.90days"] <- NA
ExpressScan$epmajor.90days[epmajor.3years == "Included" & ep_major_t_3years > cutt.off.90days] <- 0
ExpressScan$epmajor.90days[epmajor.3years == "Excluded" & ep_major_t_3years < cutt.off.90days] <- 1
detach(ExpressScan)

