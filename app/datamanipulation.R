current_dir = getwd()
if (substring(current_dir, nchar(current_dir) - 3) != "data") {
  setwd("data")
}
dis = read.csv("DisasterDeclarationsSummaries.csv")
mis = read.csv("MissionAssignments.csv")
raw_zip = readLines("US.txt")
fields = strsplit(raw_zip, "\t") 
zip = as.data.frame(do.call(rbind, fields), stringsAsFactors = FALSE)
zip = zip[c("V2", "V5", "V10", "V11")]
names(zip) <- c("zip", "state", "lat", "long")
mis = merge(mis, zip, by = "zip")

