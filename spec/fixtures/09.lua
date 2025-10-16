-- %% [markdown]
-- # Vector dot product

-- %%
local function dot_product(a, b)
  local sum = 0
  for i = 1, #a do
    sum = sum + a[i] * b[i]
  end
  return sum
end

-- %%
local v1 = { 1, 2, 3 }
local v2 = { 4, 5, 6 }
print(dot_product(v1, v2))

-- %% [markdown]
-- # Matrix multiplication

-- %%
local function mat_mul(A, B)
  local n, m, p = #A, #B, #B[1]
  local C = {}
  for i = 1, n do
    C[i] = {}
    for j = 1, p do
      local sum = 0
      for k = 1, m do
        sum = sum + A[i][k] * B[k][j]
      end
      C[i][j] = sum
    end
  end
  return C
end

-- %%
local A = { { 1, 2 }, { 3, 4 } }
local B = { { 5, 6 }, { 7, 8 } }
local C = mat_mul(A, B)
for i = 1, #C do
  print(unpack(C[i]))
end

-- %% [markdown]
-- # Matrix transpose

-- %%
local function transpose(M)
  local n, m = #M, #M[1]
  local T = {}
  for i = 1, m do
    T[i] = {}
    for j = 1, n do
      T[i][j] = M[j][i]
    end
  end
  return T
end

-- %%
local M = { { 1, 2, 3 }, { 4, 5, 6 } }
local T = transpose(M)
for i = 1, #T do
  print(unpack(T[i]))
end
