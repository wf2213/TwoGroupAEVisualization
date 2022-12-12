circular5 = function(data, tox_include){
  
  order_trt = order %>% as.character()
  other_trt = setdiff(trt_group$TRNO1 %>% unique(), order_trt) %>% as.character()
  
  tot_trt = trt_group$TRNO1 %>% unique() %>% length()
  trt = c(order_trt, other_trt)
  
  summary_df = data %>%
    left_join(trt_group) %>% 
    as_tibble() %>%
    group_by(CTC_CAT1, TOXDEG1, TRNO1) %>%
    summarise(N = n()) %>%
    ungroup %>%
    complete(CTC_CAT1, TOXDEG1, TRNO1, fill = list(N = 0)) 
  
  sel_order1 = summary_df %>% 
    filter(TRNO1 == trt[1]) %>% 
    group_by(CTC_CAT1) %>%
    summarise(tot=sum(N)) %>%
    arrange(desc(tot)) 
  
  sel_order1$labels = factor(sel_order1$CTC_CAT1, levels = sel_order1$CTC_CAT1)
  summary_df$CTC_CAT1 = factor(summary_df$CTC_CAT1, levels = sel_order1$CTC_CAT1)
  summary_df$color = paste(summary_df$TRNO1, summary_df$TOXDEG1, sep = "_")
  
  if(type == "Percent"){
    tot_num = table(trt_group$TRNO1) %>% as.data.frame()
    names(tot_num) = c("TRNO1", "tot") 
    summary_df = merge(tot_num, summary_df, by = "TRNO1")
    summary_df$N = summary_df$N/summary_df$tot*100
  }
  
  # add grid number
  max_tot = summary_df %>%
    group_by(TRNO1, CTC_CAT1) %>%
    summarise(sums = sum(N)) %>%
    .$sums %>% 
    max
  
  color_order = c(paste(order_trt, 1,  sep="_"),
                  paste(order_trt, 2,  sep="_"),
                  paste(order_trt, 3,  sep="_"),
                  paste(order_trt, 4,  sep="_"),
                  paste(order_trt, 5,  sep="_"),
                  paste(other_trt, 1,  sep="_"),
                  paste(other_trt, 2,  sep="_"),
                  paste(other_trt, 3,  sep="_"),
                  paste(other_trt, 4,  sep="_"), 
                  paste(other_trt, 5,  sep="_"))
  
  summary_df$color = factor(summary_df$color, 
                            levels = color_order,
                            ordered = T)
  
  cols_temp <- c("1" = "#FFCC00", "2" = "#FF9900", "3" = "#FF6600", "4" = "#CC3300", "5" = "Black",
                 "6" = "#99CCFF", "7" = "#00CCFF", "8" = "#0099FF", "9" = "#0066FF", "10" = "Black")
  use_color = cols_temp[c(tox_include:5, tox_include:5 + 5)]
  
  if(type == "Percent"){
    summary_df %>%
      filter(!is.na(CTC_CAT1)) %>%
      ggplot() + 
      geom_bar(aes(x = as.factor(TRNO1), y = N, fill = as.factor(as.numeric(color))),
               stat = "identity", position = "stack") +
      facet_grid(~CTC_CAT1, switch = "x", scales = "free_x")+
      theme_minimal()+
      ylab("%") +
      theme(axis.text.y = element_text(colour = "grey60", size = 14),
            axis.ticks.y = element_line(colour = "grey60"),
            axis.text.x = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_text(colour = "grey60", size = 14),
            #panel.grid.major.x = element_blank(),
            #panel.grid = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_line(
              linetype = 'solid',
              colour = "grey90"), 
            panel.grid.minor.y = element_line(
              linetype = 'solid',
              colour = "grey95"), 
            plot.margin = unit(rep(2,4), "cm"),
            legend.position = "bottom",
            legend.title = element_text(size = 20, face = "bold"),
            legend.text = element_text(size = 18)) +
      theme(strip.text.x = element_text(angle = 90, face = "bold", size = 18))+
      geom_hline(yintercept = 0) +
      guides(fill = guide_legend(nrow = 2, 
                                 byrow = T))+
      labs(fill = "Toxicity Degree") + 
      scale_fill_manual(name = "AE Severity Grade",
                        values = use_color,
                        labels = paste(rep(tox_include:5, 2), 
                                       c(rep("", 5 - tox_include), 
                                         paste("Group", order_trt),
                                         rep("", 5 - tox_include), 
                                         paste("Group", other_trt))),
                        na.translate = F) +
      scale_x_discrete(drop = F) -> p; p
  } else{
    summary_df %>%
      filter(!is.na(CTC_CAT1)) %>%
      ggplot() + 
      geom_bar(aes(x = as.factor(TRNO1), y = N, fill = as.factor(as.numeric(color))),
               stat = "identity", position = "stack") +
      facet_grid(~CTC_CAT1, switch = "x", scales = "free_x")+
      theme_minimal()+
      ylab("N")+
      theme(axis.text.y = element_text(colour = "grey60", size = 14),
            axis.ticks.y = element_line(colour = "grey60"),
            axis.text.x = element_blank(),
            axis.title.x = element_blank(),
            axis.title.y = element_text(colour = "grey60", size = 14),
            #panel.grid.major.x = element_blank(),
            #panel.grid = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            panel.grid.major.y = element_line(
              linetype = 'solid',
              colour = "grey90"), 
            panel.grid.minor.y = element_line(
              linetype = 'solid',
              colour = "grey95"),
            plot.margin = unit(rep(2,4), "cm"),
            legend.position = "bottom",
            legend.title = element_text(size = 20, face = "bold"),
            legend.text = element_text(size = 18)) +
      theme(strip.text.x = element_text(angle = 90, face = "bold", size = 18))+
      geom_hline(yintercept = 0) +
      guides(fill = guide_legend(nrow = 2,
                                 byrow = T))+
      labs(fill = "Toxicity Degree") + 
      scale_fill_manual(name = "AE Severity Grade",
                        values = use_color,
                        labels = paste(rep(tox_include:5,2), 
                                       c(rep("", 5 - tox_include), 
                                         order_trt,
                                         rep("", 5 - tox_include), 
                                         other_trt)), 
                        na.translate = F) +
      scale_x_discrete(drop = F) -> p; p
  }
}
