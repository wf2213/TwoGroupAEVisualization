#  Two-Group AE Visualization <img src="https://user-images.githubusercontent.com/75338470/207113593-46e66aff-74f6-43fc-b543-a9cd736c6cc3.png" align="right" width="100" />


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
  ![circular2](https://user-images.githubusercontent.com/75338470/207113250-0c52e6aa-3a70-422c-bfb5-6e4ab52e2053.png)
  
* `CatHorizontalBar.R` , `CatVerticalBar.R` , `CatCombinedCircular.R` and `CatSeparateCircular.R` contain functions that can only be used to visualize AE data summarized on the category level. To use the functions to plot the graphs, you need to specify:
  * circular3(df_pt_cat, tox_include)
  ![circular3](https://user-images.githubusercontent.com/75338470/207113278-a5c3bb7d-2dc6-47ee-8991-94b6a617015c.png)

  * circular4(df_pt_cat, tox_include)
  ![circular4](https://user-images.githubusercontent.com/75338470/207113293-c80a7688-4ef8-4d4f-ac0c-b526d96a8aa8.png)

  * circular5(df_pt_cat, tox_include)
  ![circular5](https://user-images.githubusercontent.com/75338470/207113330-fb78f6eb-9247-4d3c-bb54-ee63d9672759.png)

  * circular6(df_pt_cat, tox_include)
![circular6](https://user-images.githubusercontent.com/75338470/207113352-da0c9dca-a58e-4e10-9ff9-97bfdcaa84fb.png)
