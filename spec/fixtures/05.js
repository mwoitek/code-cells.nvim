// %% [markdown]
// Matrix multiplication in JavaScript

// %%
function matrixMultiply(A, B) {
    const result = [];
    for (let i = 0; i < A.length; i++) {
        result[i] = [];
        for (let j = 0; j < B[0].length; j++) {
            result[i][j] = 0;
            for (let k = 0; k < A[0].length; k++) {
                result[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    return result;
}

// %%
let A = [
    [1, 2],
    [3, 4]
];
let B = [
    [5, 6],
    [7, 8]
];
console.log(matrixMultiply(A, B));
