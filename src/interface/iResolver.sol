// SPDX-License-Identifier: WTFPL.ETH
pragma solidity >0.8.0 <0.9.0;
interface iOverloadResolver {
    function addr(bytes32 node, uint256 coinType)
        external
        view
        returns (bytes memory);
}

interface iResolver {
    function contenthash(bytes32 node) external view returns (bytes memory);
    function addr(bytes32 node) external view returns (address payable);
    function pubkey(bytes32 node)
        external
        view
        returns (bytes32 x, bytes32 y);
    function text(bytes32 node, string calldata key)
        external
        view
        returns (string memory);
    function name(bytes32 node) external view returns (string memory);
}
