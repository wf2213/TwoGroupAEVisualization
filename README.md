#  Two-Group AE Visualization <img src="app_Visualization.png" align="right" width="100" />

#### :wave: Hi, there

This file can help you to get started with using the codes for adverse event visualization from the Shiny app designed to visually compare adverse event profiles between two groups (link). 


With the codes, you will be able to:

* Generate the same graphs as in the Shiny app
* Customize the graphs
* Adapt the codes for other visualization settings

For an illustration example, you can download the sample datasets from the **Sample Data** file. To generate any graph, you need to:

* First import the ID and AE dataset in R
* Run the `CreateDataset.R` to generate the datasets needed for the functions to plot graphs (*df_pt_cat* when the data is summarized by AE category, *df_pt_ae* when the data is summarized by AE type)
  * If you are using your own datasets, make sure that you change the variable names accordingly to the same names as in the sample datasets
  * The file contains variables you need to specify, including:
    * Attribution level you would like to include for the analysis
    * Toxicity grade you would like to include for the analysis
    * Category you would like to exclude for the analysis
    * How you would like the data to be summarized ("Maximum Toxicity Type" or "Maximum Toxicity Category")
    * Treatment arm you would like to be used to sort all the plots
    * Whether you would like to plot count or percent
    * Whether you would like to use abbreviation for the categories in the plots
* `TypeHorizontalBar.R` and `TypeVerticalBar.R` contain functions that can only be used to visualize AE data summarized on the AE type level. To use the functions to plot the graphs, you need to specify:
  * circular1(df_pt_ae, tox_include)
  ![circular1](https://user-images.githubusercontent.com/75338470/207113050-5ed348e4-ffa5-40fb-95f5-9712f4023f35.png)

  * circular2(df_pt_ae, tox_include)
* `CatHorizontalBar.R` , `CatVerticalBar.R` , `CatCombinedCircular.R` and `CatSeparateCircular.R` contain functions that can only be used to visualize AE data summarized on the category level. To use the functions to plot the graphs, you need to specify:
  * circular3(df_pt_cat, tox_include)
  * circular4(df_pt_cat, tox_include)
  * circular5(df_pt_cat, tox_include)
  * circular6(df_pt_cat, tox_include)
