# For an illustration example, please download ID and AE dataset from Sample Data file
# Read in ID dataset in R and name it id0
# Read in AE dataset in R and name it ae0
# And run the codes below to generate the dataset needed for the plots

library(dplyr)
library(tidyverse)
library(grid)
library(gt)
library(gridExtra)
library(xtable)
library(reshape2)
library(stringr)
library(tidytext)
library(ggplot2)
library(tibble)
library(gtable)
library(DT)
library(purrr)

#################################################################
##                      Specify Variables                      ##
#################################################################
# specify variables for datasets
id_ind = "PATNO"
attr_ind = "TXATT"
ae_ind = "TOXLABEL"
cat_ind = "CTC_CAT"
tox_ind = "TOXDEG"
trno_ind = "TRNO"

# inclusions
attr_include = "Yes" # attribution level you would like to include for the analysis
tox_include = 3 # toxicity grade you would like to include for the analysis
cat_include = "None" # category you would like to exclude for the analysis

group = "Maximum Toxicity Type" # or "Maximum Toxicity Category", indicating how you would like the data to be summarized

# order in table
order = "A" # treatment arm you would like to be used to sort all the plots
type = "Percent" # or "Count" you would like to report
abbre = "Yes" # or "No", whether you would like to use abbreviation for the category when plotting

#################################################################
##                       Create Datasets                       ##
#################################################################
trt_group = id0 %>%
  mutate(PATNO1 = id0[, c(id_ind)],
         TRNO1 = id0[, c(trno_ind)]) %>%
  select(id_ind, trno_ind, PATNO1, TRNO1) %>%
  mutate(TRNO1 = as.character(TRNO1))
  
# define the AE dataset
df1 = ae0 %>%
  mutate(
    PATNO1 = ae0[, c(id_ind)],
    TOXLABEL1 = ae0[, c(ae_ind)],
    CTC_CAT1 = ae0[, c(cat_ind)],
    TOXDEG1 = ae0[, c(tox_ind)],
    TXATT1 = ae0[, c(attr_ind)]
  ) %>%
  mutate(TOXDEG1 = as.numeric(as.character(TOXDEG1)))

df = df1 %>% 
  filter(TXATT1 %in% attr_include,
         as.numeric(TOXDEG1) >= tox_include,
         !(CTC_CAT1 %in% cat_include)) %>% 
  mutate(TXATT1 = factor(TXATT1))

if(abbre=="Yes"){
  df = df %>% 
    mutate(CTC_CAT1 = CTC_CAT1 %>% gsub(",.*$", "",.) %>% word(1))
}

# max toxdeg per category per patient
df_pt_cat = df %>% 
  mutate(TOXDEG1 = as.numeric(as.character(TOXDEG1))) %>% 
  #as_tibble() %>% 
  group_by(PATNO1, CTC_CAT1) %>% 
  filter(TOXDEG1 == max(TOXDEG1)) %>%
  slice(1)%>%
  ungroup()

# max toxdeg per type per patient
df_pt_ae = df %>% 
  mutate(TOXDEG1 = as.numeric(as.character(TOXDEG1))) %>% 
  as_tibble() %>% 
  group_by(PATNO1, TOXLABEL1) %>% 
  filter(TOXDEG1 == max(TOXDEG1)) %>% # or top_n(1, TOXDEG)
  slice(1)%>%
  ungroup()
