// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./verifier.sol";

contract CardGame is Verifier {
    function playSameSuiteCard(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[2] memory input
    ) public view returns (bool) {
        require(verifyProof(a, b, c, input), "Those cards are not same suite!");

        return true;
    }
}
