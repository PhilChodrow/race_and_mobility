library(data.table)

setwd("~/projects/spatial_complexity/applications/time_dependence")
data_dir <- 'data/time_geo/'
col_names <- c('id', 'time', 'tract', 'h_tract', 'type')
col_class <- c('integer', 'integer', 'character', 'character', 'character')

data <- data.table('time' = integer(),
				   'tract' = character(),
				   'h_tract' = character(),
				   'N' = integer())

for(file in list.files(data_dir)){
	chunk <- fread(paste0(data_dir, file), 
				  colClasses = col_class,
				  col.names = col_names,
				  verbose = F)
	agged <- chunk[,.N,by = list(tract, h_tract, time)] 
	data <- rbind(data, agged)
}

write.csv(data, 'throughput/tract_sources.csv')
tables()





# tab <- data %>% tbl_df() %>%
# 	group_by(tract, h_tract, time) %>% 
# 	summarise(n = n())



