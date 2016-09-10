library(data.table)
library(dplyr)
library(tidyr)

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

# OK, now time to combine with the demographics

col_class <- c('integer', 'integer', 'integer', 'integer', 'integer', 'character', 'integer')
demo <- read.csv('throughput/tract_demos.csv', colClasses = col_class) %>% tbl_df

# Normalize

demo <- demo %>% select(-total) %>% 
	gather(key = race, value = n, -GEOID) %>% 
	group_by(GEOID) %>% 
	mutate(n = n / sum(n)) %>% 
	spread(key = race, value = n)

demo <- data.table(demo)

setkeyv(data, 'h_tract')
setkeyv(demo, 'GEOID')

joined <- data[demo]

tab <- joined[, j = list(
			  Asian    = sum(Asian * N, na.rm = T),
			  Black    = sum(Black * N, na.rm = T),
			  Hispanic = sum(Hispanic * N, na.rm = T),
			  Other    = sum(Other * N, na.rm = T),
			  White    = sum(White * N, na.rm = T)
			  ), by    = list(tract, time)]

write.csv(tab, 'throughput/space_time_profiles.csv')