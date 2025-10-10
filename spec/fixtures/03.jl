# %% [markdown]
# # Quicksort in Julia

# %%
function quicksort(arr)
    if length(arr) <= 1
        return arr
    end
    pivot = arr[1]
    less = filter(x -> x < pivot, arr[2:end])
    greater = filter(x -> x > pivot, arr[2:end])
    return vcat(quicksort(less), pivot, quicksort(greater))
end

# %%
arr = [7, 3, 1, 9, 4, 6]
quicksort(arr)
