
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
  installer](https://github.com/git-for-windows/git/releases/download/v2.51.2.windows.1/Git-2.51.2-64-bit.exe).

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

Once the connection is set up, a new Google Spreadsheets file needs to
be created as the storage backend for the Shiny App. In order to do
this, follow these instructions:

1.  Log in to Google Drive with the account “<iad.uned.psi@gmail.com>”.

2.  Create a new Google Spreadsheets file (ideally inside the folder
    “PID-IAD”), and give it a meaningful name (e.g. “pid-iad-data”).

3.  Copy its file ID from the direction bar: This is the alphanumeric
    code between “<https://docs.google.com/spreadsheets/d/>” and the
    last slash (“/”). DO NOT include any of the two slashes.

4.  Open file “doc/ghseets_config_template.yml”, and save it as
    “doc/gsheets_config.yml”.

5.  Paste the copied file ID into line 3 of “doc/gsheets_config.yml”,
    between the double quotes, and omitting the “caret” (\<\>)
    characters; e.g.: if the URL in the direction bar is
    `https://docs.google.com/spreadsheets/d/19oPSRB2S2HIL2BW87VB5rAEHXJCSYqxCQZZKzhciRqw/edit?gid=0#gid=0`,
    then line 3 of “doc/gsheets_config.yml” must be

    `file_id: "19oPSRB2S2HIL2BW87VB5rAEHXJCSYqxCQZZKzhciRqw"`

6.  Save the changes to “doc/gsheets_config.yml”.

## Running the app

The Shiny app can be run locally in Rstudio from any of the two files
that make up the Shiny app: [“ui.R”](ui.R) for the interface, and
[“server.R”](server.R) for the server logic. When any of the two is
active in the text editor, the “Source” button that appears in the upper
toolbar for scripts and computable documents turns into a “Run App”
button. To make sure the complete functionality of the app is working,
it is better to run it in a new window. Instead of just clicking on this
button, click on the right-side down arrow and make sure the options
“Run in Window”, instead of “Run in Viewer Pane”, is selected; then
click on “Run App”.

## Deploying the app to [shinyapps.io](https://www.shinyapps.io/)

<div class="callout-important">

### Deploying the app in “Production” vs. “Test” mode

When the app is already deployed to
[shinyapps.io](https://www.shinyapps.io/) and running, in order to avoid
a collision (which would affect the app usage by the students), a “test
account” must be used in [shinyapps.io](https://www.shinyapps.io/). For
example, with email address “<johndoe@psi.uned.es>”, create account
“john-does-test” in [shinyapps.io](https://www.shinyapps.io/).

Consider the account “iad-psi-uned-es”, associated with email address
“<iad.uned.psi@gmail.com>”, to be the “production” account”. Then,
decide beforehand whether you will follow these instructions using the
“production account” (when the app is not deployed and needs to be set
up for usage within the “PEC”) or the alternative “test account” (when
the app is already deployed and running, and the “PEC” is being
completed by the students during the course).

</div>

1.  Log in to [shinyapps.io](https://www.shinyapps.io/) using the email
    associated with the account (production/test) that you will use. If
    necessary, follow the steps to create a new account. (If using the
    “production account”, log in with email address
    “<iad.uned.psi@gmail.com>”, authenticating with Google.)

2.  In the [shinyapps.io
    dashboard](https://www.shinyapps.io/admin/#/dashboard), click on the
    avatar (upper-right corner) and then on “Tokens” in the dropdown
    menu to go to the “Tokens” tab.

3.  A token will be already created for this account, so you only need
    to authorize it in your local Rstudio session. Click on the “Show”
    button; a window will pop-up. Click on “Show secret”, and then on
    “Copy to clipboard”. On the message window, type “CTRL + C” to copy
    the R code with the authorization token, and then “Accept” to close
    the message window, and “Ok” to close the pop-up window.

4.  Paste the copied R code into the Rstudio console and type “ENTER” to
    run it and authorize the app on your local Rstudio session.
    **IMPORTANT:** This will leave a trace of the authorization token in
    your Rstudio history; at this point, make sure you go to the
    “History” tab and delete the last entry, by selecting it and
    clicking on the “Remove the selected history entries” button
    (“document with a red X” icon), or by clicking on the “Clear all
    history entries” (“broom” icon).

5.  Open either the [“ui.R”](ui.R) or [“server.R”](server.R) file in the
    Rstudio editor. Then click on the “Publish” button; select the
    corresponding account on [shinyapps.io](https://www.shinyapps.io)
    (i.e., “iad-psi-uned-es” if using the “production account”, the
    “test account” you created if using it), and enter the app title
    (“pid-pec-iad”) in the “Title” text box. Finally, **select
    carefully** ALL OF and ONLY the following files and folders:

    - .Renviron
    - .secrets/encrypted-oauth-token-rds
    - doc/gsheets_config.yml
    - R/constants.R
    - R/data_storage.R
    - R/hash_emails.R
    - R/log.R
    - R/simulated_data.R
    - renv.lock
    - server.R
    - ui.R

<div class="callout-caution">

Make sure to select the previous files and only those. There must be
exactly 11 files checkboxed.

</div>

6.  Click on “Publish”. The “Deploy” tab will open, printing out several
    messages. If the deployment is successful, the tab will ultimately
    output a message with the URL where the app is deployed. If using
    the “production account”, it will be:

    `Deployment completed: https://iad-psi-uned-es.shinyapps.io/pid-pec-iad/`

    If using the “test account”, it will match

    `Deployment completed: https://<test-account>.shinyapps.io/pid-pec-iad/`

    The “Deploy” tab will automatically close while a tab will open in
    the default browser, navigating to the URL of the app (the one in
    the message above).

7.  Check that the app is running properly: The previous URL will not
    work because the “email” GET parameter is missing from the URL, so
    to test it, first go to the [Applications dashboard in
    shinyapps.io](https://www.shinyapps.io/admin/#/applications/all) and
    check that the app “pid-pec-iad” is listed with Status “Running”.

8.  If the app is running, test the app by browsing to its URL
    (<https://iad-psi-uned-es.shinyapps.io/pid-pec-iad> if using the
    “production account”, something like
    <https://><test-account>.shinyapps.io/pid-pec-iad if using the “test
    account”), and then adding an “email” GET parameter at the end,
    i.e., with the “production account”:

    <https://iad-psi-uned-es.shinyapps.io/pid-pec-iad?email=johndoe@psi.uned.es>\`

    with a “test account”, something like:

    <https://><test-account>.shinyapps.io/<pid-pec-iad?email=johndoe@psi.uned.es>\`

<div class="callout-tip">

It is highly recommended that you use your own email at the
“@\*.uned.es” domain.

</div>

If the app works properly, a dataset should be downloaded automatically
and/or by clicking on the link to download it manually. It should also
be checked that the new entries (for “Access” and “Download”) are logged
in the Google Spreadsheet file.

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
