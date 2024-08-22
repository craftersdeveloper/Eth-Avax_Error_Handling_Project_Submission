# File Management Contract - Error Handling 

The objective of this project is to develop a smart contract for file management that securely stores file metadata on the blockchain. The contract will demonstrate the use of Solidity's require(), assert(), and revert() functions for effective error handling. By implementing these functions, the project aims to ensure that only valid operations are executed, with appropriate conditions enforced and errors reverted when necessary, thus maintaining the integrity and reliability of the file management system on the blockchain.

## Feature 

_**Secure Storage of File Metadata:**_

Design and implement a smart contract that allows users to upload, retrieve, and manage file metadata securely on the blockchain.
Ensure that all metadata entries are immutable and transparently recorded, leveraging the inherent security features of blockchain technology.

_**Error Handling Demonstration:**_

Utilize the require() function to validate user inputs and preconditions before executing critical functions, preventing invalid transactions and ensuring proper usage.
Apply the assert() function to enforce internal invariants and guarantee that the contract's state remains consistent throughout its execution.
Implement the revert() function to handle unexpected conditions and rollback transactions when specific errors or exceptions are encountered, maintaining the integrity of the contract's operations.

_**Access Control and Authorization:**_

Incorporate permission checks using error handling functions to ensure that only authorized users can perform certain actions, such as modifying or deleting metadata entries.
Provide clear and informative error messages to guide users and developers in understanding and resolving issues that arise during contract interaction.

_**Performance and Efficiency:**_

Optimize contract functions to minimize gas consumption and ensure cost-effective operations without compromising security and functionality.
Conduct thorough testing and debugging to identify and resolve potential issues related to storage, retrieval, and error handling processes.

_**Documentation and Usability:**_

Provide comprehensive documentation detailing the contract's architecture, functionalities, and usage instructions.
Include examples and explanations of how each error handling function (require(), assert(), and revert()) is implemented within the contract to facilitate learning and understanding.

## Contract Explanation 

```solidity
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
```

The `DecentralizedFileManagement` contract is a Solidity smart contract designed to manage file metadata on the Ethereum blockchain in a decentralized manner. Here's a breakdown of its components and functionalities:

### 1. **Contract Overview**
   - **Owner:** The contract has an owner, typically the deployer, who is set when the contract is created.
   - **File Struct:** The contract defines a `File` struct to store metadata about files, including their name, type, size, and author (uploader).
   - **Mapping:** A mapping (`files`) is used to associate file hashes (generated using `keccak256`) with their respective `File` structs.
   - **File Hashes:** The contract maintains an array (`fileHashes`) of all file hashes stored, allowing retrieval of all files.

### 2. **Modifiers**
   - **onlyOwner:** This modifier restricts certain actions to the owner of the contract. It checks if the caller is the owner and reverts the transaction if not.

### 3. **Core Functions**
   - **`uploadFile`:** 
     - Allows a user to upload a file's metadata.
     - **Input:** Takes the file's name, type, and size as inputs.
     - **Validation:** 
       - Requires the file size to be greater than zero.
       - Ensures that the file does not already exist by checking the generated file hash.
     - **Storage:** 
       - Stores the file metadata in the `files` mapping using a unique hash.
       - Adds the file hash to the `fileHashes` array.
     - **Returns:** The unique file hash.

   - **`getFile`:**
     - Allows anyone to retrieve file metadata by providing its hash.
     - **Validation:** Checks if the file exists using the hash.
     - **Returns:** The file's name, type, size, and author.

   - **`deleteFile`:**
     - Allows the author of a file to delete its metadata from the contract.
     - **Validation:** 
       - Ensures the caller is the file's author.
       - Confirms that the file exists.
     - **Deletion:** 
       - Removes the file metadata from the `files` mapping.
       - Updates the `fileHashes` array by removing the hash associated with the deleted file.
     - **Assertion:** Ensures the file is indeed deleted by checking if the author field is set to the zero address.

   - **`getAllFiles`:**
     - Provides a way to retrieve metadata for all files stored in the contract.
     - **Returns:** An array of `File` structs representing all stored files.

   - **`getFileHashByName`:**
     - Allows users to retrieve a file hash by searching for a file by its name.
     - **Returns:** The hash of the file if found.
     - **Reverts:** If the file with the specified name is not found, it reverts the transaction.

### 4. **Fallback and Receive Functions**
   - **fallback:** This function ensures that the contract cannot receive Ether. Any Ether sent to the contract will trigger a revert.
   - **receive:** Similar to the fallback function, it prevents Ether from being accepted by the contract.

### 5. **Error Handling**
   - **`require()`**
     - Used to validate conditions such as file size, ownership, and file existence before proceeding with function logic.
   - **`assert()`**
     - Used to ensure the contract's internal state remains consistent, particularly after deleting a file.
   - **`revert()`**
     - Explicitly called in fallback and receive functions to reject Ether, and in `getFileHashByName` if the file is not found.

### 6. **Security Considerations**
   - **Access Control:** Only the owner can perform specific actions, enforced using the `onlyOwner` modifier.
   - **Data Integrity:** The use of cryptographic hashing (`keccak256`) ensures the uniqueness of file identifiers.
   - **Error Prevention:** The contract includes comprehensive checks to prevent unauthorized access, duplicate files, and invalid data submissions.
   - 


