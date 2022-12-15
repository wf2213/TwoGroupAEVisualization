TypeHorizontalBar = function(data, tox_include, cats = unique(data$CTC_CAT1)){
  order_trt = order %>% as.character()
  other_trt = setdiff(trt_group$TRNO1 %>% unique(), order_trt) %>% as.character()
  
  tot_trt = trt_group$TRNO1 %>% unique() %>% length()
  trt = c(order_trt, other_trt)
  
  # Data Cleaning - same as circular 1
  summary_df = data %>% 
    left_join(trt_group) %>%
    as_tibble() %>% 
    dplyr::group_by(CTC_CAT1, TOXLABEL1, TOXDEG1, TRNO1) %>% 
    dplyr::summarise(N = n()) %>% # count number of ae per toxlabel, deg and treatment
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
  
  summary_df = summary_df %>% 
    mutate(TOXLABEL1 = TOXLABEL1 %>% as.character,
           CTC_CAT1 = CTC_CAT1 %>% as.character) %>% 
    group_by(TRNO1, CTC_CAT1) %>% 
    do(rbind(.,c(paste0("Z", unique(.$CTC_CAT1)),
                 unique(.$TRNO1), NA, 0, unique(.$CTC_CAT1)))) %>% 
    mutate(N = as.numeric(N)) %>% 
    ungroup
  
  # arrange toxlabel from the most frequent to least
  # add percentage
  if(type == "Percent"){
    tot_num = table(trt_group$TRNO1) %>% as.data.frame()
    names(tot_num) = c("TRNO1", "tot") 
    summary_df = merge(tot_num, summary_df, by = "TRNO1")
    summary_df$N = summary_df$N/summary_df$tot*100
  }
  
  new_factor = summary_df %>% 
    filter(TRNO1 == trt[1]) %>% 
    group_by(CTC_CAT1, TOXLABEL1) %>% 
    dplyr::summarise(total_n = sum(N)) %>% 
    mutate(max_n = max(total_n)) %>% 
    arrange(desc(max_n), CTC_CAT1, desc(total_n)) %>% 
    ungroup %>% 
    select(TOXLABEL1) %>%
    unlist %>% 
    as.vector
  
  reorder_df = function(trno){
    df = summary_df %>% 
      filter(TRNO1 == trno) %>% 
      arrange(factor(TOXLABEL1, levels = new_factor))
    
    df$id = NA
    df$id[1] = 1
    count = 1
    for (i in 2:nrow(df)){
      if (df$TOXLABEL1[i] != df$TOXLABEL1[i-1]){
        count = count + 1
      }
      df$id[i] = count
    }
    
    df$id_label = NA
    df$id_label[1] = 1
    count = 1
    for (i in 2:nrow(df)){
      if (df$TOXLABEL1[i] != df$TOXLABEL1[i-1]){
        # do not increment id variable if it is an empty bar
        if (!(df$TOXLABEL1[i] %>% str_detect("^Z") &
              df$TOXLABEL1[i] %>% substr(2, nchar(.)) == df$CTC_CAT1[i])){
          count = count + 1
        }
      }
      df$id_label[i] = count
    }
    
    
    # Get the name and the y position of each label
    label_data = df %>% 
      group_by(id, id_label, CTC_CAT1, TOXLABEL1) %>% 
      summarise(tot=sum(N)) %>% 
      ungroup %>% 
      group_by(CTC_CAT1) %>% 
      mutate(id_label = c(id_label[-n()], NA),
             TOXLABEL1 = TOXLABEL1 %>% gsub(".*(other)", "\\1", .) %>% factor())
    
    
    # prepare a data frame for base lines
    base_data = df %>% 
      group_by(CTC_CAT1) %>% 
      summarize(start = min(id), end = max(id)-1) %>% 
      rowwise() %>% 
      mutate(title=mean(c(start, end)))
    
    return (list(df, label_data, base_data))
  }
  
  list_trt1 = reorder_df(trt[1])
  summary_df1 = list_trt1[[1]]
  label_df1 = list_trt1[[2]]
  base_df1 = list_trt1[[3]]
  
  list_trt2 = reorder_df(trt[2])
  summary_df2 = list_trt2[[1]]
  label_df2 = list_trt2[[2]]
  base_df2 = list_trt2[[3]]
  
  # set plot scale
  max_trt_count = summary_df %>% 
    group_by(TRNO1, TOXLABEL1) %>% 
    summarise(sums = sum(N)) %>% 
    .$sums %>% max
  
  # y axis
  y_max = max(label_df1$id)
  
  # set up ggplot 
  p = ggplot() + 
    theme_minimal() +
    theme(#axis.text = element_text(colour = "grey"),
      #axis.title = element_blank(),
      #panel.grid = element_blank(),
      legend.position = "bottom") +
    coord_flip() +
    scale_fill_manual(name = "AE Severity Grade",
                      breaks = c("1", "2", "3", "4", "5"),
                      values = c("#99CCFF", "#00CCFF", "#0099FF", "#0066FF", "Black"),
                      na.translate = F,
                      drop = FALSE)+
    scale_x_continuous(limits = c(-y_max, 0)) +
    labs(x = NULL, y = NULL)
  
  p1 = p +
    geom_bar(data = summary_df1, 
             aes(x = -id, y = N, fill = TOXDEG1), 
             stat="identity") +
    geom_text(data = label_df1,
              aes(x = -id, y = tot, label = id_label),
              hjust = 1.5, size=3) +
    geom_segment(data = base_df1, 
                 aes(x = -(start - 0.5), y = 0, 
                     xend = -(end + 0.5), yend = 0))+
    #scale_y_continuous(position = "right") +
    scale_y_reverse(limits = c(max_trt_count, 0)) + # max_trt_count+1
    theme(axis.text.x = element_text(colour = "grey60", size=14),
          axis.text.y = element_blank(),
          #axis.title = element_blank(),
          panel.grid.major.y = element_blank(),
          #panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_line(#size = 0.5, 
            linetype = 'solid',
            colour = "grey90"), 
          panel.grid.minor.x = element_line(#size = 0.25, 
            linetype = 'solid',
            colour = "grey95"),
          legend.title = element_text(size=20, face="bold"),
          legend.text = element_text(size=18),
          plot.title = element_text(size = 25, 
                                    face = "bold",
                                    hjust = 0.5))+
    ggtitle(trt[1])
  
  
  p2 = p +
    geom_bar(data = summary_df2, 
             aes(x = -id, y = N, fill = TOXDEG1), 
             stat="identity") +
    geom_text(data = label_df2,
              aes(x = -id, y = tot, label = id_label),
              hjust = -0.5, size=3) +
    geom_segment(data = base_df2, 
                 aes(x = -(start - 0.5), y = 0, 
                     xend = -(end + 0.5), yend = 0)) +
    scale_y_continuous(limits = c(0, max_trt_count))+ # max_trt_count+1
    theme(axis.text.x = element_text(colour = "grey60", size=14),
          axis.text.y = element_blank(),
          #axis.title = element_blank(),
          panel.grid.major.y = element_blank(),
          #panel.grid.minor.y = element_blank(),
          panel.grid.major.x = element_line(#size = 0.5, 
            linetype = 'solid',
            colour = "grey90"), 
          panel.grid.minor.x = element_line(#size = 0.25, 
            linetype = 'solid',
            colour = "grey95"),
          plot.title = element_text(size = 25, 
                                    face = "bold",
                                    hjust = 0.5))+
    ggtitle(trt[2])
  
  p_label = ggplot() +
    geom_text(data = base_df1,
              aes(y = - title, x = 0, label = CTC_CAT1),
              size=7, fontface="bold") + 
    theme_minimal() +
    xlab(ifelse(type=="Percent","%","N"))+
    theme(axis.text = element_blank(),
          #axis.title = element_blank(),
          panel.grid = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_text(colour = "grey", size=14),
          plot.title = element_text(size = 25, 
                                    face = "bold",
                                    hjust = 0.5))+
    ggtitle(" ")+
    scale_y_continuous(limits = c(- y_max, 0))
  
  # TOXLABEL sublabel
  p_sublabel = ggplot() +
    geom_text(data = label_df1, 
              aes(x = -id, y = 0, 
                  label = ifelse(is.na(id_label), NA, paste0(id_label, ":", TOXLABEL1))),
              hjust = 0, size=4) +
    coord_flip() +
    theme_minimal() +
    scale_x_continuous(limits = c(-y_max, 0)) +
    scale_y_continuous(limits = c(0, 0.05))+
    theme(axis.text = element_blank(),
          panel.grid = element_blank(),
          axis.title = element_blank(),
          plot.title = element_text(size = 25, 
                                    face = "bold",
                                    hjust = 0.5))+
    ggtitle(" ")
  
  g_legend = function(a.gplot){
    tmp = ggplot_gtable(ggplot_build(a.gplot))
    leg = which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend = tmp$grobs[[leg]]
    return(legend)}
  
  mylegend = g_legend(p1)
  grid.arrange(arrangeGrob(p1 + theme(legend.position="none"),
                           p_label,
                           p2 + theme(legend.position="none"),
                           p_sublabel,
                           layout_matrix = rbind(c(rep(1, 3), 2, 
                                                   rep(3, 3), 4, 4))),
               mylegend, nrow = 2,heights = c(30, 1))
}
