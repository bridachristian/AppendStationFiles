# rm(list = ls())

library(devtools)
library(DataQualityCheckEuracAlpEnv)
library(rJava)
library(rChoiceDialogs)
library(svDialogs)
library(properties)
library(rstudioapi)

# set working dir in the script path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(dirname(current_path)))

# setting_dir ="H:/Projekte/Klimawandel/Experiment/data/2order/DQC/Anno_Zero/Setting/file_config_append/"
setting_dir = paste(getwd(),"/Settings/file_config_append/",sep = "")        # <-- TO SET

# ----------------------------------------------------------------------------------------------------------
#                                               SETTINGS  
# ----------------------------------------------------------------------------------------------------------

if(!exists("STATION_DIR")){
  STATION_DIR = jchoose.dir(default = getwd(),caption = "Select the WORKING DIRECTORY you want process:")
  if(length(STATION_DIR) == 0){
    stop("Insert the data folder!") 
    rm(list = ls())
    
  }else{
    station_name = basename(STATION_DIR)
    if(grepl(STATION_DIR,pattern = "hobo")){
      input_setting = read.properties(paste(setting_dir,"/hobo.properties",sep = ""))
    }else{
      if(grepl(STATION_DIR,pattern = "campbell")){
        input_setting = read.properties(paste(setting_dir,"/campbell.properties",sep = ""))
      }else{
        # read file_settings
        input_setting = read.properties(jchoose.files(default = setting_dir,caption = paste("WORKING DIRECTORY selected:",station_name, " - Please, select the file_config to use:")))
      }
    }
  }
}else{
  station_name = basename(STATION_DIR)
  setting_choose = svDialogs::okCancelBox(paste("WORKING DIRECTORY selected:", station_name,". Do you confirm?"))
  
  # setting_choose <-jselect.list(choices = c("TRUE","FALSE"),title = paste("Station to process:", station_name,". Do you want to update?"))
  
  if(setting_choose == "FALSE"){
    STATION_DIR = jchoose.dir(default = dirname(STATION_DIR),caption = "Select the WORKING DIRECTORY you want process:")
    
    station_name = basename(STATION_DIR)
    if(grepl(STATION_DIR,pattern = "hobo")){
      input_setting = read.properties(paste(setting_dir,"/hobo.properties",sep = ""))
    }else{
      if(grepl(STATION_DIR,pattern = "campbell")){
        input_setting = read.properties(paste(setting_dir,"/campbell.properties",sep = ""))
      }else{
        # read file_settings
        input_setting = read.properties(jchoose.files(default = setting_dir,caption = paste("WORKING DIRECTORY selected:",station_name, " - Please, select the file_config to use:")))
      }
    }
    # input_setting = read.properties(jchoose.files(default = getwd(),caption = paste("Station selected:",station_name, " - Please, select the file_config to use:")))
  }
}
# --- Import settings from file_config --- 
# STATION_DIR = jchoose.dir(default = getwd(),caption = "Select the station you want process:")
# STATION_DIR = "H:/Projekte/Klimawandel/Experiment/data/2order/DQC/Anno_Zero/Append/original_files/I1" 
# STATION_DIR = "C:/Users/CBrida/Desktop/Anno_Zero/Append/original_files/I1"

