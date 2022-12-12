circular3 = function(data, tox_include){
  
  trno_freq = table(trt_group$TRNO1) %>% as.data.frame()
  names(trno_freq) = c("TRNO1", "trno_tot")
  
  order_trt = order %>% as.character()
  other_trt = setdiff(trt_group$TRNO1 %>% unique(), order_trt) %>% as.character()
  
  tot_trt = trt_group$TRNO1 %>% unique() %>% length()
  trt = c(order_trt, other_trt)
  
  # Data Cleaning
  summary_df = data %>% 
    left_join(trt_group) %>% #
    as_tibble() %>% 
    group_by(PATNO1, CTC_CAT1, TRNO1, TOXDEG1) %>% 
    summarise(N = n()) %>% 
    ungroup %>% 
    group_by(CTC_CAT1, TOXDEG1, TRNO1) %>% 
    summarise(N = sum(N)) %>% 
    ungroup
  
  summary_df = summary_df %>% add_row(CTC_CAT1 = NA,
                                      TRNO1 = trt[1])
  
  summary_df = summary_df %>% 
    complete(CTC_CAT1, TRNO1, fill = list(N = 0)) %>% 
    mutate(TOXDEG1 = factor(TOXDEG1),
           CTC_CAT1 = factor(CTC_CAT1)
    ) 
  
  # arrange toxlabel from the most frequent to least
  summary_df = summary_df %>% 
    mutate(#TOXLABEL = TOXLABEL %>% as.character,
      CTC_CAT1 = CTC_CAT1 %>% as.character) %>% 
    group_by(TRNO1, CTC_CAT1) %>% 
    mutate(N = as.numeric(N)) %>% 
    ungroup
  
  # normalize y axis
  summary_df = summary_df %>% 
    mutate(N1 = N,
           N) %>% 
    rename(TOXLABEL1 = CTC_CAT1)
  
  max_tot = summary_df %>% 
    group_by(TRNO1, TOXLABEL1) %>% 
    summarise(tot=sum(N)) %>% 
    .$tot %>% 
    max
  
  max_tot_pct = summary_df %>% 
    group_by(TRNO1, TOXLABEL1) %>% 
    summarise(tot = sum(N)) %>%
    merge(trno_freq, "TRNO1") %>%
    summarise(pct = tot/trno_tot*100) %>%
    .$pct %>% 
    max
  
  ### add and sort label
  annotation = summary_df%>%
    group_by(TOXLABEL1, TRNO1)%>%
    dplyr::summarize(location=sum(N))
  
  ### sort CTC_CAT
  order = annotation %>%
    filter(TRNO1 == trt[1]) %>%
    arrange(desc(location))
  
  summary_df$TOXLABEL1 = factor(summary_df$TOXLABEL1,
                                levels = rev(order$TOXLABEL1),
                                ordered = T)
  
  positions = function(trno){
    df = summary_df %>% 
      filter(TRNO1 == trno) %>% 
      arrange(desc(TOXLABEL1))
    
    df$id = NA
    df$id[1] = 1
    count = 1
    for (i in 2:nrow(df)){
      if (df$TOXLABEL1[i] != df$TOXLABEL1[i-1] | is.na(df$TOXLABEL1[i])){
        count = count + 1
      }
      df$id[i] = count
    }
    
    if(type == "Percent"){
      tot_num = table(trt_group$TRNO1) %>% as.data.frame()
      names(tot_num) = c("TRNO1", "tot") 
      df = merge(tot_num, df, by = "TRNO1")
      df$N = df$N/df$tot*100
    }
    
    # Get the name and the y position of each label
    label_data = df %>% 
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
               gsub(".*(other)", "\\1", .) %>% 
               factor())
    
    # add grid number
    if(type == "Percent"){
      max_tot = max_tot_pct
    }
    
    grid.adj = c(1, 5, seq(10, 1000, 5))
    interval = grid.adj[which.min(abs(max_tot/grid.adj - 4))]
    grid.add = data.frame(N = seq(0, max_tot, interval))
    grid.add$id = dim(label_data)[1]
    
    if(type == "Percent"){
      grid.add$label = paste(grid.add$N, "%", sep="")
    } else{
      grid.add$label = grid.add$N
    }
    
    p = ggplot(df) + 
      coord_polar() +
      theme_minimal() +
      geom_bar(aes(x = as.factor(id), y = N, fill = TOXDEG1), 
               stat="identity") +
      scale_y_continuous(limits = c(-max_tot/4, max_tot + interval),
                         breaks = as.numeric(grid.add$N))+
      geom_text(data = label_data, 
                aes(x = id, y = tot + 0.5, fontface = "bold",
                    label = TOXLABEL1, hjust = hjust), 
                size = 6, angle = label_data$angle) +
      geom_text(data = grid.add,
                aes(x = id, y = N, label = label), color = "grey60",
                size = 4)+
      geom_hline(yintercept = as.numeric(grid.add$N), 
                 colour = "grey85", size = 0.2) +
      theme(#axis.text.y = element_text(colour = "grey"),
        panel.border = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        #axis.title = element_blank(),
        panel.grid = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.margin = unit(rep(0.3,4), "cm"),
        legend.position = "bottom",
        legend.title = element_text(size = 20, face = "bold"),
        legend.text = element_text(size = 18),
        plot.title = element_text(size = 25, 
                                  face = "bold",
                                  hjust = 0.5)) +
      scale_fill_manual(name = "AE Severity Grade",
                        breaks = c("1", "2", "3", "4", "5"),
                        values = c("#99CCFF", "#00CCFF", "#0099FF", "#0066FF", "Black"),
                        na.translate = F,
                        drop = FALSE) +
      scale_x_discrete(drop = F) +
      ylab(NULL) +
      ggtitle(trno)
    return (p)
  }
  
  positions(trt[1]) -> p1
  positions(trt[2]) -> p2
  
  g_legend = function(a.gplot){
    tmp = ggplot_gtable(ggplot_build(a.gplot))
    leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend = tmp$grobs[[leg]]
    return(legend)}
  
  mylegend = g_legend(p1)
  grid.arrange(arrangeGrob(p1 + theme(legend.position="none"),
                           p2 + theme(legend.position="none"),
                           nrow = 1),
               mylegend, nrow = 2, heights = c(30, 1))
}
