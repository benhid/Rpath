<p align="center">
  <img src=resources/logo_small.png alt="RPath">
</p>

# RPath: A Web-App for Biologic Pathway Exploration

RPath is a web application for the end-to-end manipulation of biologic pathways. Its divided in three modules: built-in search engine via the [Pathway Commons](http://www.pathwaycommons.org/)' API, analysis techniques using SPARQL queries and graph visualization.

## Download

To download RPath just clone the Git repository hosted in GitHub:

```sh
$ git clone https://github.com/benhid/rpath.git
```

## Prerequisites

* R 3.4

Launching [RPath](R/app.R) will install any missing packages.

## Usage

To start up the app download the source code, then go to the `R` folder and run the `app.R` file.

Or by just running one command:

```R
# install.packages("shiny")
shiny::runGitHub("RPath", "benhid", subdir = "R/")
```

## Using Docker

It's possible to run the web-app inside a Docker container. First, build the image from the [Dockerfile](Dockerfile):

```sh
sudo docker build -t khaosresearch/rpath .
```

e.g.

```sh
sudo docker run -it -p 3838:3838 khaosresearch/rpath
```

## Custom modules

Every module in RPath is listed on the [modules](R/modules) folder. Each of them contains at least two files: `<module_name>.R` and `<module_name>Panel.R`. The first one will be used on the server-side of the app. The other one defines the user interface.

In order to RPath to load a new module, edit the file [modules.R](R/modules/modules.R) to insert the name of the module:

```R
# Modules to be loaded.
# Each module must consists of one directory with two files: 
#     ./R/modules/<module_name>
#       |-- <module_name>.R
#       '-- <module_name>Panel.R.
modules.tabs <- c("search", "data_summary", "visualization", "user_manual")

# Modules to be disabled until search is perform.
# This list consists of the values of the tab panels.
#     e.g. tabPanel("Visualization", value = "visTab", ...)
modules.hidden.tabs <- c("analysisTab", "visTab")
```

After that, to get the URL from the selected pathway of the search process, use:

```R
URL <- getRowFromDf()
```
