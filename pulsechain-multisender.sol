// SPDX-License-Identifier: NONE
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IDTX {
	function governor() external view returns (address);
}

interface IGovernor {
	function treasuryWallet() external view returns (address);
}

contract MultiSender {
    uint256 public constant FEE = 1e18;
    address public immutable DTX;
    address public treasury;

    constructor(address _dtx, address _buybackContract) {
        DTX = _dtx;
        treasury = _treasury;
    }

    function massNative(address[] calldata _address, uint256[] calldata _amount) external payable {
		uint256 _quantity = _address.length;
        require(_quantity == _amount.length, "addresses array mismatches amounts");
        payable(treasury).transfer(FEE * _quantity);
		
		for(uint i=0; i < _quantity; i++) {
            payable(_address[i]).transfer(_amount[i]);
        }
	}

    function massERC20(address tokenAddress, address[] calldata _address, uint256[] calldata _amount) external payable {
		uint256 _quantity = _address.length;
        require(_quantity == _amount.length, "addresses array mismatches amounts");
        payable(treasury).transfer(FEE * _quantity);
		
		for(uint i=0; i < _quantity; i++) {
            require(IERC20(tokenAddress).transferFrom(msg.sender, _address[i], _amount[i]));
        }
	}

    function massERC721(address tokenAddress, address[] calldata _address, uint256[] calldata _tokenIds) external payable {
		uint256 _quantity = _address.length;
        require(_quantity == _tokenIds.length, "addresses array mismatches tokenIds");
        payable(treasury).transfer(FEE * _quantity);
		
		for(uint i=0; i < _quantity; i++) {
            IERC721(tokenAddress).safeTransferFrom(msg.sender, _address[i], _tokenIds[i]);
        }
	}

    function updateTreasury(address _newTreasury) external {
    	require(msg.sender == governor(), "decentralized voting only");
        treasury = _newTreasury;
    }

	function governor() public view returns (address) {
		return IDTX(DTX).governor();
	}

  	function treasuryAddress() public view returns (address) {
		return IGovernor(governor()).treasuryWallet();
	}
}
