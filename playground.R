library(gdata)

ms <- as.data.table(read.xls("~/Desktop/kdt_stripper/32d-CSR_Database_2015.12.30-ebk.xls", skip=8, sheet=2, header=TRUE))
ms$VPD.Filename


d <- "/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3"

?list.files

list.files(d, pattern="SP37|WP38")
l <- character()
for(f in ms[Subject=="3227GX"]$VPD.Filename) {
  l <- c(l, list.files(d, pattern=f))
}

l

fl <- list.files(d, full.names = TRUE)
fl
grep("SP37", fl, value=TRUE)
?grep


l <- character()
for(f in ms[Subject=="3227GX"]$VPD.Filename) {
  l <- c(l, grep(f, fl, value=TRUE))
}

l

ps1e <- "/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3/3227gx_082912_w4s4w5_PID_3227GX_082912_W4S4W5_RID_0_Session3_2MAD_Ch_C3 Ax.PASCI"

rr <- as.data.table(read.delim(ps1e, sep='|', header=FALSE))
rr[2,2,with=FALSE]

ahh <- "~/Downloads/T20-CSR_Subject Info.xls"
read.xls(ahh, skip=2, nrows=19, header=FALSE)



##
t <- "15:22:04"
d <- "28.08.12"
cd <- as.POSIXct(paste(d,t,sep=" "), tz="America/New_York", format='%d.%m.%y %H:%M:%S')
od <- as.POSIXct(paste("01.01", as.character(year(cd)), sep='.'), tz="America/New_York", format="%d.%m.%Y")

tdiff <- as.numeric(difftime(cd, od, units=c("hours")))




##




do <- "01.01.12"

od <- as.POSIXct(do, tz="America/New_York", format='%d.%m.%y')

cd
od

as.numeric(difftime(cd, od, units=c("hours")))

names(cd)


