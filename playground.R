tds <- read.csv("C:/Users/pwm4/Downloads/example_ps2_full.csv")
tds <- as.data.table(tds)
nrow(tds)


t <- master_sheet()[Subject=="3227GX",.N,by='VPD.Filename']
t[,CS:=cumsum(N)]
t[,groups:=CS %/% 250]
