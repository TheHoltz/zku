// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract MerkleTree {
    bytes32[] public leaves;
    bytes32 public root;

    // event to be fired when a new root is calculated
    event RootChanged(bytes32 newRoot);

    // internal function to change root
    function _setRoot(bytes32 newRoot) internal {
        root = newRoot;
        emit RootChanged(newRoot);
    }

    // function to add leave and recalculate root
    function addLeave(bytes32 newLeave) public {
        leaves.push(newLeave);

        if (leaves.length % 2 != 0) {
            leaves.push(bytes32(0));
        }

        _setRoot(_computeRoot(leaves));
    }

    // compute root of Merkle tree
    function _computeRoot(bytes32[] memory _transactions)
        internal
        pure
        returns (bytes32)
    {
        // if there is only one element, return it
        if (_transactions.length == 1) {
            return _transactions[0];
        }

        uint256 nextLevel = _transactions.length / 2;
        bytes32[] memory left = new bytes32[](nextLevel);
        bytes32[] memory right = new bytes32[](nextLevel);

        for (uint256 i = 0; i < nextLevel; i++) {
            left[i] = _transactions[i * 2];
            right[i] = _transactions[i * 2 + 1];
        }

        return
            keccak256(
                abi.encodePacked(_computeRoot(left), _computeRoot(right))
            );
    }
}
