yadirGetMetrikaGAData <- function

                      (start_date = "10daysAgo",
                       end_date = "today",
                       counter_ids = NULL,
                       dimensions = NULL,
                       metrics = NULL,
                       filters = NULL,
                       sort = NULL,
                       samplingLevel = "HIGHER_PRECISION",
                       token = NULL){
#�������� ���������� ������������ ����������
if(is.null(counter_ids)|is.null(metrics)|is.null(token)){
  stop("��������� counter_ids, metrics � token �������� �������������, ��������� �� � ��������� ������ ��������!")
}
  
#��������� ������� StringAsFactor
if(getOption("stringsAsFactors") == TRUE){
  string_as_factor <- "change"
  options(stringsAsFactors = F)
} else {
  string_as_factor <- "no change"
}

#������ �������������� ���� �����
result <- data.frame(stringsAsFactors = F)

#������� ������� �� ������ � �����������
metrics <- gsub(" ", "",metrics)

#���������� ��� ������������ �������
max_results <- 500
start_index <- 1
last_query <- FALSE

packageStartupMessage("Processing", appendLF = F)

while(last_query == FALSE){

#��������� GET ������ � API �������
#��������� GET ���������
query <- paste0("start-date=",start_date,"&end-date=",end_date,"&metrics=",metrics,"&ids=",counter_ids,"&max-results=",max_results,"&start-index=",start_index,"&oauth_token=",token)
#�� ������� ��������� �� ������������ ���������
if(!is.null(dimensions)) {
  dimensions <- gsub(" ", "",dimensions)
  query <- paste0(query,"&dimensions=",dimensions)}
if(!is.null(filters)) query <- paste0(query,"&filters=",filters)
if(!is.null(sort)) query <- paste0(query,"&sort=",sort)
if(!is.null(samplingLevel)) query <- paste0(query,"&samplingLevel=",samplingLevel)

#�������� ���� ������� ���������� �� URL ���������
query <- gsub(":","%3a",query)
#��������� URL � GET ���������
query <- paste0("https://api-metrika.yandex.ru/analytics/v3/data/ga?", query)
#���������� ������ �� ������
answer <- GET(query)
#������ ���������
rawData <- content(answer, "parsed", "application/json")

#�������� ������ �� ������
if(!is.null(rawData$error)){
  stop(paste0(rawData$error$errors[[1]]$reason," - ",rawData$error$errors[[1]]$message, ", location - ", rawData$error$errors[[1]]$location))
}

#������� ����������
#�������� ������ � ��������� ��������
column_names <- unlist(lapply(rawData$columnHeader, function(x) return(x$name)))

#������ ������
rows <- lapply(rawData$rows, function(x) return(x))
for(rows_i in 1:length(rows)){
  result <- rbind(result, unlist(rows[[rows_i]]))
}
#������� �����
packageStartupMessage(".", appendLF = F)
#��������� �� ��������� ��������.
start_index <- start_index + max_results

#��������� ��������� �� ��� ��������
if(rawData$totalResults < start_index){
  last_query <- TRUE
 }
}

#����� ����� ��������
colnames(result) <- column_names

#����������� ��� ������ � ��������
for(tape_i in 1:length(rawData$columnHeaders)){

  if(rawData$columnHeaders[[tape_i]]$columnType == "METRIC"){
    result[,tape_i] <- as.numeric(result[,tape_i])
  }
}

#���������� ����� ������������ ��������� ����� � ������ ���� ������ � �� ������ ������
if(string_as_factor == "change"){
  options(stringsAsFactors = T)
}

#������� ��������� � ��� ��� ������ ���������
packageStartupMessage("Done", appendLF = T)

#������� ����� ����������
if(rawData$containsSampledData == TRUE){
packageStartupMessage("��� ����� ������ ���� ������������ �������������.", appendLF = T)
packageStartupMessage(paste0("������ ������� �� ������� ��������� �����: ", rawData$sampleSize), appendLF = T)
packageStartupMessage(paste0("������ ������� ���������� : ",  as.integer(rawData$sampleSize) / as.integer(rawData$sampleSpace) * 100, "% �� ������ ���������� �������"), appendLF = T)
packageStartupMessage(paste0("����� ���������� ���������� �����������: ", rawData$totalResults), appendLF = T)
} else {
packageStartupMessage("��� ����� ������ �� ���� ������������ �������������.", appendLF = T)
packageStartupMessage(paste0("����� ���������� ���������� �����������: ", rawData$totalResults), appendLF = T)
}
#��������� ���������
return(result)
}