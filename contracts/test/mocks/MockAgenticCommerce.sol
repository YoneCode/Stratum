// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAgenticCommerce} from "../../src/interfaces/IAgenticCommerce.sol";

/// @notice Minimal mock of the ERC-8183 reference impl, exposing only the surface
///         that `StratumJobFactory` actually consumes (`getJob`). Tests seed jobs
///         via `setJob` and assert behaviour against the factory.
/// @dev    Intentionally does NOT implement the full IAgenticCommerce interface —
///         the factory address-casts a raw address into IAgenticCommerce, and
///         Solidity dispatches by selector at the call site, so unused selectors
///         on the mock would only matter if the factory ever calls them.
contract MockAgenticCommerce {
    mapping(uint256 jobId => IAgenticCommerce.Job) private _jobs;

    function setJob(uint256 jobId, IAgenticCommerce.Job memory job) external {
        _jobs[jobId] = job;
    }

    function getJob(uint256 jobId) external view returns (IAgenticCommerce.Job memory) {
        return _jobs[jobId];
    }
}
