// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedFileManagement {
    address public owner;

    struct File {
        string name;
        string fileType;
        uint256 size;
        address author;
    }

    mapping(bytes32 => File) private files;
    bytes32[] private fileHashes;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function uploadFile(string memory name, string memory fileType, uint256 size) public returns (bytes32) {
        require(size > 0, "File size must be greater than zero");

        bytes32 fileHash = keccak256(abi.encodePacked(name, fileType, size, msg.sender));
        require(files[fileHash].author == address(0), "File already exists");

        files[fileHash] = File({
            name: name,
            fileType: fileType,
            size: size,
            author: msg.sender
        });

        fileHashes.push(fileHash);

        return fileHash;
    }

    function getFile(bytes32 fileHash) public view returns (string memory, string memory, uint256, address) {
        require(files[fileHash].author != address(0), "File does not exist");

        File memory file = files[fileHash];
        return (file.name, file.fileType, file.size, file.author);
    }

    function deleteFile(bytes32 fileHash) public {
        require(files[fileHash].author == msg.sender, "Only the author can delete this file");
        require(files[fileHash].author != address(0), "File does not exist");

        delete files[fileHash];

        for (uint256 i = 0; i < fileHashes.length; i++) {
            if (fileHashes[i] == fileHash) {
                fileHashes[i] = fileHashes[fileHashes.length - 1];
                fileHashes.pop();
                break;
            }
        }

        assert(files[fileHash].author == address(0));
    }

    function getAllFiles() public view returns (File[] memory) {
        File[] memory allFiles = new File[](fileHashes.length);

        for (uint256 i = 0; i < fileHashes.length; i++) {
            allFiles[i] = files[fileHashes[i]];
        }

        return allFiles;
    }

    function getFileHashByName(string memory name) public view returns (bytes32) {
        for (uint256 i = 0; i < fileHashes.length; i++) {
            if (keccak256(abi.encodePacked(files[fileHashes[i]].name)) == keccak256(abi.encodePacked(name))) {
                return fileHashes[i];
            }
        }
        revert("File not found");
    }

    fallback() external payable {
        revert("Contract does not accept Ether");
    }

    receive() external payable {
        revert("Contract does not accept Ether");
    }
}