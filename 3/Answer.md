# Homework 3

### 2

The verify tx function return false on invalid proofs. I tried both tampered Proof and Input values, both are not valid.

ALso, I tried to verify a proof working with other circuit (square root of 16), that's not verifiable on this circuit also.

### 4

I generated a zk-proof to prove with the specified address as first input. Then, as the balance in EVM chain is 256 bits, I split it into two 128 bits values and used them as second and third inputs.

```rust
def main(field address, field balance1, field balance2) {
    assert(address == 1); // Suppose the address is 0x0000000000000000000000000000000000000001
    assert(balance1 > 0 || balance2 > 1000000000000000000);
    return;
}
```

I supposed address(1) has a balance of 2 ether, and generated a proof for it. Then, I followed the zokrates tutorial and exported the verifier contract in verifier.sol, but applied some changes to it. Instead of getting whole the verify input elementes from the caller/user, I only got the first one as the address and filled the second and third with the balance of the address(1) in the EVM chain.

````solidity
    function verifyTx(
            Proof memory proof, uint[1] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](3);

        for(uint i = 0; i < 1; i++){
            inputValues[i] = input[i];
        }

        uint256 balance = address(1).balance;

        uint128 balanceHigh = uint128(balance >> 128);
        uint128 balanceLow = uint128(balance);
        inputValues[1] = balanceHigh;
        inputValues[2] = balanceLow;

        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }

````

I was able to verify my proof, with modified input values as stated above.

<img width="1088" alt="image" src="https://github.com/aminlatifi/zk-bootcamp-homework/assets/5684607/d6d71898-95d0-4b3d-b3f7-fe795dffc521">

