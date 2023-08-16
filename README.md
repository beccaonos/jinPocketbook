# Justice in Numbers Pocketbook R Package

The **Justice in Numbers Pocketbook** R package provides a set of functions to build documents containing various charts, tables, and summary information taken from the Justice in Numbers website. 

## Installation

You can install the package directly from GitHub using the `devtools` package:

```R
# Install devtools if not already installed
install.packages("devtools")

# Install the Justice in Numbers Pocketbook package from GitHub
devtools::install_github("moj-analytical-services/jinPocketbook")
```

## Getting Started

To get started, load the package and run the main function: `build_jin_document(doc_type)`. You must specify a `doc_type` of either "pocketbook" or "summary_tables". This function will build the Justice in Numbers Pocketbook or Summary Tables document and then save it to the default S3 bucket location - 'alpha-jin-pocketbook'.

```R
# Load the Justice in Numbers Pocketbook package
library(jinPocketbook)

# Build the Justice in Numbers Pocketbook
build_jin_document("pocketbook")

# Build the Justice in Numbers Summary Tables
build_jin_document("summary_tables")
```

By default, the `build_jin_document()` function will fetch the latest data from the Justice in Numbers API online. However, you can also specify the root path and file extension for the API files if you want to test the package using locally downloaded JSON files. 

### Deprecated Officer functions

The package has a dependency on the `officer` package and uses the function `slip_in_text()` which has been deprecated in later versions of the package. See issue [here](https://github.com/moj-analytical-services/jinPocketbook/issues/2#issue-1853095607). Users with later versions of officer may receive an error to this effect. If you receive this error, you will need to roll back your installed version of officer using the below code using `renv`:

```R
renv::install("officer@0.3.4", rebuild = TRUE)
```

## Package Functions

The **Justice in Numbers Pocketbook** package has only one function available to the user:

**`build_jin_document()`**: This is the main function that builds the entire Justice in Numbers Pocketbook or Summary Tables document and saves it. By default it will download data from the Justice in Numbers API, use it to generate the relevant document, then save it to the default S3 bucket location with the filename `JiN_Pocketbook_yyyy_mm_dd.docx` or `JiN_Summary_Tables_yyyy_mm_dd.docx`, with the date set on the day the package is run. It will overwrite any existing file with the same name.

This function has one required argument:

- `doc_type`: This accepts either the values "pocketbook" or "summary_tables". This instructs the function which of the two Justice in Numbers documents to produce.

Among the other arguments, you will usually only want to use defaults, but the function does accept the following arguments, which will generally only be used for testing or development purposes:

 - `rootpath` (Default is "https://data.justice.gov.uk"): This sets the root where the package will look for the API files. You should only change this if you are carrying out testing on the API and want to download the JSON files manually and run the Pocketbook offline. In this case, you should change this to the local folder where you've stored the downloaded JSON files. You will need to replicate the API structure within the offline folder structure you create for this to work.

- `ext` (Default is ""): This is used in conjunction with rootpath when running the package using downloaded offline files. You should change this to "JSON" if you want to run the Pocketbook using downloaded files.

 - `targetpath` (Default is "alpha-jin-pocketbook"): This is the folder where you want to save the generated DOCX file. It can be a S3 bucket or a local folder. This folder must contain the sub-folders "Pocketbook" and "Summary" as the files will be saved to one of these subfolders, depending on which of the document types is being run.
 
 - `S3target` (Default is TRUE): If `targetpath` is a S3 bucket, this should be TRUE. If it is a local folder, it should be FALSE.
 
 - `change_check` (Default is FALSE): This can only be TRUE if `S3target` is also TRUE. If TRUE, the package will check whether the generated document is the same as the most recent document in the target S3 bucket and subfolder. If it is, then it won't be saved. This means that the function will only save a new file to the bucket if there has been a change to the underlying data. It is assumed that this will only need to be changed to TRUE as part of an automated scheduled production process to avoid the destination folder becoming full of identical documents.

## Additional Notes

- The `build_jin_document()` function may take some time to run, particularly where the `change_check` argument is used.

- The package is designed to work with the latest data from the Justice in Numbers website. Make sure to have an internet connection when running the `build_jin_document()` function.

- For advanced users, some internal functions are available in the package. However, it is recommended to only use the main function `build_jin_document()` for building the complete pocketbook.

- The pocketbook will be saved as a Word document with a filename reflecting the current date.

## Developer Notes

Some components of the underlying code are hard-coded. This may need to be changed in future if the structure of Justice in Numbers or the Pocketbook is changed:

 - 'Economic costs of crime' is the only measure that does not have trend information and there therefore isn't a trend chart on Justice Data from which to take figures from the API. As a result, this row of the summary table is hard-coded into the file `R/summary_table.R`. Once a trend measure is created within the API, this hard coding will need to be removed and the values will be picked up from the API.

 - The script that checks for changes in the Pocketbook file currently ignores two paragraphs which contain the date of publication. This avoids the change check seeing a change in the publication just because it had been run on a different date. These are currently on rows 5 and 8 for the Pocketbook and rows 1 and 2 for the Summary Tables in the body text summary table generated by the code. If the Pocketbook structure is edited in future so that these paragraphs are moved, this will need updating in `R/build_jin_document.R` 

## License

This package is distributed under the MIT License. See the `LICENSE` file for more details.

## Acknowledgments

The **Justice in Numbers Pocketbook** package was developed by [Phil Hall](https://github.com/phil-hall-moj) and is part of a larger project related to the Justice in Numbers website.

If you have any questions, suggestions, or issues related to the package, please feel free to [open an issue](https://github.com/moj-analytical-services/jinPocketbook/issues) on GitHub.

