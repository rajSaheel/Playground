// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Voting {

    address public owner;
    bool public isElection = true;

    event VoterRegistered(address voterAddress, string voterName);
    event Voted(address voterAddress, uint candidateIndex);
    event CandidateFiled(address candidateAddress, string candidateName);
    event ElectionStateChanged(bool isElection);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have the access to transact this function!");
        _;
    }

    modifier duringElection() {
        require(isElection == true, "Election is not active");
        _;
    }

    modifier afterElection() {
        require(isElection == false, "Election is still active");
        _;
    }

    struct Voter {
        uint id;
        string name;
        bool hasVoted;
        bool isRegistered;
    }

    struct Candidate {
        uint id;
        uint votes;
        string name;
        bool isFiled;
    }

    mapping(address => Candidate) public candidates;
    address[] public candidateArr;
    mapping(address => Voter) public voters;
    address[] public voterArr;

    function turnElection() public onlyOwner {
        isElection = !isElection;
        emit ElectionStateChanged(isElection);
    }

    function registerVoter(string memory _name) external duringElection {
        require(!voters[msg.sender].isRegistered, "Voter has already been registered!");
        voters[msg.sender] = Voter({
            id: voterArr.length + 1,
            name: _name,
            hasVoted: false,
            isRegistered: true
        });
        voterArr.push(msg.sender);
        emit VoterRegistered(msg.sender, _name);
    }

    function vote(uint _index) external duringElection {
        require(voters[msg.sender].isRegistered, "You are not registered to vote!");
        require(!voters[msg.sender].hasVoted, "You have already voted!");
        require(_index > 0 && _index <= candidateArr.length, "Invalid candidate index");

        candidates[candidateArr[_index - 1]].votes++;
        voters[msg.sender].hasVoted = true;
        emit Voted(msg.sender, _index);
    }

    function fileCandidature(string memory _name) external duringElection {
        require(!candidates[msg.sender].isFiled, "You have already filed for candidature");
        candidates[msg.sender] = Candidate({
            id: candidateArr.length + 1,
            votes: 0,
            name: _name,
            isFiled: true
        });
        candidateArr.push(msg.sender);
        emit CandidateFiled(msg.sender, _name);
    }

    function announceResult() external view afterElection returns (address[] memory, string[] memory, uint[] memory) {
        uint length = candidateArr.length;
        string[] memory candidateNames = new string[](length);
        uint[] memory candidateVotes = new uint[](length);

        for (uint i = 0; i < length; i++) {
            Candidate storage candidate = candidates[candidateArr[i]];
            candidateNames[i] = candidate.name;
            candidateVotes[i] = candidate.votes;
        }

        return (candidateArr, candidateNames, candidateVotes);
    }
}
