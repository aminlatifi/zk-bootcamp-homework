// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;

library Pairing {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]

    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }
    /// @return the generator of G1

    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2

    function P2() internal pure returns (G2Point memory) {
        return G2Point(
            [
                10857046999023057135944570762232829481370756359578518086990519993285655852781,
                11559732032986387107991004021392285783925812861821192530917403151452391805634
            ],
            [
                8495653923123431417604973247489272438418190587263600148770280649306958101930,
                4082367875863433681332203403145435568316851327593401208105741076214120093531
            ]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.

    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint256 q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        }
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1

    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }
        require(success);
    }

    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }
        require(success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success
            case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.

    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)
        internal
        view
        returns (bool)
    {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.

    function pairingProd3(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.

    function pairingProd4(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }

    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(
            uint256(0x238eb19778f7f1a0cb3278738437b08baaa16240b11fffca59912ba437e147ea),
            uint256(0x1cd8dc9fc02cb27d2117eabb244d4c7ed0e1edf90d06777aa1bd75dec826c47e)
        );
        vk.beta = Pairing.G2Point(
            [
                uint256(0x140958fe75171ccee4b3fe1a22de9bba331963b1e025640fe490413adc1f8b63),
                uint256(0x10ad40a1329761dc08bdcd89f9596e6c330b3d8f96d5ad3e71dcab2e6f6fda67)
            ],
            [
                uint256(0x2523ae18ffe32d21a8fc7b9ae31c8408d3298c7ddc8209ac6ef94bbb0ae103b7),
                uint256(0x0f54607e0c1a203cb51f273de4d807c2c12a8fb8cdc041f9bfc261ab0ff6ba29)
            ]
        );
        vk.gamma = Pairing.G2Point(
            [
                uint256(0x2c07bdc561357fc5f2a536e97fcbd2b374f4366862e3e8e72449b4f7b8d58907),
                uint256(0x23ddc51f697fb8ecd9bb7e99d63cee60a8e6503f2080f4f13bdadd107bd2ec12)
            ],
            [
                uint256(0x10ba1e481bc3461d223e123bcd7178a951ee82e67ff79f99d85338a4fcaf4640),
                uint256(0x22292dd58e92b0fb7a15f1829c67df0838337e839f8d7620030c0d08f94c8aab)
            ]
        );
        vk.delta = Pairing.G2Point(
            [
                uint256(0x033602d1fb495b97b352fbb7f8af897f584ebb92e8d4f33d5665bd483d2283d8),
                uint256(0x113395bfa6545510c093a8b7d4d1279f721ca1a53386fd281cf8b1c8511fdf2f)
            ],
            [
                uint256(0x2dc23b70b4e591a1b989242f5df342624483135c84a3c0df5e0281827c19b86d),
                uint256(0x01fd0ab7fe7a3503397439715846368ab89f4f6fdfc57835cd9ee0c921f18250)
            ]
        );
        vk.gamma_abc = new Pairing.G1Point[](4);
        vk.gamma_abc[0] = Pairing.G1Point(
            uint256(0x12a3c4a51e2081ef7b93ef834f8baf6e751e14c2b130459d10be3e0e4a086922),
            uint256(0x0ac437e6a6f87f63a99f07fbb895eb56981c894fe989251e2a63646d4b3a7743)
        );
        vk.gamma_abc[1] = Pairing.G1Point(
            uint256(0x0f207a8b27ef4cefa6f2529287c3d5014eac0f1703498c4b00e5a73231c5c108),
            uint256(0x306171982a816c80552c1c99a9c2b3b97dbfea8a7747b956e53f1fe295fb3f0a)
        );
        vk.gamma_abc[2] = Pairing.G1Point(
            uint256(0x030e56b6ea6728f6449058a503d72214131e93501e0d37c403b148453387a99a),
            uint256(0x2e99161de6d1edbcab749577aa7e9ac36a48ccdc2b44c8655ef506a764c02fe6)
        );
        vk.gamma_abc[3] = Pairing.G1Point(
            uint256(0x12c8d0093169bcc3b9f2c782f941df964d21aa162d1fbd42adf4af210f983607),
            uint256(0x23960647ec1796e2c7e8996f14f002c909fd5f4330875998611e8a3c5a8ff9c5)
        );
    }

    function verify(uint256[] memory input, Proof memory proof) internal view returns (uint256) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if (
            !Pairing.pairingProd4(
                proof.a,
                proof.b,
                Pairing.negate(vk_x),
                vk.gamma,
                Pairing.negate(proof.c),
                vk.delta,
                Pairing.negate(vk.alpha),
                vk.beta
            )
        ) return 1;
        return 0;
    }

    function getBalanceAddress(address _address) public view returns (uint256) {
        uint256 balance = _address.balance;
        return balance;
    }

    function sendEthTo(address _address) public payable {
        (bool success,) = _address.call{value: msg.value}("");
        require(success);
        return;
    }

    function verifyTx(Proof memory proof, uint256[1] memory input) public view returns (bool r) {
        uint256[] memory inputValues = new uint256[](3);

        for (uint256 i = 0; i < 1; i++) {
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
}
