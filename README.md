# INWTUtils
This repository contains a package which provides utility functions
used by the INWT Statistics GmbH. This includes amongst others
functions to create a file structure for new projects, to check
code for violations of style conventions and to keep the searchpath
clean. In addition, an example R script is included.


# Creating a file structure for a new project

When you start a new project in R, you usually first need a particular file
structure.
This includes certain folders, maybe the structure for an R package including
some basic tests, and several configuration files (e.g., a .gitignore).
You could create this structure from scratch every time, or copy it from an
existing project (followed by deleting all the unnecessary files from the old
project and realizing that you still did not catch the latest version of some
file). An easier way is to do it with the function `createProjectSkeleton()`
from the `INWTUtils` package.


## 1 Usage of `createProjectSkeleton`

`createProjectSkeleton` goes into action in the very beginning of a new project:
You still have nothing or maybe an existing empty folder and you need a complete
file structure as sketched above.
If you wish, you can add a package infrastructure and/or an .Rproject file.
The latter two can also be done separately (see sections 2 and 3).


### Calling `createProjectSkeleton` with default values

Using the function with just the default values will create the following
file structure in your current working directory (which would in this case be 
named *myfolder*):



![Fig. 1: File structure created by `createProjectSkeleton` with default values.](vignettes/skeleton_01default.PNG)

The purposes of the folders are mostly obvious:

- *data*: all data, original or modified, e.g., .Rdata, .csv,
or .xlsx files.
- *reports* will contain R Markdown reports.
- *RScrips* is for your scripts. It already contains an example script to
  demonstrate a useful script structure.

Finally the *myfolder.Rproj* file has been created. It is automatically named 
after the superordinate folder. This .Rproject file is already filled with
useful preferences, e.g. not saving and restoring the R workspace, not saving
the history and inserting spaces for tabs.


### Customizing `createProjectSkeleton`

The resulting file structure can be customized via the following arguments
for `createProjectSkeleton:`

- `dir:` Directory where the file structure should be created (absolute path
  or path relative to the current working directory)
