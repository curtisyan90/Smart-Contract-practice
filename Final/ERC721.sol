// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract ERC721{
    // Interface ID
    bytes4 private constant INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 private constant INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    // Contract owner
    address contractOwner;

    // Mapping from token ID to URI
    mapping (uint256 => string) private _URIs;
    
    // Mapping interface supported or not
    mapping(bytes4 => bool) private supportedInterfaces;

    // Token supply
    uint32 _supply = 0;

    // Token max supply
    uint32 _max = 3;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        contractOwner = msg.sender;
        _name = name_;
        _symbol = symbol_;

        registerInterface(INTERFACE_ID_ERC165);
        registerInterface(INTERFACE_ID_ERC721);
        registerInterface(INTERFACE_ID_ERC721_METADATA);
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "not owner");
        _;
    }


/*-------- Asset --------*/

    // Get owner's tokens
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    // Get token's owner
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }


/*-------- Metadata --------*/

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI,"/",toString(tokenId),".json"));
    }

    function _baseURI() internal pure returns (string memory) {
        return ""; // Add base URI here
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _URIs[tokenId] = _tokenURI;
    }

    function maxSupply() public view returns (uint32) {
        return _max;
    }

    function totalSupply() public view returns (uint32) {
        return _supply;
    }


/*-------- ERC721 --------*/

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not token owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    // Get token's operator
    function getApproved(uint256 tokenId) public view returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }

    // Approve all token to operator
    function setApprovalForAll(address operator, bool approved) public {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    // Check operator has been approved or not
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // Transfer after check permission
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner nor approved");
        require(to != address(0), "ERC721: transfer to the zero address");
        _transfer(from, to, tokenId);
    }

    // Mint token
    function mint(address to) public onlyOwner{
        _mint(to);
    }

    // Check Token exist or not
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    // Check permission
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    // Mint
    function _mint(address to) internal virtual {
        uint32 tokenId = _supply+1;
        require(to != address(0), "ERC721: mint to the zero address");
        // require(!_exists(tokenId), "ERC721: token already minted");
        require(_max >= (tokenId), "ERC721: no more token supply");

        _supply += 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // Transfers token from token owner
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // Approve to operate on token ID
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    // Approve all token to operator
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    // Token ID not been minted yet
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }


/*-------- ERC165 --------*/

    function supportsInterface(bytes4 interfaceID) public view returns (bool) {
        return supportedInterfaces[interfaceID];
    }

    function registerInterface(bytes4 interfaceID) internal virtual {
        require(interfaceID != 0xffffffff, "Invalid interface id");
        supportedInterfaces[interfaceID] = true;
    }


/*-------- Library --------*/

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
