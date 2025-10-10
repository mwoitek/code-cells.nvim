# %% [markdown]
# # Binary search in R

# %%
binary_search <- function(arr, target) {
  low <- 1
  high <- length(arr)

  while (low <= high) {
    mid <- floor((low + high) / 2)
    if (arr[mid] == target) {
      return(mid)
    } else if (arr[mid] < target) {
      low <- mid + 1
    } else {
      high <- mid - 1
    }
  }

  return(-1)
}

# %%
arr <- c(1, 3, 5, 7, 9, 11, 13)
target <- 7
binary_search(arr, target)
