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

# Proxy settings
#Sys.setenv(http_proxy="")