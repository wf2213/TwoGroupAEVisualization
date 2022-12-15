TypeVerticalBar = function(data, tox_include, cats = unique(data$CTC_CAT1)){
  
  order_trt = order %>% as.character()
  other_trt = setdiff(trt_group$TRNO1 %>% unique(), order_trt) %>% as.character()
  
  tot_trt = trt_group$TRNO1 %>% unique() %>% length()
  trt = c(order_trt, other_trt)
  
  plt_data = data %>%
    left_join(trt_group)
  
  plt_data = plt_data %>%
    group_by(CTC_CAT1, TOXLABEL1, TOXDEG1, TRNO1) %>%
    dplyr::summarise(N = n())
  
  plt_data$N[which(plt_data$TRNO1 == trt[2])] =
    0 - plt_data$N[which(plt_data$TRNO1 == trt[2])]
  plt_data = plt_data %>%
    mutate(CTC_CAT1 = gsub(",.*$", "", CTC_CAT1) %>% word(1))
  
  if(type == "Percent"){
    tot_num = table(trt_group$TRNO1) %>% as.data.frame()
    names(tot_num) = c("TRNO1", "tot") 
    plt_data = merge(tot_num, plt_data, by = "TRNO1")
    plt_data$N = plt_data$N/plt_data$tot*100
  }
  
  ### trt 1 down, trt 2 above
  ### add and sort label
  annotation = plt_data[which(plt_data$TRNO1 == trt[1]),] %>%
    group_by(TOXLABEL1) %>%
    dplyr::summarize(location = sum(N))
  additional = plt_data[which(plt_data$TRNO1 == trt[2]), 
                        "TOXLABEL1"] %>% unique()
  
  additional = as.data.frame(additional)
  names(additional) = "TOXLABEL1"
  additional = additional[(!additional$TOXLABEL1 %in% annotation$TOXLABEL1), ]
  additional = as.data.frame(additional)
  names(additional) = "TOXLABEL1"
  
  if(dim(additional)[1] != 0){
    additional$location = 0
    annotation = rbind(annotation, additional)
  }
  
  annotation$TOXDEG1 = 5
  annotation = merge(annotation,
                     plt_data[c("TOXLABEL1", 
                                "CTC_CAT1")][!duplicated(plt_data[c("TOXLABEL1", 
                                                                    "CTC_CAT1")]),],
                     by = "TOXLABEL1")
  annotation = annotation %>% arrange(desc(location))
  plt_data$TOXLABEL1 = factor(plt_data$TOXLABEL1,
                              levels = annotation$TOXLABEL1)
  annotation$TOXLABEL1 = factor(annotation$TOXLABEL1,
                                levels = annotation$TOXLABEL1)
  
  ### sort CTC_CAT
  order = annotation%>%
    group_by(CTC_CAT1)%>%
    dplyr::summarize(order = max(location))%>%
    arrange(desc(order))
  
  plt_data$CTC_CAT1 = factor(plt_data$CTC_CAT1,
                             levels = order$CTC_CAT1)
  
  if(type == "Percent"){
    p = ggplot(plt_data, aes(y = N, x = TOXLABEL1, fill = as.factor(TOXDEG1)))+
      geom_bar(stat = "identity", position = "stack")+
      scale_y_continuous(expand = c(.1, .1))
    
    ggplot(plt_data, aes(y = N, x = TOXLABEL1, fill = as.factor(TOXDEG1)))+
      geom_bar(stat = "identity", position = "stack")+
      scale_y_continuous(expand = c(.1, .1),
                         breaks = (ggplot_build(p)$layout$panel_params[[1]]$y.sec$breaks),
                         labels = abs(ggplot_build(p)$layout$panel_params[[1]]$y.sec$breaks)
      ) +
      geom_text(annotation, mapping = aes(x = TOXLABEL1, y = location, 
                                          label = TOXLABEL1),
                size = 4, angle = 90, hjust = -0.5)+
      facet_grid(~factor(CTC_CAT1,
                         levels = order$CTC_CAT1),
                 switch = "x",
                 scales = "free_x", space = "free_x")+
      theme_minimal()+
      #ylab(paste(other_trt, "", "", "","", "", "", "%", "", "", "", "", "", "",order_trt))+
      ylab("%")+
      theme(axis.text.y = element_text(colour = "grey60", size = 14),
            axis.title.y = element_text(colour = "grey60", size = 14),
            axis.text.x = element_blank(),
            #axis.text = element_blank(),
            axis.title.x = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.y = element_line(#size = 0.25, 
              linetype = 'solid',
              colour = "grey95"),
            panel.grid.major.y = element_line(
              linetype = 'solid',
              colour = "grey90"),
            legend.position = "bottom",
            legend.title = element_text(size =20, face = "bold"),
            legend.text = element_text(size = 18),
            strip.text.x = element_text(angle = 90, face = "bold", size = 16))+
      scale_fill_manual(name = "AE Severity Grade",
                        breaks = c("1", "2", "3", "4", "5"),
                        values = c("#99CCFF", "#00CCFF", "#0099FF", "#0066FF", "Black"),
                        na.translate = F,
                        drop = FALSE)+
      geom_hline(yintercept = 0, size = 0.5, linetype = 1, alpha = 1)
  } else {
    p = ggplot(plt_data, aes(y = N, x = TOXLABEL1, fill = as.factor(TOXDEG1)))+
      geom_bar(stat = "identity",position = "stack")+
      scale_y_continuous(expand = c(.1, .1)) 
    
    ggplot(plt_data, aes(y = N, x = TOXLABEL1, fill = as.factor(TOXDEG1)))+
      geom_bar(stat = "identity", position = "stack")+
      scale_y_continuous(expand = c(.1, .1),
                         breaks = (ggplot_build(p)$layout$panel_params[[1]]$y.sec$breaks),
                         labels = abs(ggplot_build(p)$layout$panel_params[[1]]$y.sec$breaks)
      ) +
      geom_text(annotation, mapping = aes(x = TOXLABEL1, y = location, 
                                          fill = as.factor(TOXDEG1), label = TOXLABEL1),
                size = 4, angle = 90, hjust = -0.5)+
      facet_grid(~factor(CTC_CAT1,
                         levels = order$CTC_CAT1),
                 switch = "x",
                 scales = "free_x", space = "free_x")+
      theme_minimal()+
      #ylab(paste(other_trt, "", "", "","", "", "", "N", "", "", "", "", "", "",order_trt))+
      ylab("N")+
      theme(axis.text.y = element_text(colour = "grey60", size = 14),
            axis.title.y = element_text(colour = "grey60", size = 14),
            axis.text.x = element_blank(),
            #axis.text = element_blank(),
            axis.title.x = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.y = element_line( 
              linetype = 'solid',
              colour = "grey95"),
            panel.grid.major.y = element_line(
              linetype = 'solid',
              colour = "grey90"),
            legend.position = "bottom",
            legend.title = element_text(size=20, face="bold"),
            legend.text = element_text(size=18),
            strip.text.x = element_text(angle = 90, face = "bold", size=16))+
      scale_fill_manual(name = "AE Severity Grade",
                        breaks = c("1", "2", "3", "4", "5"),
                        values = c("#99CCFF", "#00CCFF", "#0099FF", "#0066FF", "Black"),
                        na.translate = F,
                        drop = FALSE)+
      geom_hline(yintercept = 0, size=0.5, linetype=1, alpha=1)
  }
}