- `pkgName:` If you specify a package name via this argument, a package with
  this name is created in your folder. It already contains the infrastructure
  to use the
  [testthat package](https://journal.r-project.org/archive/2011-1/RJournal_2011-1_Wickham.pdf)
   and a first test for the code style of your package.
- `pkgFolder:` If you pass a folder name via this argument, your package will
  live in this folder, otherwise directly in the project root.
  The former may lead to a better overview in
  your project root and is appropriate for projects whose main scope is not
  package development, e.g., a forecasting project. This also avoids conflicts
  between the *data* folder containing your data to analyse and the *data*
  folder which is part of the package. However if your project's
  purpose is package development, the package should not be moved to a separate
  folder.
  The package infrastructure is created with `create` resp. `setup` from the
  [devtools package](https://cran.r-project.org/web/packages/devtools/devtools.pdf).
- `rProject:` You may already have an .Rproject file and don't want to create a
  new one.
- `exampleScript:` If you don't want an example script in *RScripts*, set this
  argument to `FALSE`.

For example, the following function call would result in the file structure
shown in figure 2:


```r
createProjectSkeleton(dir = "playWith",
                      pkgName = "playPkg",
                      pkgFolder = ".", # Default, could be left out
                      rProject = FALSE,
                      exampleScript = FALSE)
```

![Fig. 2: Another file structure created by `createProjectSkeleton`, this time including a package.](vignettes/skeleton_02otherArgs.PNG)

In addition to the files from figure 1, you can see the package infrastructure
in the project directory:

- The folder *R* for R files containing the package functions
- A folder *tests* (already containing one test)
- An *.Rbuildignore*: This file specifies files to be ignored when building the
  package. It includes *.Rproj* files, *.Rproj.user* folders, and *RScripts*.
- The *DESCRIPTION* file contains your package name and the imports 
  lintr (for the test) and INWTUtils. All other information must be
  added by hand, e.g., your name and email adress.
- The *NAMESPACE* file.

Of course, the *RScripts* folder does not contain the example script,
and there is no *.Rproj* file in this case.
  

## 2 Creating only the package with `createPackage`

`createPackage()` is generally called inside `createProjectSkeleton`.
It can also be called directly, for example if you want to add a package to an
existing project with an existing file structure. Similar to
`createProjectSkeleton`, it receives argument for the project directory, the
package name and the package folder (in case the package should live in a
separate folder).
In addition to `devtools::create` or `devtools::setup` this method already
provides a test for the code style, the appropriate *.Rbuildignore* and imports
in the *DESCRIPTION* file.


## 3 Creating only the R project with `createProject`
`createProject()` writes an *.Rproject* file with useful configurations. You can
specifiy if the project contains a package (logical argument `pkg`), the folder
where the package lives (argument `pkgFolder`), and, of course, the directory
where the .Rproject file is created (argument `dir`).


# Checking code style with INWTUtils

## Overview

This vignette describes how to check your code files for a good style
with `checkStyle` (a wrapper for the `lint` function of the
`lintr` package). The function is tailored to the usage at the INWT Statistics
company but can by applied in other contexts without any disadvantages.

For several so-called *lints* the function checks if they appear in the code.
In this context, lints are (mostly small) violations of style rules, e.g.,
missing spaces around operators, double spaces, very long lines or trailing
blank lines.
A function checking a specific lint is called linter function.
The section "Included linters" gives more information about the set of tested lints. 


## Why should you watch your style?

Your code may be robust and fast in spite of a bad style. But a good style
makes your code more beautiful and easier to read -- especially for others.
Adapting a consistent style within a team helps to find your way around in the code
written by someone else.

It's never to late to adapt a good coding style -- and never to early.


## How to use `checkStyle`

`checkStyle` can be applied to one or more files. If you don't add any other
argument, the default set of linters is used as returned by the function
`selectLinters`. To demonstrate the usage, we first create two files with
examples for bad style:




```r
writeLines(c("# This is an example for bad style",
             "x = 1+2",
             "# A comment with  double  spaces",
             ""),
           con = "badStyle1.R")
writeLines(c("# This is a second example   ",
             "z<-c(1,2)"),
           con = "badStyle2.R")
```

How many violations of common style conventions do you see? `checkStyle` may
find some more:


```r
checkStyle(files = c("badStyle1.R", "badStyle2.R"))
```

A new tab opens in RStudio which lists all lints found in the checked files.
It contains the full filepaths and a list with line numbers and
lints for each file. You can start to edit the code and repeat the check
until the opened tab remains empty.

![Output produced by `checkStyle`: For each file you see the full path and a 
list of style rule violations (vignettes/lints).](vignettes/style_01checkStyleOutput.PNG)


If you want to customize the set of used linters, there are
three possibilities:

- Specify a file type with the `type` argument
- Exclude linters with the `excludeLinters` argument
- Add more linters with the `addLinters` argument

These arguments are passed to `selectLinters` and change the set of linters that
the function returns.

Specifying a file type via the `type` argument adds some linters to the set of
used linters.
You can choose between scripts (`type = "script"`) or files with package 
functions (`type = "pkgFuns"`). Or you can just ignore the argument.

`excludeLinters` just needs a vector or list with names of the linters you want
to exclude.
`addLinters` needs a bit more: a named vector or named list of linters. How you
choose the exact names doesn't play a role, but the values have to be linter
functions from an attached package.

For example:


```r
checkStyle(files = c("badStyle1.R", "badStyle2.R"),
           type = "script",
           excludeLinters = c("object_length_linter",
                              "function_argument_linter"),
           addLinters = list(setwd_linter = setwd_linter,
                             a = source_linter))
```


## Included linters

The following linters are used by default:

- function_argument_linter

- assignment_linter

- commas_linter

- double_space_linter

- infix_spaces_linter

- internal_function_linter

- line_length_linter

- no_tab_linter

- object_length_linter

- sapply_linter

- spaces_left_parentheses_linter

- trailing_blank_lines_linter

- trailing_whitespaces_linter

If `type = "script"`, no linters are added at the moment.



If `type = "pkgFuns"`, the following linters are added:

- setwd_linter

- source_linter

- options_linter

The following linters stem from the `INWTUtils` package:

`function_argument_linter` checks if arguments without default value
are listed before arguments with default value in function definitions.

`double_space_linter` checks for double empty spaces.

`internal_function_linter` checks for the use of internal functions via `:::`. 
There is usually a reason why an internal function has not been exported. It
has probably not been tested properly outside the context it is used in.

`setwd_linter`, `source_linter`, and `options_linter` check for `setwd`,
`source` resp. `options` statements because they can cause side effects when
used in functions.

`trailing_whitespaces_linter` looks for superfluous whitespaces at the end of
a line. [^a]

The remaining linters are taken from the `lintr` package.
Details can be found via
[`?lintr::linters`](https://rdrr.io/cran/lintr/man/linters.html).


## Exclude lines from checking

Sometimes you may want to exclude specific lines from the check because the
found lint cannot be removed for some reason. You achieve this by adding the
`nolint` commands into the file to be checked (see also 
[`?lintr::exclude`](https://rdrr.io/cran/lintr/man/exclude.html)):


```r
# nolint start
x <- c(1,2) # This line will be excluded from the checks
# nolint end
y <- c(3, 4) # This line won't be excluded anymore.
```





[^a]: This linter is very similar to `trailing_whitespace_linter` from the
`lintr` package, but it takes a special case into account: If you insert the
pipe operator `%>%` from the [dplyr package](https://cran.r-project.org/web/packages/dplyr/vignettes/introduction.html)
using the shortcut `Ctrl` + `Shift` + `m`, a whitespace is inserted behind it
per default. These whitespaces are not detected by `trailing_whitespaces_linter`
because it would lead to many annoying alarms.