if(length(STATION_DIR) == 0){
  stop("Insert the data folder!")
  
}else{
  
  station_name = basename(STATION_DIR)
  
  # read file_settings
  # input_setting = read.properties(jchoose.files(default = getwd(),caption = paste("Station selected:",station_name, " - Please, select the file_config to use:")))
  
  if(!exists("input_setting")){
    stop("Insert the file_config")
  }else{
    
    STATION_DIR <- gsub("\\\\","/",STATION_DIR)
    # STATION_DIR <- paste(STATION_DIR,"/",sep = "")
    
    input_dir = paste(STATION_DIR,"/output/",sep = "")              #<-- subfolder STATION_DIR/input/
    output_dir = paste(STATION_DIR,"/output_campbell_format/",sep = "")            #<-- subfolder STATION_DIR/output/
    
    
    if(!dir.exists(input_dir) | length(dir(input_dir)) == 0 ){
      print("Files error:")
      stop(paste("Any files in output folder", input_folder)) 
    }else{
      
      if(!dir.exists(output_dir)){
        dir.create(output_dir)
      }
      
      
      # --- Define file settings ---
      file_extension  = input_setting$file_extension
      sep = input_setting$sep
      
      datetime_header = input_setting$datetime_header
      record_header = input_setting$record_header
      
      datetime_format = input_setting$datetime_format
      datetime_sampling = input_setting$datetime_sampling
      
      data_from_row = as.numeric(input_setting$data_from_row)
      header_row_number = as.numeric(input_setting$header_row_number)
      
      
      # file_extension  = ".txt"
      # 
      # # --- Define file settings ---
      # datetime_header = "Date Time, GMT+01:00"
      # datetime_format = "%Y-%m-%d %H:%M:%S"
      # sep = ";"
      # datetime_sampling = "15 min"
      # data_from_row = 3
      # header_row_number = 2
      # record_header = "#"
      # 
      
      
      #  --- Default ouput settings ---
      file_extension_output  = ".dat"
      sep_out = ","
      
      # ----------------------------------------------------------------------------------------------------------
      #                                               START SCRIPT  
      # ----------------------------------------------------------------------------------------------------------
      options(scipen=999)
      
      # input_folder = paste(append_dir, input_dir,sep = "")
      # output_folder = paste(append_dir, output_dir,sep = "")
      input_folder = input_dir
      output_folder = output_dir
      
      files = dir(input_folder,pattern = file_extension)
      
      hr = list()
      hr2 = list()
      data_list = list()
      
      i=1
      
      for(i in 1:length(files)){
        mydata_list = read_data(INPUT_DATA_DIR = input_folder,FILE_NAME = files[i], DATETIME_FORMAT = datetime_format, SEP = sep,
                                DATETIME_HEADER = datetime_header,DATETIME_SAMPLING = datetime_sampling,DATA_FROM_ROW = data_from_row,HEADER_ROW_NUMBER = header_row_number)
        
        header = mydata_list [[1]]
        header_colnames = mydata_list [[2]]
        data = mydata_list [[3]]
        flag_error_df = mydata_list [[4]]
        df_out = mydata_list [[5]]
        
        new_header = hobo_to_campbell(HEADER = header, DATETIME_HEADER = datetime_header,RECORD_HEADER = record_header)
        colnames(new_header) = colnames(data)
        new_row1 = new_header[1,]
        # new_row1 = unname(new_row1)
        
        data = time_to_char(DATA = data, DATETIME_HEADER = datetime_header, DATETIME_FORMAT = datetime_format)
        data_to_write = rbind(new_header, data)
        
        data_to_write = cbind(data_to_write[, which(colnames(data_to_write) == datetime_header)],
                              data_to_write[, which(colnames(data_to_write) == record_header)],
                              data_to_write[, -c(which(colnames(data_to_write) == datetime_header),
                                                 which(colnames(data_to_write) == record_header))])
        # data_to_write = unname(data_to_write,str)
        colnames(new_row1) = colnames(data_to_write)
        data_to_write <- rbind(new_row1,data_to_write)
        data_to_write <- data_to_write[-2,]
        
        file_name_out = paste(substring(files[i], 1, nchar(files[i])-nchar(file_extension)),file_extension_output, sep = "") 
        write.table(data_to_write,paste(output_folder,file_name_out, sep = ""),row.names = FALSE,na = "NaN",sep = sep_out,quote = FALSE,col.names = FALSE,append = FALSE)
      }
      print(" --- DONE ---")
    }
  }
}

