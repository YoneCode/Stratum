// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {IReputationRegistry} from "../../src/interfaces/IReputationRegistry.sol";

/// @notice Mock Reputation Registry that records calls for test assertions.
contract MockReputationRegistry {
    struct FeedbackCall {
        uint256 agentId;
        int128 value;
        uint8 valueDecimals;
        string tag1;
    }

    FeedbackCall[] public calls;

    function giveFeedback(
        uint256 agentId,
        int128 value,
        uint8 valueDecimals,
        string calldata tag1,
        string calldata,
        string calldata,
        string calldata,
        bytes32
    ) external {
        calls.push(FeedbackCall(agentId, value, valueDecimals, tag1));
    }

    function callCount() external view returns (uint256) {
        return calls.length;
    }

    function lastCall() external view returns (FeedbackCall memory) {
        return calls[calls.length - 1];
    }
}
