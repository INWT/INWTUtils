# This script contains functions with correct or incorrect argument order
# (arguments without default should be listed first). It is used to test
# function_argument_linter().


### Functions with incorrect argument order (args with default first)

# 2 arguments
f <- function(x=1,
              y) {
  x + y
}
f <- function(x = "aString",
              y) {paste(x, y)}
f <- function(x = TRUE,
              y) x * y

# 3 arguments
f <- function(x = 'astring',
              y, z) {
  paste(x, y, z)
}
f <- function(arg_1, y = TRUE,
              z)
  max(arg_1, y, z)
f <- function(x = 1,
              y,
              z = 'astring'){rep(z, times = x + y)}
f <- function(x = TRUE, arg.2 = 123,
              z) NULL

# dots
f <- function(x = TRUE,
              y, ...) x * y



### Functions with correct argument order (args without default first)

# 1 argument
f <- function(x) {
  2 * x
}
f <- function(x = 1) {2 * 1 + 5}

# 2 arguments
f <- function(x, y) {
  x + y
}
f <- function(x, y) {x + y}
f <- function(x = 2, y = 'aString') paste(x, y)
f <- function(x = "aString", y = TRUE)
  if (y)
    x
f <- function(x, y = TRUE)
  x * y

# 3 arguments
f <- function(x,
              y,
              z = 2) {
  x + y + z
}
f <- function(x, y = 1, z = 2)
{
  x + y + z
}

# dots
f <- function(x = 1, y = 2, ...) x + y
f <- function(x = 1,
              y = 2,
              ...) x + y
f <- function(x, y = 1,
              ...) {
  mean(x, y, ...)
}
f <- function(x = TRUE,
              ...) {
  if (x) print("YES", ...)
}

# Use of other functions
paste(x = c("Hello", "world"), " ")
f <- function(x, y) {
  mean(x = x, y)
}
