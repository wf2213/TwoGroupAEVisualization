circular4 = function(data, tox_include){
  
  order_trt = order %>% as.character()
  other_trt = setdiff(trt_group$TRNO1 %>% unique(), order_trt) %>% as.character()
  
  tot_trt = trt_group$TRNO1 %>% unique() %>% length()
  trt = c(order_trt, other_trt)
  
  trt_group$TRNO1 = as.numeric(factor(trt_group$TRNO1,
                                      levels = trt,
                                      ordered = T))
  
  trno_freq = table(trt_group$TRNO1) %>% as.data.frame()
  names(trno_freq) = c("trno", "trno_tot")
  
  summary_df = data %>%
    left_join(trt_group) %>% #
    as_tibble() %>%
    group_by(CTC_CAT1, TOXLABEL1, TOXDEG1, TRNO1) %>%
    summarise(N = n()) %>%
    ungroup
  
  # add missing toxlabels for each treatment group
  summary_df = summary_df %>%
    complete(TOXLABEL1, TRNO1, fill = list(N = 0)) %>%
    select(-CTC_CAT1) %>%
    left_join(summary_df %>% select(CTC_CAT1, TOXLABEL1)) %>%
    mutate(TOXDEG1 = factor(TOXDEG1),
           CTC_CAT1 = factor(CTC_CAT1),
           TOXLABEL1 = factor(TOXLABEL1)) %>%
    distinct()
  
  summary_df$TOXLABEL1 = summary_df$CTC_CAT1
  
  order = summary_df %>%
    filter(TRNO1 == 1) %>%
    group_by(TOXLABEL1) %>%
    summarise(N = sum(N)) %>%
    arrange(desc(N))
  
  # arrange toxlabel from the most frequent to least
  summary_df = summary_df %>%
    mutate(TOXLABEL1 = TOXLABEL1 %>% as.character,
           CTC_CAT1 = CTC_CAT1 %>% as.character) %>%
    group_by(TRNO1, CTC_CAT1) %>%
    do(rbind(.,c(paste0("Z", unique(.$CTC_CAT1)),
                 unique(.$TRNO1), NA, 0, unique(.$CTC_CAT1)))) %>%
    mutate(N = as.numeric(N)) %>%
    ungroup %>% 
    mutate(TOXLABEL1 = ifelse(!(TOXLABEL1 %>% str_detect("^Z") & 
                                  TOXLABEL1 %>% substr(2, nchar(.)) == CTC_CAT1),
                              paste0(TOXLABEL1, TRNO1),
                              paste0(TOXLABEL1, 3))) %>% 
    arrange(desc(CTC_CAT1), TOXLABEL1)
  
  summary_df$CTC_CAT1=factor(summary_df$CTC_CAT1,
                             levels = rev(order$TOXLABEL1),
                             ordered = T)
  
  summary_df = summary_df %>%
    arrange(desc(CTC_CAT1), TOXLABEL1)
  
  summary_df$id = NA
  summary_df$id[1] = 1
  count = 1
  for (i in 2:nrow(summary_df)){
    if (summary_df$TOXLABEL1[i] != summary_df$TOXLABEL1[i-1]){
      count = count + 1
    }
    summary_df$id[i] = count
  }
  summary_df = summary_df %>% filter(!is.na(CTC_CAT1))
  
  if(type == "Percent"){
    tot_num=table(trt_group$TRNO1) %>% as.data.frame()
    names(tot_num) = c("TRNO1", "tot") 
    summary_df = merge(tot_num, summary_df, by = "TRNO1")
    summary_df$N = summary_df$N/summary_df$tot*100
  }
  
  max_tot = summary_df %>%
    group_by(TRNO1, TOXLABEL1) %>%
    summarise(sums = sum(N)) %>%
    .$sums %>% 
    max
  
  # normalize y axis
  summary_df = summary_df %>% mutate(N1 = N,
                                     N = N)
  
  # Get the name and the y position of each label
  label_data = summary_df %>% 
    group_by(id, TOXLABEL1) %>% 
    summarise(tot = sum(N),
              tot1 = sum(N1)) %>% 
    ungroup
  
  number_of_bar = nrow(label_data)
  angle = 90 - 360 * (label_data$id - 0.5) / number_of_bar
  label_data = label_data %>% 
    mutate(hjust = ifelse(angle < -90, 1, 0),
           angle = ifelse(angle < -90, angle + 180, angle),
           TOXLABEL1 = TOXLABEL1 %>% 
             gsub(".*(other)", "\\1", .))
  
  label_data$TOXLABEL1[duplicated(substr(label_data$TOXLABEL1, 1, nchar(label_data$TOXLABEL1)-1))] = NA
  label_data$TOXLABEL1[label_data$TOXLABEL1 %>% str_detect("3.*")] = NA
  label_data$TOXLABEL1 = substr(label_data$TOXLABEL1, 1, nchar(label_data$TOXLABEL1) - 1)
  
  # add in count
  label_data$trno = NA
  times = dim(label_data)[1]/3
  label_data$trno = rep(1:3,times)
  label_data = merge(label_data, trno_freq, by = "trno", all = T)
  label_data$prop = round(label_data$tot1/label_data$trno_tot*100, 1)
  
  # add grid number
  grid.adj = c(1,5,seq(10,100, 5))
  interval = grid.adj[which.min(abs(max_tot/grid.adj - 4))]
  grid.add = data.frame(N = seq(0, max_tot, interval))
  grid.add$id = dim(label_data)[1]
  
  if(type == "Percent"){
    grid.add$label = paste(grid.add$N, "%", sep = "")
  } else{
    grid.add$label = grid.add$N
  }
  
  # prepare a data frame for base lines
  base_data = summary_df %>% 
    filter(!is.na(TOXDEG1)) %>% 
    group_by(CTC_CAT1) %>% 
    summarize(start = min(id), end = max(id)) %>% 
    rowwise() %>% 
    mutate(title = mean(c(start, end)))
  
  grid_data = base_data
  grid_data$end = grid_data$end[c( nrow(grid_data), 1:nrow(grid_data) - 1)] + 1
  grid_data$start = grid_data$start - 1
  grid_data = grid_data[-1,]
  
  summary_df = summary_df %>% 
    mutate(TOXDEG1 = as.factor(as.numeric(as.character(TOXDEG1)) + 
                                 5*(as.numeric(as.factor(TRNO1)) - 1)))
  
  max_tot = summary_df %>%
    group_by(TRNO1, TOXLABEL1) %>%
    summarise(tot = sum(N)) %>%
    .$tot %>%
    max
  
  cols_temp <- c("1" = "#FFCC00", "2" = "#FF9900", "3" = "#FF6600", "4" = "#CC3300", "5" = "Black",
                 "6" = "#99CCFF", "7" = "#00CCFF", "8" = "#0099FF", "9" = "#0066FF", "10" = "Black")
  use_color = cols_temp[c(tox_include:5, tox_include:5 + 5)]
  
  pos = summary_df[
    !duplicated(summary_df[c("CTC_CAT1", "id", "TRNO1")]),
    c("CTC_CAT1", "id", "TRNO1")]
  pos = pos %>% group_by(CTC_CAT1) %>%
    slice(1:2)
  
  ggplot(summary_df) + 
    geom_bar(aes(x = as.factor(id), y = N, 
                 fill = TOXDEG1), stat="identity") +
    coord_polar() +
    ylim(- max_tot/4, max_tot + interval) +
    geom_text(data = label_data, 
              aes(x = id, y = tot + 0.5, label = TOXLABEL1, hjust = hjust), 
              fontface = "bold", alpha = 0.6, size = 6, 
              angle = label_data$angle) +
    geom_text(data = grid.add,
              aes(x = id, y = N, label = label), color = "grey60",
              size = 4)+
    geom_hline(yintercept = as.numeric(grid.add$N), 
               colour = "grey85", size = 0.2) +
    geom_segment(data = base_data, 
                 aes(x = start - 0.5, y = 0, xend = end + 0.5, yend = 0), 
                 alpha = 0.8, size = 0.6) +
    theme_minimal() +
    guides(fill = guide_legend(ncol = 1)) + 
    theme(axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank(),
          panel.border = element_blank(),
          plot.margin = unit(rep(0,4), "cm"),
          legend.position = "right",
          legend.title = element_text(size = 20, face = "bold"),
          legend.text = element_text(size = 18),
          legend.box.margin = margin(-10, -10, -10, -10)) + 
    labs(fill = "Toxicity Degree") + 
    scale_fill_manual(name = "AE Severity Grade",
                      values = use_color,
                      labels = paste(rep(tox_include:5,2), 
                                     c(paste("Group", order_trt), 
                                       rep("", 5 - tox_include), 
                                       paste("Group", other_trt),
                                       rep("", 5 - tox_include))), 
                      na.translate = F) + #"#73c2FB", "#0080FF", "#1034A6", "Black")) +
    scale_x_discrete(drop = F) -> p; p
  
}
