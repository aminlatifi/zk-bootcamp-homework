# Homework 1

### 1

a) Yes, it's true. The group {0, 1, 2, 3, 4, 5, 6,7} is a finite field group mode 8. The odd squares mod 8 are:

$$
    1^2 \mod 8 = 1 \newline
    3^2 \mod 8 = 1 \newline
    5^2 \mod 8 = 1 \newline
    7^2 \mod 8 = 1
$$

Any number bigger than 7 can be reduced to a number between 0 and 7 by taking the remainder of the division by 8. So, the odd squares mod 8 are 1.

b) Even numbers square have different results. The even numbers are: 0, 2, 4, 6. The squares are:

$$
    0^2 \mod 8 = 0 \newline
    2^2 \mod 8 = 4 \newline
    4^2 \mod 8 = 0 \newline
    6^2 \mod 8 = 4
$$

So they can be 0 or 4.

### 2

a) O(n) means that the time or space complexity of an algorithm groth linearly with the size of the input. In other words, if the input size is doubled, the required resources will almost double.
b) O(1) means the complexity of the algorithm is constant and independent of the input size.
c) O(log n) means the complexity of the algotithm grows logarithmically with the input size. For example, if the input size squared, the required resouces would increase by 2 or a constant factor.

### For a proof size, which of these would you want ?

Definitely O(1). It's the best case scenario. It means that the algorithm will always take the same amount of time to run, regardless of the input size. Also, it's the desirable case for verifying on chain by a smart contract.
