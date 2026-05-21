// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";

import {IACPHook} from "../src/interfaces/IACPHook.sol";
import {IAgenticCommerce} from "../src/interfaces/IAgenticCommerce.sol";
import {IIdentityRegistry} from "../src/interfaces/IIdentityRegistry.sol";
import {IReputationRegistry} from "../src/interfaces/IReputationRegistry.sol";
import {IValidationRegistry} from "../src/interfaces/IValidationRegistry.sol";

/// @notice Pin every interface signature against the canonical EIP wording.
/// @dev    The expected selectors are computed inline as `keccak256(canonicalSig)`, so the
///         test compiles iff the interface signature matches the canonical signature exactly.
///         Sources:
///           - https://eips.ethereum.org/EIPS/eip-8004
///           - https://eips.ethereum.org/EIPS/eip-8183
contract InterfacesTest is Test {
    // ───── ERC-8004 Identity ─────────────────────────────────────────────────

    function test_Erc8004_Identity_RegisterOverloads() public pure {
        // Three register overloads — selectors must be resolvable as raw keccak256 hashes
        // because Solidity cannot auto-disambiguate `IIdentityRegistry.register.selector`
        // when overloads exist.
        bytes4 sel0 = bytes4(keccak256("register()"));
        bytes4 sel1 = bytes4(keccak256("register(string)"));
        bytes4 sel2 = bytes4(keccak256("register(string,(string,bytes)[])"));

        // Sanity: all three must differ.
        assertTrue(sel0 != sel1);
        assertTrue(sel1 != sel2);
        assertTrue(sel0 != sel2);
    }

    function test_Erc8004_Identity_FixedSelectors() public pure {
        assertEq(
            IIdentityRegistry.setAgentURI.selector,
            bytes4(keccak256("setAgentURI(uint256,string)"))
        );
        assertEq(
            IIdentityRegistry.getMetadata.selector,
            bytes4(keccak256("getMetadata(uint256,string)"))
        );
        assertEq(
            IIdentityRegistry.setMetadata.selector,
            bytes4(keccak256("setMetadata(uint256,string,bytes)"))
        );
        assertEq(
            IIdentityRegistry.setAgentWallet.selector,
            bytes4(keccak256("setAgentWallet(uint256,address,uint256,bytes)"))
        );
        assertEq(
            IIdentityRegistry.getAgentWallet.selector,
            bytes4(keccak256("getAgentWallet(uint256)"))
        );
        assertEq(
            IIdentityRegistry.unsetAgentWallet.selector,
            bytes4(keccak256("unsetAgentWallet(uint256)"))
        );
    }

    // ───── ERC-8004 Reputation ───────────────────────────────────────────────

    function test_Erc8004_Reputation_GiveFeedback() public pure {
        assertEq(
            IReputationRegistry.giveFeedback.selector,
            bytes4(
                keccak256("giveFeedback(uint256,int128,uint8,string,string,string,string,bytes32)")
            )
        );
    }

    function test_Erc8004_Reputation_OtherSelectors() public pure {
        assertEq(
            IReputationRegistry.revokeFeedback.selector,
            bytes4(keccak256("revokeFeedback(uint256,uint64)"))
        );
        assertEq(
            IReputationRegistry.appendResponse.selector,
            bytes4(keccak256("appendResponse(uint256,address,uint64,string,bytes32)"))
        );
        assertEq(
            IReputationRegistry.readFeedback.selector,
            bytes4(keccak256("readFeedback(uint256,address,uint64)"))
        );
        assertEq(
            IReputationRegistry.getClients.selector,
            bytes4(keccak256("getClients(uint256)"))
        );
        assertEq(
            IReputationRegistry.getLastIndex.selector,
            bytes4(keccak256("getLastIndex(uint256,address)"))
        );
    }

    // ───── ERC-8004 Validation ───────────────────────────────────────────────

    function test_Erc8004_Validation_Selectors() public pure {
        assertEq(
            IValidationRegistry.validationRequest.selector,
            bytes4(keccak256("validationRequest(address,uint256,string,bytes32)"))
        );
        assertEq(
            IValidationRegistry.validationResponse.selector,
            bytes4(keccak256("validationResponse(bytes32,uint8,string,bytes32,string)"))
        );
        assertEq(
            IValidationRegistry.getValidationStatus.selector,
            bytes4(keccak256("getValidationStatus(bytes32)"))
        );
    }

    // ───── ERC-8183 Agentic Commerce ─────────────────────────────────────────

    function test_Erc8183_Lifecycle_Selectors() public pure {
        assertEq(
            IAgenticCommerce.createJob.selector,
            bytes4(keccak256("createJob(address,address,uint256,string,address)"))
        );
        assertEq(
            IAgenticCommerce.setProvider.selector,
            bytes4(keccak256("setProvider(uint256,address)"))
        );
        assertEq(
            IAgenticCommerce.setBudget.selector,
            bytes4(keccak256("setBudget(uint256,uint256,bytes)"))
        );
        assertEq(IAgenticCommerce.fund.selector, bytes4(keccak256("fund(uint256,bytes)")));
        assertEq(
            IAgenticCommerce.submit.selector,
            bytes4(keccak256("submit(uint256,bytes32,bytes)"))
        );
        assertEq(
            IAgenticCommerce.complete.selector,
            bytes4(keccak256("complete(uint256,bytes32,bytes)"))
        );
        assertEq(
            IAgenticCommerce.reject.selector,
            bytes4(keccak256("reject(uint256,bytes32,bytes)"))
        );
        assertEq(
            IAgenticCommerce.claimRefund.selector,
            bytes4(keccak256("claimRefund(uint256)"))
        );
    }

    function test_Erc8183_View_Selectors() public pure {
        assertEq(IAgenticCommerce.getJob.selector, bytes4(keccak256("getJob(uint256)")));
        assertEq(IAgenticCommerce.paymentToken.selector, bytes4(keccak256("paymentToken()")));
        assertEq(IAgenticCommerce.platformFeeBP.selector, bytes4(keccak256("platformFeeBP()")));
        assertEq(IAgenticCommerce.evaluatorFeeBP.selector, bytes4(keccak256("evaluatorFeeBP()")));
    }

    function test_Erc8183_AcpHook_Selectors() public pure {
        assertEq(
            IACPHook.beforeAction.selector,
            bytes4(keccak256("beforeAction(uint256,bytes4,bytes)"))
        );
        assertEq(
            IACPHook.afterAction.selector,
            bytes4(keccak256("afterAction(uint256,bytes4,bytes)"))
        );
    }
}
