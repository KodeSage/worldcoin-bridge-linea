// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { WorldIDBridge } from "world-id-state-bridge/abstract/WorldIDBridge.sol";

import { IOpWorldID } from "world-id-state-bridge/interfaces/IOpWorldID.sol";
import { CrossDomainOwnable3 } from "@eth-optimism/contracts-bedrock/contracts/L2/CrossDomainOwnable3.sol";

/// @title Linea World ID Bridge
/// @author Worldcoin
/// @notice A contract that manages the root history of the Semaphore identity merkle tree on
///         Linea.
/// @dev This contract is deployed on Linea and is called by the L1 Proxy contract for each new
///      root insertion.
contract LineaWorldID is WorldIDBridge, CrossDomainOwnable3, IOpWorldID {
    ///////////////////////////////////////////////////////////////////////////////
    ///                                CONSTRUCTION                             ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Initializes the contract the depth of the associated merkle tree.
    ///
    /// @param _treeDepth The depth of the WorldID Semaphore merkle tree.
    constructor(uint8 _treeDepth) WorldIDBridge(_treeDepth) { }

    ///////////////////////////////////////////////////////////////////////////////
    ///                               ROOT MIRRORING                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice This function is called by the state bridge contract when it forwards a new root to
    ///         the bridged WorldID.
    /// @dev    This function can revert if Optimism's CrossDomainMessenger stops processing proofs
    ///         or if OPLabs stops submitting them. Next iteration of Optimism's cross-domain messaging, will be
    ///         fully permissionless for message-passing, so this will not be an issue.
    ///         Sequencer needs to include changes to the CrossDomainMessenger contract on L1,
    ///         not economically penalized if messages are not included, however the fraud prover (Cannon)
    ///          can force the sequencer to include it.
    ///
    /// @param newRoot The value of the new root.
    ///
    /// @custom:reverts CannotOverwriteRoot If the root already exists in the root history.
    /// @custom:reverts string If the caller is not the owner.
    function receiveRoot(uint256 newRoot) external virtual onlyOwner {
        _receiveRoot(newRoot);
    }

    ///////////////////////////////////////////////////////////////////////////////
    ///                              DATA MANAGEMENT                            ///
    ///////////////////////////////////////////////////////////////////////////////

    /// @notice Sets the amount of time it takes for a root in the root history to expire.
    ///
    /// @param expiryTime The new amount of time it takes for a root to expire.
    ///
    /// @custom:reverts string If the caller is not the owner.
    function setRootHistoryExpiry(uint256 expiryTime) public virtual override onlyOwner {
        _setRootHistoryExpiry(expiryTime);
    }
}
