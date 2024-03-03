// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract Twitter_Contract {
    struct tweet {
        uint id;
        address author;
        string content;
        uint createdAt;
    }
    struct VerifiedUser {
        bool isVerified;
        uint verificationFee;
    }

    struct message {
        uint id; 
        address from;
        address to;
        string content;
        uint createdAt;
    }

    mapping(uint => tweet) public tweets;
    mapping(address => uint[]) public tweetsOf;
    mapping(address => message[]) public conversations;
    mapping(address => mapping(address => bool)) public operators;
    mapping(address => address[]) public followers;
    mapping(address => VerifiedUser) public verifiedUsers;

    uint public nextId;
    uint public nextMessageId;
    uint public verificationFee;

    constructor(uint _verificationFee) {
        verificationFee = _verificationFee;
    }

   function Tweet(address _author, string memory _content) internal {
    require(bytes(_content).length <= 280, "Tweet content exceeds 280 characters");
    tweets[nextId] = tweet(nextId, _author, _content, block.timestamp);
    nextId++;
}

    function _sendMessage(address _from, address _to, string memory _content) internal {
        conversations[_from].push(message(
            nextMessageId,
            _from,
            _to,
            _content,
            block.timestamp
        ));
        nextMessageId++;
    }

    function tweetByPR(address _address, string memory _content) public {
        Tweet(_address, _content);
    }

    function tweetByOwner(string memory _content) public {
        Tweet(msg.sender, _content);
    }

    function sendMessageByPR(address _from, address _to, string memory _content) public {
        _sendMessage(_from, _to, _content);
    }

    function sendMessageByOwner(address _to, string memory _content) public {
        _sendMessage(msg.sender, _to, _content);
    }

    function follow(address _address) public {
        followers[msg.sender].push(_address);
    }

    function allow(address _operator) public {
        operators[msg.sender][_operator] = true;
    }

    function disallow(address _operator) public {
        operators[msg.sender][_operator] = false;
    }

    function getLatestTweet(uint count) public view returns (tweet[] memory) {
        require(count > 0 && count < nextId, "Count is not proper");
        uint j;
        tweet[] memory _tweets = new tweet[](count);
        for (uint i = nextId - count; i < nextId; i++) {
            tweet storage structure = tweets[i];
            _tweets[j] = tweet(
                structure.id,
                structure.author,
                structure.content,
                structure.createdAt
            );
            j++;
        }
        return _tweets;
    }

    function verifyAccount() public payable {
        require(!verifiedUsers[msg.sender].isVerified, "Account is already verified");
        require(msg.value == verificationFee, "Incorrect verification fee");
        
        verifiedUsers[msg.sender] = VerifiedUser(true, msg.value);
    }

    function setVerificationFee(uint _verificationFee) public {
        verificationFee = _verificationFee;
    }
    
    function isAccountVerified(address _account) public view returns(bool) {
    if (verifiedUsers[_account].isVerified == true){
        return true;
    } else {
        return false;
    }
  }

}
