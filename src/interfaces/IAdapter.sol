// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAdapter {
    /**
     * @dev Returns a textual description of the adapter.
     * @return The description of the adapter as a string.
     */
    function kind() external view returns (string memory);

    /**
     * @dev Returns the address of the asset that the adapter supports.
     * @return The address of the asset.
     */
    function asset() external view returns (address);

    /**
     * @dev Returns the address of the LP token obtained by deploying to the external protocol.
     * @return The address of the LP token.
     */
    function lpToken() external view returns (address);

    /**
     * @dev Returns the portfolio balance of the specified address.
     * @param target The address whose balance is being queried.
     * @return The balance of the target address.
     */
    function balance(address target) external view returns (uint256);

    /**
     * @dev Allocates or deallocates assets in the external protocol.
     * @param amount The amount to allocate (positive) or deallocate (negative).
     * @param data Additional data needed for the operation.
     */
    function manage(int256 amount, bytes memory data) external;

    /**
     * @dev Returns addresses of any extra tokens received as rewards.
     * @return An array of addresses of tokens.
     */
    function withExtraRewards() external view returns (address[] memory);

    /**
     * @dev Allows to sweep extra rewards manually
     * @return An array of amounts obtained for each token swept
     */
    function sweepExtraRewards(address[] memory) external view returns (uint256[] memory);
}
