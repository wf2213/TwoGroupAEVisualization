#  Two-Group AE Visualization <img src="https://user-images.githubusercontent.com/75338470/207113593-46e66aff-74f6-43fc-b543-a9cd736c6cc3.png" align="right" width="100" />


#### :wave: Hi, there

This file can help you to get started with using the codes for adverse event visualization from the Shiny app designed to visually compare adverse event profiles between two groups (add Shiny App link). 


With the codes, you will be able to:

* Generate the same graphs as in the Shiny app
* Customize the graphs 
* Adapt the codes for other visualization settings

For an illustration example, you can download the sample datasets from the **Sample Data** file and follow the steps below.

*The AE data set is randomly generated for illustration purpose and may not medically make sense.*

## Usage

1. Import the ID and AE datasets in R
2. Run the `CreateDataset.R` to generate the datasets needed for the functions to plot graphs (*df_pt_cat* when the data is summarized by AE category, *df_pt_ae* when the data is summarized by AE type)
  * If you are using your own datasets, make sure that you change the variable names accordingly to the same names as in the sample datasets
  * This file contains the following arguments you need to specify:
    * **attr_include**: Attribution level you would like to include for the analysis
    * **tox_include**: Toxicity grade you would like to include for the analysis
    * **cat_include**: Category you would like to *exclude* for the analysis
    * **group**: How you would like the data to be summarized ("Maximum Toxicity Type" or "Maximum Toxicity Category")
    * **order**: Treatment arm you would like to be used to sort all the plots
    * **type**: Whether you would like to plot count or percent
    * **abbre**: Whether you would like to use abbreviation for the categories in the plots
3. choose plots you would like to generate and run the corresponding R scripts. 

4. Specify the following function to create the correponding plots. 

* `TypeHorizontalBar.R` and `TypeVerticalBar.R` contain functions that can only be used to visualize AE data summarized on the **AE type level**. To use the functions to plot the graphs, you need to specify:
  * TypeVerticalBar(df_pt_ae, tox_include)
![Maximum Toxicity Type 2022-12-15 (1)](https://user-images.githubusercontent.com/75338470/207946361-1d1a67c8-d461-41e4-813e-ef1e74381cdd.png)

  * TypeHorizontalBar(df_pt_ae, tox_include)
  ![Maximum Toxicity Type 2022-12-15](https://user-images.githubusercontent.com/75338470/207946385-641b62a2-7d5d-42e4-b4a0-ec79b2f196ae.png)

* `CatHorizontalBar.R` , `CatVerticalBar.R` , `CatCombinedCircular.R` and `CatSeparateCircular.R` contain functions that can only be used to visualize AE data summarized on the **AE category level**. To use the functions to plot the graphs, you need to specify:
  
  * CatSeparateCircular(df_pt_cat, tox_include)
![Maximum Toxicity Category 2022-12-15 (2)](https://user-images.githubusercontent.com/75338470/207946215-7ae24d3f-d050-4c61-bcfb-0dee113bbfd2.png)

  * CatCombinedCircular(df_pt_cat, tox_include)
![Maximum Toxicity Category 2022-12-15 (3)](https://user-images.githubusercontent.com/75338470/207946142-f534fbff-a17d-442b-a7ff-7bacf4d1c42e.png)

  * CatVerticalBar(df_pt_cat, tox_include)
![Maximum Toxicity Category 2022-12-15 (1)](https://user-images.githubusercontent.com/75338470/207946265-1fd56140-dfe0-4f05-ab99-5851015d0ea7.png)

  * CatHorizontalBar(df_pt_cat, tox_include)
![Maximum Toxicity Category 2022-12-15](https://user-images.githubusercontent.com/75338470/207946317-9775329e-9075-4a5e-88d9-f242d02e1326.png)
