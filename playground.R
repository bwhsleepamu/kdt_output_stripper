# 
# ms <- as.data.table(read.xls("~/Desktop/kdt_stripper/32d-CSR_Database_2015.12.30-ebk.xls", skip=8, sheet=2, header=TRUE))
# ms$VPD.Filename
# 
# 
# d <- "/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3"
# 
# ?list.files
# 
# list.files(d, pattern="SP37|WP38")
# l <- character()
# for(f in ms[Subject=="3227GX"]$VPD.Filename) {
#   l <- c(l, list.files(d, pattern=f))
# }
# 
# l
# 
# fl <- list.files(d, full.names = TRUE)
# fl
# grep("SP37", fl, value=TRUE)
# ?grep
# 
# 
# l <- character()
# for(f in ms[Subject=="3227GX"]$VPD.Filename) {
#   l <- c(l, grep(f, fl, value=TRUE))
# }
# 
# l
# 
# ps1e <- "/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3/3227gx_082912_w4s4w5_PID_3227GX_082912_W4S4W5_RID_0_Session3_2MAD_Ch_C3 Ax.PASCI"
# 
# rr <- as.data.table(read.delim(ps1e, sep='|', header=FALSE))
# rr[2,2,with=FALSE]
# 
# ahh <- "~/Downloads/T20-CSR_Subject Info.xls"
# read.xls(ahh, skip=2, nrows=19, header=FALSE)
# 
# 
# 
# ##
# t <- "15:22:04"
# d <- "28.08.12"
# dt <- paste(d,t,sep=" ")
# cd <- as.POSIXct(dt, tz="America/New_York", format='%d.%m.%y %H:%M:%S')
# od <- as.POSIXct(paste("01.01", as.character(year(cd)), sep='.'), tz="America/New_York", format="%d.%m.%Y")
# 
# tdiff <- as.numeric(difftime(cd, od, units=c("hours")))
# 
# 
# tdiff
# as.POSIXct(tdiff*60*60, origin=origin_by_year(2012))
# ##
# 
# 
# 
# 
# do <- "01.01.12"
# 
# od <- as.POSIXct(do, tz="America/New_York", format='%d.%m.%y')
# 
# cd
# od
# 
# as.numeric(difftime(cd, od, units=c("hours")))
# 
# names(cd)
# 
# ####
# 
# 
# p2 <- "/X/People/Research Staff/Beckett_Scott/32-CSR_KDT-FFT_2013.09.16/3227GX/PASCI/C3/3227gx_082812_w2s2w3_PID_3227GX_082812_W2S2W3_RID_0_Session4_2MAD_Ch_C3 Ax.PASCI"
# 
# read_fields <- scan(p2, what=character(), skip=1, nlines=3, sep='|')
# read_fields[2]
# read_fields[7]
# read_fields[12]
# 
# dt <- structure(paste(,substr(, 1, 8), sep=' '), class = "pasciDateTime")
# 
# 
# 
# 
# ###
# 
# 
# 
# 
# ps1 <- as.data.table(read.csv("~/Desktop/example_ps1.ps1", header=FALSE))
# colnames(ps1) <- c("file_path")
# msi <- list(type='application/vnd.ms-excel',datapath="~/Desktop/kdt_stripper/32d-CSR_Database_2015.12.30-ebk.xls")
# ms <- loadFile(msi, 8, TRUE, 2)
# 
# ps1[,file_path:=as.character(file_path)]
# 
# my_ms <- copy(ms[Subject=="3227GX"])
# pasci_file_info <- ps1[,readPasciInfo(file_path),by='file_path']
# ps2 <- data.table(subject_code=my_ms$Subject, vpd_pattern=my_ms$VPD.Filename, kdt_start_epoch=as.numeric(as.character(my_ms$KDT.Beginning.Epoch)), kdt_start_date=my_ms$Begin.Date, 
#                   kdt_start_time=my_ms$KDT.Begin.Time, kdt_end_epoch=as.numeric(as.character(my_ms$KDT.Ending.Epoch)), kdt_end_date=my_ms$End.Date, kdt_end_time=my_ms$KDT.End.Time)
# ps2 <- ps2[!is.na(kdt_start_epoch) & !is.na(kdt_end_epoch)]
# ps2[,c("pasci_path", "vpd_file_name", "vpd_start_date", "vpd_start_time"):=pasci_file_info[grep(vpd_pattern, vpd_file_name, ignore.case=TRUE), which=FALSE],by='subject_code,vpd_pattern,kdt_start_epoch']
# 
# 
# ps2[,pk:=.I]
# ps2[,pasci_file_dt:=as.pasciDateTime(vpd_start_date, vpd_start_time)]
# ps2[,pasci_file_labtime:=as.labtime(pasci_file_dt)]
# ps2[,kdt_start_labtime:=pasci_file_labtime+((kdt_start_epoch-1)/2/60)]
# ps2[,kdt_end_labtime:=pasci_file_labtime+((kdt_start_epoch-1)/2/60)]
# 
# ps2[,tau:=peri]
# ps2[,cbt_comp_min:=comp_min]
# ps2[,fd_start_labtime:=fd_start]
# ps2[,fd_end_labtime:=fd_end]
# 
# # Set comp_min to comp_min - (24*5)
# ps2[kdt_start_labtime < fd_start_labtime, `:=`(tau=24, cbt_comp_min=cbt_comp_min-(24*5))]
# 
# # Set comp_min to comp_min + 24*20
# ps2[kdt_start_labtime > fd_end_labtime, `:=`(tau=24, cbt_comp_min=cbt_comp_min+(24*20))]
# ps2_output <- ps2[,list(vpd_file_name, kdt_start_epoch, paste(kdt_start_date, substr(kdt_start_time,1,5)), kdt_start_labtime, kdt_end_epoch, paste(kdt_end_date, substr(kdt_end_time,1,5)), kdt_end_labtime, tau*60, cbt_comp_min)]
# 
# ps2
# 
# fd_start <- 5889.52
# fd_end <- 6369.52
# peri <- 24.351
# comp_min <- 5908.79
# 
# 
# 
# 
# 
# ps2[,ff:=format_labtime(kdt_end_labtime),by='pk']
# 
# format_labtime(ps2$kdt_end_labtime)
# 
# 
# d <- ps2$vpd_start_date[1]
# t <- ps2$vpd_start_time[1]
# 
# dt <- as.pasciDateTime(d,t)
# ll <- as.labtime(dt)
# 
# ll
# 
# 
# View(ps2)
# 
# ps2_t <- copy(ps2)
# 
# 
# 
# pasci_file_info[grep("W2S2W3", vpd_file_name, ignore.case=TRUE), which=FALSE]
# 
# 
# 
# grep("W2S2W3", pasci_file_info$vpd_file_name, ignore.case = TRUE)
# ?data.table
# 
# 
# 
# 
# 
# pasci_file_info
# 
# 
# 
# 
# 
# 
