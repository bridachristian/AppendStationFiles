rm(list = ls())

library(rJava)
library(rChoiceDialogs)
library(svDialogs)
library(properties)
library(rstudioapi)

# set working dir in the script path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(dirname(current_path)))

setting_dir = paste(getwd(),"/Setting/file_config_append/",sep = "")    # <- You can set another one
if(!dir.exists(setting_dir)){
  dir.create(setting_dir)
}

# ----------------------------------------------------------------------------------------------------------
#                                               SETTINGS  
# ----------------------------------------------------------------------------------------------------------


# input_dir <- jchoose.dir(default = getwd(),caption = "Select input directory:") 
# input_dir <- gsub("\\\\","/",input_dir)
# input_dir <- paste(input_dir,"/",sep = "")
# output_dir <- jchoose.dir(default = getwd(),caption = "Select output directory:") 
# output_dir <- gsub("\\\\","/",output_dir)
# output_dir <- paste(output_dir,"/",sep = "")

file_extension <-jselect.list(choices = c(".dat",".csv", ".txt"), preselect = ".dat", title = "Select the file extension admitted:")
sep <-jselect.list(choices = c(",",";"),preselect = ",",title = "Select the input separator:")

datetime_header <- dlgInput("Enter the datetime column name:")$res
record_header <- dlgInput("Enter the record column name:")$res

datetime_format <- jselect.list(choices = c("%Y-%m-%d %H:%M:%S","%Y-%m-%d %H:%M"),preselect = "%Y-%m-%d %H:%M:%S",title = "Select the datetime format:")
datetime_sampling <-jselect.list(choices = c("15 min","1 hour"),preselect = "15 min",title = "Select the datetime sampling:")

data_from_row <- as.numeric(dlgInput("Enter the first row of data:")$res)
header_row_number <- as.numeric(dlgInput("Enter the row of data labels:")$res)

first_row_to_check <- as.numeric(dlgInput("Enter the first row to check (header):")$res)
last_row_to_check <- as.numeric(dlgInput("Enter the last row to check (header):")$res)

quote_header <-jselect.list(choices = c("TRUE","FALSE"),title = "Do you want to quote the output header?")

file_config_dir <- jchoose.dir(default = setting_dir,caption = "Select where to save file_config:") 
file_config_dir <- gsub("\\\\","/",file_config_dir)
file_config_dir <- paste(file_config_dir,"/",sep = "")
file_config_name <- dlgInput("Enter the file name of file_config:")$res

settings = list(file_extension,
                sep,
                datetime_header, 
                record_header,
                datetime_format,
                datetime_sampling,
                data_from_row,
                header_row_number,
                first_row_to_check,
                last_row_to_check,
                quote_header)

names(settings) = c("file_extension",
                    "sep",
                    "datetime_header",
                    "record_header",
                    "datetime_format",
                    "datetime_sampling",
                    "data_from_row",
                    "header_row_number",
                    "first_row_to_check",
                    "last_row_to_check",
                    "quote_header")



write.properties(file = paste(file_config_dir,file_config_name,".properties",sep = ""),
                 properties = settings)
# save(input_dir,
#      output_dir,
#      file_extension,
#      datetime_format,
#      datetime_header,
#      record_header,
#      datetime_sampling,
#      sep,
#      data_from_row,
#      header_row_number,
#      first_row_to_check,
#      quote_header,
#      last_row_to_check, file = dlgSave(title = "Save file config as:",)$re)
#  

print(" --- DONE ---")
rm(list = ls())
# load(jchoose.files(default = getwd()))

