# generate id dataset
set.seed(1234)
sample_id = data.frame(
  PATNO = 1:40,
  TRNO = sample(c(rep("A", 20), rep("B", 20)), replace = F))

# generate ae data
TOX_CAT_data = matrix(c("Gastrointestinal disorders", "Abdominal pain",
                        "Renal and urinary disorders", "Acute kidney injury",
                        "Endocrine disorders", "Adrenal insufficiency",
                        "Psychiatric disorders", "Agitation",
                        "Investigations", "Alkaline phosphatase increased",
                        "Skin and subcutaneous tissue disorders", "Alopecia",
                        "Investigations", "ALT increased",
                        "Blood and lymphatic system disorders", "Anemia",
                        "Metabolism and nutrition disorders", "Anorexia",
                        "Psychiatric disorders", "Anxiety",
                        "Cardiac disorders", "Aortic valve disease",
                        "Musculoskeletal and connective tissue disorders", "Arthralgia",
                        "Musculoskeletal and connective tissue disorders", "Arthritis",
                        "Investigations", "AST increased",
                        "Immune system disorders", "Autoimmune disorder",
                        "Cardiac disorders", "AV block complete",
                        "Musculoskeletal and connective tissue disorders", "Back pain",
                        "Investigations", "Blood bilirubin increased",
                        "Investigations", "Blood corticotrophin decreased",
                        "Blood and lymphatic system disorders", "Blood/lymph disorder-Other",
                        "Eye disorders", "Blurred vision",
                        "Musculoskeletal and connective tissue disorders", "Bone pain",
                        "Respiratory, thoracic and mediastinal disorders", "Bronchopulmonary hemorrhage",
                        "Injury, poisoning and procedural complications", "Bruising",
                        "Cardiac disorders", "Cardiac arrest",
                        "Cardiac disorders", "Cardiac disorder-Other, spec",
                        "Investigations", "Cardiac troponin I increased",
                        "Infections and infestations", "Catheter related infection",
                        "Musculoskeletal and connective tissue disorders", "Chest wall pain",
                        "General disorders and administration site conditions", "Chills"),
                      byrow = T, ncol = 2) %>% as.data.frame()
names(TOX_CAT_data) = c("CTC_CAT", "TOXLABEL")

set.seed(1234)
sample_ae = data.frame(
  PATNO = sample(c(1:40), replace = T, 400),
  CYCLE = sample(1:5, replace = T, 400),
  TOXLABEL = sample(
    c("Abdominal pain", "Acute kidney injury",
      "Adrenal insufficiency", "Agitation",
      "Alkaline phosphatase increased",
      "Alopecia", "ALT increased", "Anemia",
      "Anorexia", "Anxiety", "Aortic valve disease",
      "Arthralgia", "Arthritis", "AST increased",
      "Autoimmune disorder", "AV block complete",
      "Back pain", "Blood bilirubin increased",
      "Blood corticotrophin decreased",
      "Blood/lymph disorder-Other",
      "Blurred vision", "Bone pain", "Bronchopulmonary hemorrhage",
      "Bruising", "Cardiac arrest", "Cardiac disorder-Other, spec",
      "Cardiac troponin I increased", "Catheter related infection",
      "Chest wall pain", "Chills"),
    replace = T, 400),
  TOXDEG = sample(c(1:5), 
                  prob = c(0.6, 0.20, 0.13, 0.05, 0.02),
                  replace = T, 400),
  TXATT = sample(c("Yes", "No"), 
                 prob = c(0.7, 0.3),
                 replace = T, 400)) %>%
  merge(TOX_CAT_data, by = "TOXLABEL") %>%
  select(PATNO, CYCLE, CTC_CAT, TOXLABEL, TOXDEG, TXATT)

# assign ongoing ae indicator
sample_ae = sample_ae %>%
  mutate(AEONGOING = ifelse(CYCLE == 5, 1, 0))
  
