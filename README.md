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
install.packages("shiny")
shiny::runGitHub("RPath", "benhid", subdir = "R/")
```
