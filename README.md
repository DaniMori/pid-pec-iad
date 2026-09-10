
- [Repository `pid-pec-iad`](#repository-pid-pec-iad)
- [License](#license)
  - [Attributions](#attributions)
- [Project installation](#project-installation)
  - [Software components](#software-components)
  - [Installing the project locally](#installing-the-project-locally)
  - [Restoring the environment](#restoring-the-environment)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Running the app](#running-the-app)
  - [Deploying the “Data Download” app to Posit Connect
    Cloud](#deploy-dd)

# Repository `pid-pec-iad`

Repository for “Teaching innovation project 2025” at UNED. It consists
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
  4.6.1](https://cran.rstudio.com/bin/windows/base/old/4.6.1/): In
  Windows, using the [binary
  installer](https://cran.rstudio.com/bin/windows/base/old/4.6.1/R-4.6.1-win.exe)
  is recommended.

<!-- -->

- [Rstudio Desktop](https://posit.co/download/rstudio-desktop/):
  Although not strictly necessary, it is recommended to install the
  Rstudio IDE; for strict reproducibility, use build [2026.08.2+200 for
  Windows
  10/11](https://download1.rstudio.org/electron/windows/RStudio-2026.08.2-200.exe).

<!-- -->

- [Quarto publishing system](https://quarto.org/): An additional
  component used by Rstudio to generate and publish literate computing
  outputs. For strict reproducibility please use build 1.9.38; On
  Windows, use [the 64-bit
  installer](https://github.com/quarto-dev/quarto-cli/releases/download/v1.9.38/quarto-1.9.38-win.msi).

<!-- -->

- [Git client](https://git-scm.com/download): Install the Git client in
  order to be able to clone locally the project repository. On Windows,
  use [the 64-bit Windows
  installer](https://github.com/git-for-windows/git/releases/download/v2.53.0.windows.1/Git-2.53.0-64-bit.exe).

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
deploy it to [Posit Connect Cloud](https://connect.posit.cloud) so that
students can access it.

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

The Shiny app can be run locally in Rstudio from the file
[“data-download.R”](data-download.R). When it is active in the text
editor, the “Source” dropdown menu that appears in the upper toolbar for
scripts and computable documents turns into a “Run App” menu. To make
sure the complete functionality of the app is working, it is better to
run it on a web browser. Instead of just clicking on this button, click
on the right-side down arrow and make sure the option “Run External”
(instead of “Run in Window” or “Run in Viewer Pane”) is selected; then
click on “Run App”.

### Testing the data download

To test the app functionality, go to the URL bar and add e.g.
“?<email=johndoe@psi.uned.es>” after the app URL (which should look like
“<https://localhost>:<XXXX>”, being `<XXXX>`), and type `ENTER`. For
example, if the URL is

    https://localhost:1111

test the functionality (data downloading) by browsing to

    https://localhost:1111?email=johndoe@psi.uned.es

## Deploying the “Data Download” app to [Posit Connect Cloud](https://connect.posit.cloud)

<div class="callout-important">

### Deploying the app in “Production” vs. “Test” mode

When the app is already deployed to [Connect
Cloud](https://connect.posit.cloud) and running, in order to avoid a
collision (which would affect the app usage by the students), a “test
account” must be used in [Connect Cloud](https://connect.posit.cloud).
For example, with email address “<johndoe@psi.uned.es>”, create account
“john-does-test” in [Connect Cloud](https://connect.posit.cloud).

Consider the account associated with email address
“<iad.uned.psi@gmail.com>” to be the “production” account”. Then, decide
beforehand whether you will follow these instructions using the
“production account” (when the app is not deployed and needs to be set
up for usage within the “PEC”) or the alternative “test account” (when
the app is already deployed and running, and the “PEC” is being
completed by the students during the course).

</div>

1.  Log in to [Connect Cloud](https://connect.posit.cloud) using the
    email associated with the account (production/test) that you will
    use. If necessary, follow the steps to create a new account. (If
    using the “production account”, log in with email address
    “<iad.uned.psi@gmail.com>”, authenticating with Google.)

2.  In Rstudio, click on the menu “Tools” -\> “Global Options…”, and
    section “Publishing”.

3.  Click on “Connect…”, then on “Posit Connect Cloud” and “Connect
    Account”. This will open an authorizatin page in the default web
    browser.

4.  The page in the browser will show a pane titled “Authorize Access”,
    with an 8-character alphanumeric code. After reading the
    information, click on “Continue”, and then on “Authorize”. If the
    authorization is successful, the page will show now an “Access
    Authorized” message. Close the browser tab or window.

5.  Return to Rstudio. The “Options” window will now show the [Connect
    Cloud](https://connect.posit.cloud) account under “Publishing
    Accounts”. Click on “Ok” to close the “Options” window.

6.  Open the script
    [“src/deploy_data_download.R”](src/deploy_data_download.R) in
    Rstudio, and run it by clicking on the “Source” button (upper right
    corner in the editor).

7.  After the message “Preparing for deployment”, the console will
    prompt to “Enter the publication account:”. Enter the account name
    for [Connect Cloud](https://connect.posit.cloud), then press
    `ENTER`.

<div class="callout-tip">

Prompting for the publication account every time is an intentional
design decision, to avoid hardcoding the account in the code and
preventing its exposure (it is not clear whether it can be a security
issue, but just in case).

When trying to deploy and redeploy the app several times, it may be
tiresome and frustrating having to type in the account every time. To
avoid this, the deployment script
[“src/deploy_data_download.R”](src/deploy_data_download.R) can be edited
to manually add the account name (between lines 27 and 28), therefore
skipping the “prompt” step:

``` r
...

deploy_app(
  account = "iad-psi-uned",
  main      = APP_MAIN,
...
```

<div class="callout-warning">

Important! If you do add this line, **do NOT commit** the change to git.
Instead, revert the change when you have finished deploying the app.

</div>

8.  The console will output several messages informing of the progress
    of the deployment process.

<div class="callout-information">

If the deployment has been tried before and the app already existed (and
has been deleted) in [Connect Cloud](https://connect.posit.cloud), at a
certain point the console may inform that it “Failed to find existing
content on server”, and prompt to choose “What do you want to do?”.

If this happens, chose option “2: Delete existing deployment record &
deploy this content as a new item”, by typing on the console `2` and
then pressing `ENTER`.

</div>

    If the deployment is successful, the console will output a message similar to

    ```
    ── Deployment complete ──────────────────────────────────────────────────────────────────────
    ✔ Successfully deployed to <https://connect.posit.cloud/<account-name>/content/019f65b7-492a-8cfa-a453-340a6b9d5bd5>
    ```

with `<account-name>` being the publishing account introduced in step 7.
A tab will open in the default browser, navigating to a preview of the
app in [Connect Cloud](https://connect.posit.cloud).

<div class="callout-information">

The Operating System may pop up a Window requesting to grant access to R
through the firewall. If this is the case, click on “Grant access”
(“Permitir” or similar).

</div>

9.  In the app preview, click on the “Settings” button, click on “URL”,
    and activate “Customize your URL”. In “Custom name” will be
    automatically filled in with “data-download-app”; leave it as is (or
    fill it in with that value, otherwise), and click on “Republish”.

10. In the app preview, click on the “Copy Link” button. Open a new
    browser tab and paste in the URL of the app. It will be similar to

`https://<account-name>-data-download-app.share.connect.posit.cloud/`

with `<account-name>` being the publishing account introduced in step 7.

11. Check that the app is running properly: The previous URL will not
    work because the “email” GET parameter is missing from the URL, so
    to test it, add an “email” GET parameter at the end, e.g.:

`https://<account-name>-data-download-app.share.connect.posit.cloud/?email=johndoe@psi.uned.es`

<div class="callout-tip">

It is highly recommended that you use your own email at the
“@\*.uned.es” domain.

</div>

If the app works properly, a dataset should be downloaded, either
automatically and/or by clicking on the link to download it manually. It
should also be checked that the new entries (for “Access” and
“Download”) are logged in the Google Spreadsheet file.

## Deploying the “Feedback” app to [Posit Connect Cloud](https://connect.posit.cloud)

Deploying the “Feedback” app to [Connect
Cloud](https://connect.posit.cloud) follows a similar procedure as
described above for [deploying the “Data Download” app](#deploy-dd). The
only changes that need to be made to that procedure for the “Feedback”
app are:

**Steps 6 and 7:** Use script
[“src/deploy_feedback.R”](src/deploy_feedback.R) instead of
[“src/deploy_data_download.R”](src/deploy_data_download.R).

**Steps 9 through 11:** Use the value “feedback-app” instead of
“data-download-app” in the textbox “Custom name”, to customize the URL
of the app. This URL will then be similar to

`https://<account-name>-feedback-app.share.connect.posit.cloud/`

with `<account-name>` being the publishing account introduced in step 7.

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

</div>
