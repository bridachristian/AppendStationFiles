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
setting_dir = paste(getwd(),"/Settings/file_config_append/",sep = "")      # <-- HERE YOU HAVE TO SET WHERE THE PROPERTIES FILES PRODUCED WITH THE SCRIPT
#                                                                           #     01_file_config_creator.R  (Settings)  


 
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
  rm(list = ls())
  stop("Insert the data folder!")
  
}else{
  
  station_name = basename(STATION_DIR)
  
  # read file_settings
  # input_setting = read.properties(jchoose.files(default = getwd(),caption = paste("Station selected:",station_name, " - Please, select the file_config to use:")))
  
  
  if(!exists("input_setting")){
    rm(list = ls())
    stop("Insert the file_config")
  }else{
    
    # --- Define path --- 
    
    STATION_DIR <- gsub("\\\\","/",STATION_DIR)
    # STATION_DIR <- paste(STATION_DIR,"/",sep = "")
    
    input_dir = paste(STATION_DIR,"/input/",sep = "")              #<-- subfolder STATION_DIR/input/
    output_dir = paste(STATION_DIR,"/output/",sep = "")            #<-- subfolder STATION_DIR/output/
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
    
    # --- Define checking settings ---
    first_row_to_check = as.numeric(input_setting$first_row_to_check)
    last_row_to_check = as.numeric(input_setting$last_row_to_check)
    
    # --- Define output format ---
    quote_header = as.logical(input_setting$quote_header)
    
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
    # # --- Define checking settings ---
    # first_row_to_check = 1
    # last_row_to_check = 2
    # 
    # # --- Define output format ---
    # quote_header = TRUE
    
    # --- Load read data function ---
    print("--- INPUT SETTING SUMMARY ---")
    print(paste("station_name =",station_name))
    print(paste("input_dir =",input_dir))
    print(paste("output_dir =",output_dir))
    print(paste("file_extension =",file_extension))
    print(paste("sep = ",sep))
    print(paste("datetime_format =",datetime_format))
    print(paste("record_header =",record_header))
    print(paste("datetime_header =",datetime_header))
    print(paste("datetime_sampling =",datetime_sampling))
    print(paste("data_from_row =",data_from_row))
    print(paste("header_row_number =",header_row_number))
    print(paste("first_row_to_check =",first_row_to_check))
    print(paste("last_row_to_check =",last_row_to_check))
    print(paste("quote_header =",quote_header))
    print("-----------------------------")
    print(paste("Time start: ", Sys.time()))
    print("-----------------------------")
    
    t1 = Sys.time()
    # ----------------------------------------------------------------------------------------------------------
    #                                               START SCRIPT  
    # ----------------------------------------------------------------------------------------------------------
    
    options(scipen=999)
    
    # input_folder = paste(append_dir, input_dir,sep = "")
    # output_folder = paste(append_dir, output_dir,sep = "")
    input_folder = input_dir
    output_folder = output_dir
    
    files = dir(input_folder,pattern = file_extension)
    if(length(files) == 0){
      print("Files error:")
      stop(paste("Any files in input folder", input_folder))  
    }
    hr = list()
    hr2 = list()
    data_list = list()
    
    i=1
    
    for(i in 1:length(files)){
      gc(reset = T)
      mydata_list = read_data(INPUT_DATA_DIR = input_folder,FILE_NAME = files[i], DATETIME_FORMAT = datetime_format, SEP = sep,
                              DATETIME_HEADER = datetime_header,DATETIME_SAMPLING = datetime_sampling,DATA_FROM_ROW = data_from_row,HEADER_ROW_NUMBER = header_row_number)
      
      header = mydata_list [[1]]
      header_colnames = mydata_list [[2]]
      data = mydata_list [[3]]
      flag_error_df = mydata_list [[4]]
      df_out = mydata_list [[5]]
      
      if(flag_error_df == -1 | flag_error_df == 1 ){ 
        stop_flag = 1
        file_stop = files[i]
        print("Structure error:")
        print(df_out)
        stop(paste(file_stop, "has a wrong structure"))  
        
      }else{
        stop_flag = 0
        colnames(data) =  header_colnames
      }
      
      data = time_to_char(DATA = data,DATETIME_HEADER = datetime_header,DATETIME_FORMAT = datetime_format)
      
      hr [[i]] = header
      names(hr)[[i]] = files[i]
      
      hr2 [[i]] = header[first_row_to_check:last_row_to_check,]   # <-- rows to check
      names(hr2)[[i]] = files[i]
      
      data_list [[i]] = data
      names(data_list)[[i]] = files[i]
      
    }
    
    if(stop_flag == 1){
      print(paste("Error:",file_stop, "has wrong structure"))
      print(df_out)
      stop("Wrong structure!")
    }else{
      
      u2 = unique(sapply(hr2,ncol))
      file_names_change_first = c()
      file_names_change_last = c()
      
      k=1
      for(k in 1: length(u2)){
        gc(reset = T)
        w  = unname(which(sapply(hr2, ncol) == u2[k]))
        hr2_star = hr2[w]
        hr_k = hr[w]
        
        sss = sapply(hr2_star, paste, collapse = "-")      # <- group by identical header dataframe
        
        data_list_w = data_list[w]
        
        h=1
        
        for(h in 1:length(unique(sss))){
          gc(reset = T)
          w_group = which(sss == unique(sss)[h])
          data_list_star = data_list_w[w_group]
          hr_write = hr_k[w_group][[length(data_list_star)]]
          
          file_name_out = names(data_list_star)[length(data_list_star)]
          
          data_append = do.call("rbind",data_list_star)
          data_append = DataQualityCheckEuracAlpEnv::deletes_duplcated_data(data_append,DATETIME_HEADER = datetime_header)[[1]]
          data_append[,which(colnames(data_append) == datetime_header)] = as.character(data_append[,which(colnames(data_append) == datetime_header)])
          
          data_append = data_append[order(data_append[which(colnames(data_append)== datetime_header)]),]
          colnames(hr_write) = colnames(data_append)  
          
          if(quote_header == TRUE){
            fff = as.data.frame(apply(hr_write, c(1,2), function(x) paste("\"", x, "\"",sep = "")),stringsAsFactors = F)
          }else{
            fff = hr_write
          }
          
          # WRITE HEADER AND APPEND DATA
          write.table(fff,paste(output_folder,file_name_out, sep = ""),row.names = FALSE,na = "NaN",sep = sep,quote = FALSE,col.names = FALSE,append = FALSE)
          write.table(data_append,paste(output_folder,file_name_out, sep = ""),row.names = FALSE,na = "NaN",sep = sep,quote = FALSE,col.names = FALSE,append = TRUE)
          
          file_names_change_first = c(file_names_change_first,names(data_list_star)[1])
          file_names_change_last = c(file_names_change_last,names(data_list_star)[length(data_list_star)])
        }
      }
      
      
      if(length(file_names_change_first)> 1){
        print("--- RESULTS ---")
        print("Header changes!")
        
        df_print = data.frame(seq(from = 1, to = length(file_names_change_first),by = 1), file_names_change_first,file_names_change_last,rep("-->",times = length(file_names_change_first)), file_names_change_first)
        colnames(df_print) = c("Group","From", "To","", "New filename")
        print(df_print)
        
      }else{
        print("--- RESULTS ---")
        print("The whole files in the input folder have the same headers")
      }
      t2 = Sys.time()
      print(paste("Time end: ", Sys.time()))
      print(t2 - t1)
    }
    print(" --- DONE ---")
  }
}
