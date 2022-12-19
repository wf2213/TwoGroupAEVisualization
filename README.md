# Two-Group Adverse Event Type Visualization <img src="https://user-images.githubusercontent.com/75338470/207113593-46e66aff-74f6-43fc-b543-a9cd736c6cc3.png" align="right" width="100"/>


#### :wave: Hi, there

This file provides the code for adverse event (AE) type visualization Shiny app designed to visually compare adverse event types and categories between two treatment arms (add Shiny app link).

With the code, you will be able to:

* Generate the same graphs as in the Shiny app
* Customize the graphs 
* Adapt the code for other visualization settings. For example, this app can also be used to visualize **AE resolution**. An example of how to prepare the data will be provided at the end of this document.

*The AE data set is randomly generated with code in file `GenerateSampleData.R` for illustration purpose and may not medically make sense.*

## Usage

For an illustration example, you can download the sample datasets from the **Sample Data** file and follow the steps below.

1. Import the ID and AE datasets in R
2. Run the `PrepareInputDataset.R` to generate the datasets needed for the functions to plot graphs (*df_pt_cat* when the data is summarized by AE category, *df_pt_ae* when the data is summarized by AE type)
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
 * To visualize the data summarized on the **AE type level**, the two functions below display the count or proportion of maximal grade of AEs for each patient by severity for each **AE type** and allow the visual comparison of AEs across treatment arms by mirroring the data across a central axis either **vertically** or **hotizontally**. The bars are sorted (in descending order) based on the frequency of the events by AE category – and then by AE term within AE category – in one arm.
    * `TypeVerticalBar.R`
    * `TypeHorizontalBar.R` 
 * Similarly, to visualize the data summarized on the **AE category level**, the two functions below display the count or proportion of maximal grade of AEs by severity for each **AE category** between two arms either **vertically** or **hotizontally**.
    * `CatVerticalBar.R`
    * `CatHorizontalBar.R`
 * Another way to visualize the data summarized on the **AE category level** is to use the circular plots below to display the count or proportion of maximal grade of AEs by severity for each **AE category**. The treatment arms can be displayed **side by side within the same circular plot** for each **AE category** using different color schemes.  Alternatively, the information can be displayed using **two circular plots side by side** with the exact same position for the AE categories using the same color.
    * `CatCombinedCircular.R`
    * `CatSeparateCircular.R`

4. Specify the following function to create the correponding plots. 

```
TypeVerticalBar(df_pt_ae, tox_include)
```
![Maximum Toxicity Type 2022-12-15 (1)](https://user-images.githubusercontent.com/75338470/207946361-1d1a67c8-d461-41e4-813e-ef1e74381cdd.png)

 ```
 TypeHorizontalBar(df_pt_ae, tox_include)
 ```
![Maximum Toxicity Type 2022-12-15](https://user-images.githubusercontent.com/75338470/207946385-641b62a2-7d5d-42e4-b4a0-ec79b2f196ae.png)

```
CatVerticalBar(df_pt_cat, tox_include)
```
![Maximum Toxicity Category 2022-12-15 (1)](https://user-images.githubusercontent.com/75338470/207946265-1fd56140-dfe0-4f05-ab99-5851015d0ea7.png)

```
CatHorizontalBar(df_pt_cat, tox_include)
```
![Maximum Toxicity Category 2022-12-15](https://user-images.githubusercontent.com/75338470/207946317-9775329e-9075-4a5e-88d9-f242d02e1326.png)

```
CatCombinedCircular(df_pt_cat, tox_include)
```
![Maximum Toxicity Category 2022-12-15 (3)](https://user-images.githubusercontent.com/75338470/207946142-f534fbff-a17d-442b-a7ff-7bacf4d1c42e.png)

```
CatSeparateCircular(df_pt_cat, tox_include)
```
![Maximum Toxicity Category 2022-12-15 (2)](https://user-images.githubusercontent.com/75338470/207946215-7ae24d3f-d050-4c61-bcfb-0dee113bbfd2.png)

## Other Visualization Using Code

For example, to use this app for visualizing AE resolution data (whether the AE is resolved or not by the end of the trial), you can use the following code for the data processing before running `PrepareInputDataset.R`. This code assumes that all the unresolved AEs are carried forward until the last cycle and are indicated with *AEONGOING = 1*

```
# CYCLE is the number of cycle in which the AE happens
# AEONGOING is the indicator for whether the AE is resolved in the cycle (1 = ongoing, 0 = resolved)
ae = ae %>%
  group_by(PATNO) %>%
  summarise(MAX_CYCLE = max(CYCLE)) %>%
  select(PATNO, MAX_CYCLE) %>%
  merge(ae) %>%
  filter(CYCLE == MAX_CYCLE,
         AEONGOING == 1)
```

A processed AE resolution sample data based on the sample AE data is in **Sample Data** file.

An example of the plot generated with the AE resolution data is shown below:
![AE_resolution_exmaple](https://user-images.githubusercontent.com/75338470/208353381-badb2810-0bd2-452e-a430-0d2cf84b81e1.png)
