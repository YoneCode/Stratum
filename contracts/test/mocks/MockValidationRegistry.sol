// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @notice Mock Validation Registry that records calls for test assertions.
contract MockValidationRegistry {
    struct ResponseCall {
        bytes32 requestHash;
        uint8 response;
        string responseURI;
        bytes32 responseHash;
        string tag;
    }

    ResponseCall[] public calls;

    function validationResponse(
        bytes32 requestHash,
        uint8 response,
        string calldata responseURI,
        bytes32 responseHash,
        string calldata tag
    ) external {
        calls.push(ResponseCall(requestHash, response, responseURI, responseHash, tag));
    }

    function callCount() external view returns (uint256) { return calls.length; }

    function lastCall() external view returns (ResponseCall memory) {
        return calls[calls.length - 1];
    }
}
