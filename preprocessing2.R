# install.packages('dplyr')
# install.packages('tidyr')
# install.packages('gridExtra')
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(gridExtra)

# 필요한 패키지를 설치하고 불러옵니다.
# install.packages("showtext")
library(showtext)

# showtext를 사용하여 폰트 시스템을 초기화합니다.
showtext_auto(enable = TRUE)

# 사용할 한글 폰트를 등록합니다. 여기서는 'NanumGothic'을 사용합니다.
font_add_google("Nanum Gothic", "nanumgothic")

# 그래픽 장치를 초기화하고 한글 폰트를 사용하도록 설정합니다.
showtext_begin()


rm(list=ls())
setwd("~/Desktop/ML_Team2/")
car_data <- read.csv("car_bobe (2).csv", stringsAsFactors = FALSE)


View(car_data)
# '가격' 컬럼에 NA값이 있는 행을 제거합니다.
car_data <- car_data[car_data$가격 != "", ]
car_data <- car_data %>% 
  filter(!is.na(가격))
car_data <- car_data %>% 
  filter(!str_detect(가격, "^[^0-9]"))

#가격 -> numeric 형으로

car_data$가격 <- gsub('만원', '', car_data$가격)
car_data$가격 <- gsub(',', '', car_data$가격)
car_data$가격 <- as.numeric(car_data$가격)

#연식 -> YYYY.MM 로 통일
car_data <- car_data %>% 
  mutate(연식 = gsub("^\\s+|\\s+$", "", substr(연식, 1, 8)))

#배기량 -> numeric 형으로
car_data <- car_data %>%
  mutate(배기량 = as.integer(gsub(" cc.*$", "", gsub(",", "", 배기량))))

#주행거리 -> numeric 형으로

car_data <- car_data %>%
  mutate(주행거리 = gsub(" km", "", 주행거리), # Remove ' km'
         주행거리 = gsub(",", "", 주행거리), # Remove commas
         주행거리 = as.integer(주행거리)) # Convert to integer

#색상 -> 세부색상 제거 후 대표 색상만

car_data$색상 <- sub("색.*", "", car_data$색상)

#unique(car_data$색상)

color_groups <- list(
  "흰" = c("흰", "진주", "진주투톤"),
  "회" = c("회", "진회", "은"),
  "파란" = c("파란", "청", "청옥", "하늘", "남", "은하늘", "진청"),
  "검정" = c("검정", "검정투톤"),
  "노란" = c("베이지", "노란", "금", "연금"),
  "자주" = c("자주","보라"))
  
# 그룹화된 색상으로 변경
for (group in names(color_groups)) {
  car_data$색상[car_data$색상 %in% color_groups[[group]]] <- group
}

# '차종' 컬럼을 첫 공백을 기준으로 분할하여 '브랜드'와 '차종' 컬럼으로 나누기
split_names <- strsplit(as.character(car_data$차종), " ", fixed = TRUE)

car_data$브랜드 <- sapply(split_names, function(x) x[1])
car_data$차종 <- sapply(split_names, function(x) paste(x[-1], collapse = " "))

# 9번째 컬럼부터 끝(옵션 컬럼들)까지의 NA 값을 0으로 바꾸기
car_data[, 9:ncol(car_data)][is.na(car_data[, 9:ncol(car_data)])] <- 0

# 맨 마지막 열을 맨 앞 열로 이동

car_data <- car_data[, c(ncol(car_data), 1:(ncol(car_data)-1))]


car_data$전손유무 <- 0
car_data$침수유무 <- 0

car_data$소유자.이전.횟수[car_data$소유자.이전.횟수 == ""] <- 0

car_data <- car_data %>% 
  mutate(`소유자.이전.횟수` = as.integer(gsub("회", "", `소유자.이전.횟수`)))

write.csv(car_data, file = "donotlabeling.csv", row.names = FALSE)

#색상, 변속기 연료 컬럼 레이블 인코딩

car_data$색상 <- as.numeric(factor(car_data$색상, levels = unique(car_data$색상)))
car_data$변속기 <- as.numeric(factor(car_data$변속기, levels = unique(car_data$변속기)))
car_data$연료 <- as.numeric(factor(car_data$연료, levels = unique(car_data$연료)))

# 가장 많은 차종을 찾는 코드
# frequency_table <- table(car_data$차종)
# most_common_car <- names(frequency_table)[which.max(frequency_table)]
# most_common_car

write.csv(car_data, file = "bobae_preprocessing.csv", row.names = FALSE)

# 가격 중 잘못 입력된 값 2개 정정하기
car_data[car_data$가격 == 30000000, '가격'] = 3000
car_data[car_data$가격 == 630000, '가격'] = 630

# 주행거리 중 잘못 입력된 값 정정하기
car_data[car_data$주행거리 == 2322500, '주행거리'] = 232000

write.csv(car_data, file = "after_high_to_low.csv", row.names = FALSE)

View(car_data)
str(car_data)
