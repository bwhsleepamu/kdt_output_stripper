# labtime.R

origin_by_year <- function(y) {
  as.POSIXct(paste("01.01", as.character(y), sep='.'), tz="America/New_York", format="%d.%m.%Y")
  
}

as.labtime <- function(x, ...) {
  UseMethod("as.labtime", x)
}

as.labtime.pasciDateTime <- function(x, ...) {
  
  cd <- as.POSIXct(as.character(x), tz="America/New_York", format='%d.%m.%y %H:%M:%S')
  od <- origin_by_year(year(cd))
  
  tdiff <- as.numeric(difftime(cd, od, units=c("hours")))
  tdiff <- structure(tdiff, class="labtime")
  
  tdiff
}

print.labtime <- function(x) {
  h <- floor(x)
  r <- (x - h)*60
  m <- floor(r)
  r <- (r - m)*60
  s <- round(r)
  
  print(paste(h,str_pad(m,2,pad='0'),str_pad(s,2,pad='0'), sep=':'))
}

as.realtime <- function(x, ...) {
  UseMethod("as.realtime", x)
}

as.realtime.labtime <- function(x, year=2016, ...) {
  as.POSIXct(as.numeric(x)*60*60, origin=origin_by_year(year))
  
}

as.pasciDateTime <- function(d, t) {
  structure(paste(d,t, sep=' '), class = "pasciDateTime")
} 

format_labtime <- function(x) {
  x_labtime <- structure(x, class="labtime")
  print.labtime(x_labtime)
}
