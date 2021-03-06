yadirGetCampaignList <-
function (logins = NULL, token = NULL) {
#�������� ���������� ������
if(is.null(token)) {
  stop("Enter your API token!")
}
  
#��������� ����� ������ ������
start_time  <- Sys.time()

#������� ������
result       <- data.frame(Id = character(0),
                           Name = character(0),
                           Type = character(0),
                           Status = character(0),
                           State = character(0),
                           DailyBudgetAmount = double(0),
                           DailyBudgetMode = character(0),
                           Currency = character(0),
                           StartDate = as.Date(character(0)),
                           Impressions = integer(0),
                           Clicks = integer(0),
                           ClientInfo = character(0),
                           Login = character(0),
                           stringsAsFactors=FALSE)
  
#����� ��������� offset
lim <- 0

#��������� � ������ ��������� ������
packageStartupMessage("Processing", appendLF = F)

while(lim != "stoped"){  
#��������� ���� POST �������
queryBody <- paste0("{
  \"method\": \"get\",
  \"params\": { 
    \"SelectionCriteria\": {},
    \"FieldNames\": [
                    \"Id\",
                    \"Name\",
                    \"Type\",
                    \"StartDate\",
                    \"Status\",
                    \"State\",
                    \"Statistics\",
                    \"Currency\",
                    \"DailyBudget\",
                    \"ClientInfo\"],
    \"Page\": {  
      \"Limit\": 10000,
      \"Offset\": ",lim,"
    }
  }
}")


    
    for(l in 1:length(logins)){
      answer <- POST("https://api.direct.yandex.com/json/v5/campaigns", body = queryBody, add_headers(Authorization = paste0("Bearer ",token), 'Accept-Language' = "ru","Client-Login" = logins[l]))
      #��������� ������
      stop_for_status(answer)
      dataRaw <- content(answer, "parsed", "application/json")
      
        if(length(dataRaw$error) > 0){
            stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
           }
      
      #������� ������
      for (i in 1:length(dataRaw$result$Campaigns)){
        
        try(result <- rbind(result,
                        data.frame(Id                 = dataRaw$result$Campaigns[[i]]$Id,
                                   Name               = dataRaw$result$Campaigns[[i]]$Name,
                                   Type               = dataRaw$result$Campaigns[[i]]$Type,
                                   Status             = dataRaw$result$Campaigns[[i]]$Status,
                                   State              = dataRaw$result$Campaigns[[i]]$State,
                                   DailyBudgetAmount  = ifelse(is.null(dataRaw$result$Campaigns[[i]]$DailyBudget$Amount), NA, dataRaw$result$Campaigns[[i]]$DailyBudget$Amount / 1000000),
                                   DailyBudgetMode    = ifelse(is.null(dataRaw$result$Campaigns[[i]]$DailyBudget$Mode), NA, dataRaw$result$Campaigns[[i]]$DailyBudget$Mode),
                                   Currency           = dataRaw$result$Campaigns[[i]]$Currency,
                                   StartDate          = dataRaw$result$Campaigns[[i]]$StartDate,
                                   Impressions        = ifelse(is.null(dataRaw$result$Campaigns[[i]]$Statistics$Impressions), NA,dataRaw$result$Campaigns[[i]]$Statistics$Impressions),
                                   Clicks             = ifelse(is.null(dataRaw$result$Campaigns[[i]]$Statistics$Clicks), NA,dataRaw$result$Campaigns[[i]]$Statistics$Clicks),
                                   ClientInfo         = dataRaw$result$Campaigns[[i]]$ClientInfo,
                                   Login              = logins[l])), silent = T)
        
        }
    }

  #��������� �����, ��� ������� �������� ���
  packageStartupMessage(".", appendLF = F)
  #��������� �������� �� ��� ������ ������� ���� �������
  lim <- ifelse(is.null(dataRaw$result$LimitedBy), "stoped",dataRaw$result$LimitedBy + 1)
}

#��������������� ��������� ���� ��������������� ���� ������ � ������
result$Type <- as.factor(result$Type)
result$Status <- as.factor(result$Status)
result$State <- as.factor(result$State)
result$Currency <- as.factor(result$Currency)

#��������� ����� ���������� ���������
stop_time <- Sys.time()

#��������� � ���, ��� �������� ������ ������ �������
packageStartupMessage("Done", appendLF = T)
packageStartupMessage(paste0("���������� ���������� ��������� ��������: ", nrow(result)), appendLF = T)
packageStartupMessage(paste0("������������ ������: ", round(difftime(stop_time, start_time , units ="secs"),0), " ���."), appendLF = T)
#���������� ���������
return(result)
}