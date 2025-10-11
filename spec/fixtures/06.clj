; %% [markdown]
; # Check if a string is a palindrome in Clojure

; %%
(defn palindrome? [s]
  (= (seq s) (reverse s)))

; %%
(palindrome? "racecar")
(palindrome? "hello")
