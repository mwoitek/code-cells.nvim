# %%
import random


# %%
def greet(name):
    return f"Hello, {name}!"


# %%
x = [random.randint(1, 100) for _ in range(5)]
y = sum(x)


# %%
class Dummy:
    def __init__(self, value):
        self.value = value


# %%
for i in range(3):
    print(greet(f"User{i}"), Dummy(i).value)
