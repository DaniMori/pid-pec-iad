
# Repository `pid-pec-iad`

Repository for “Teaching innovation project 2025” at UEND. It consists
of:

- A Shiny Application for generating personalized student datasets

- A feedback app

- A correction notebook to generate the compensation grades

# License

This project is licensed under the [Creative Commons Attribution 4.0
International license](https://creativecommons.org/licenses/by/4.0/).
Please see the [license file](LICENSE.md).

## Attributions

This project makes use of the
[rproj-template](https://github.com/DaniMori/rproj-template) Github
template created by [Daniel Morillo](https://github.com/DaniMori) and
licensed under the [Creative Commons Attribution 4.0 International
license](https://creativecommons.org/licenses/by/4.0/).

# Project installation

## Software components

Start by installing the following software components:

- [R version
  4.4.1](https://cran.rstudio.com/bin/windows/base/old/4.4.1/): In
  Windows, using the [binary
  installer](https://cran.rstudio.com/bin/windows/base/old/4.4.1/R-4.4.1-win.exe)
  is recommended.

<!-- -->

- [Rstudio Desktop](https://posit.co/download/rstudio-desktop/):
  Although not strictly necessary, it is recommended to install the
  Rstudio IDE; for strict reproducibility, use build [2025.09.1+401 for
  Windows
  10/11](https://download1.rstudio.org/electron/windows/RStudio-2025.09.1-401.exe).

<!-- -->

- [Quarto publishing system](https://quarto.org/): An additional
  component used by Rstudio to generate and publish literate computing
  outputs. For strict reproducibility please use build 1.7.32; On
  Windows, use [the 64-bit
  installer](https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.32/quarto-1.7.32-win.msi).

<!-- -->

- [Git client](https://git-scm.com/download): Install the Git client in
  order to be able to clone locally the project repository. On Windows,
  use [the 64-bit Windows
  installer](https://github.com/git-for-windows/git/releases/download/v2.51.0.windows.1/Git-2.51.0-64-bit.exe).

## Installing the project locally

This project is hosted as a GitHub repository. It can be cloned as a
local Git repository following [these
instructions](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2)
(steps 2 through 7). Note that this will create a local copy of
(‘clone’) the GitHub repository as an Rstudio project in the folder
specified. The URL that must be entered into the `Repository URL` text
box is:

    https://github.com/DaniMori/pid-pec-iad.git

**IMPORTANT:** It is totally unrecommended to clone a git repository
inside a cloud storage folder (e.g., Dropbox, OneDrive). Please note
that GitHub serves the purpose of backing up the repository, so no cloud
storage is necessary. Similarly, cloning the repository in a network
folder may cause problems with the `renv` environment (see below); do it
at your own risk!

After cloning the repository, the Rstudio project will open
automatically in the Rstudio IDE. If it doesn’t, or you want to return
later to the project in Rstudio, you can do so by double clicking on the
file `rstudio_project.Rproj` that has been created in the project folder
when cloning the repository.

**NOTE:** It is common practice to avoid using and versioning
`.Rprofile` files. However, this project uses [package
`renv`](https://cran.r-project.org/package=renv) to create a
reproducible environment, which needs the `.Rprofile` file that lives in
the root directory of the project. **Please DO NOT delete or edit this
file**; it will install and activate the `renv` package and make it
ready for restoring the environment.

## Restoring the environment

The reproducible environment created by `renv` must be restored to
install all the packages this project needs to be built properly. If
`renv` does not initialize automatically (check the console for messages
about this), you will need to manually install the package first:

``` r
install.packages("renv")
```

Once it is successfully installed, use the “renv” -\> “Restore library…”
button in Rstudio’s “Packages” tab to restore the environment.
Alternatively, you can type in the console:

``` r
renv::restore()
```

# Usage

The main purpose of this repository is to create a Shiny app that
generates the personalized synthetic dataset for each student enrolled
in the course. In order to do this, we must configure first the Shiny
app; then we can run it locally to test its functionality, and finally
deploy it to [shinyapps.io](https://www.shinyapps.io/) so that students
can access it.

## Configuration

Before trying to run it, the Google Spreadsheets connection must be set
up. Follow the instructions in document [“Google Spreadsheets connection
instructions”](doc/gs_instructions.qmd) to do this.

## Running the app

The Shiny app can be run locally in Rstudio from any of the two files
that make up the Shiny app: [“ui.R”](ui.R) for the interface, and
[“server.R”](server.R) for the server logic. When any of the two is
active in the text editor, the “Source” button that appears in the upper
toolbar for scripts and computable documents turns into a “Run App”
button. To make sure the complete functionality of the app is working,
it is better to run it in a new window. Instead of just clicking on this
button, click on the right-side down arrow and make sure the options
“Run in Window”, instead of “Run in Vewer Pane”, is selected; then click
on “Run App”.

## Deploying the app to [shinyapps.io](https://www.shinyapps.io/)

<!-- # TODO: Complete -->

# Repository structure

The file structure of this repository is as follows:

    pid-pec-iad
    |
    |- server.R (Shiny app server logic)
    |
    |- ui.R     (Shiny app user interface)
    |
    |--- apps   (To store apps, e.g. in Shiny)
    |
    |--- dat    (To store input datasets; must NEVER be checked-in to Github)
    |
    |--- doc    (To store important documentation of the project)
    |
    |--- R      (R functions created for this project live here)
    |
    |--- renv   (System library necesssary for `renv` to work. DON'T TOUCH)
    |
    |--- src    (Source scripts that implement the main processes)
    |
    |--- www    (Project assets, e.g., images, bibliography files, etc.)

Use the folders as indicated to store the different files and generate
the outputs of the processes.
