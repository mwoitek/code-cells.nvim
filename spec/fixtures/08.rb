# %% [markdown]
# # Fibonacci numbers in Ruby

# %%
def fibonacci(n)
  return n if n <= 1
  fibonacci(n - 1) + fibonacci(n - 2)
end

# %%
fibonacci(10)
