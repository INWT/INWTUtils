# This script contains an example to test the checkStyle function.
f1 <- function(x = 3, y) NULL # function_argument_linter
a = 2 # assignment_linter
b <- c(a,2) # commas_linter
c <-  1:5 # double_space_linter
d # A comment with double  whitespace to check the double_space_linter
f2 <- function(vec) 2*vec # infix_spaces_linter
z <- 3 * a + b # A very long line with more than one hundred characters to check the line_length_linter
veryLongVariableNameExceeding30Characters <- 0 # object_length_linter
INWTUtils:::scriptLinters() # internal_function_linter
if(x == 1) 2
# trailing_blank_lines_linter:

