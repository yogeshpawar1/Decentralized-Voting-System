// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Decentralized Voting System
 * @dev A smart contract for conducting transparent and secure voting
 * @author Your Name
 */
contract Project {
    // Struct to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingActive;
    uint256 public totalCandidates;
    uint256 public totalVotes;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event VoterRegistered(address indexed voter);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }
    
    modifier isRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    /**
     * @dev Constructor to initialize the voting system
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        totalCandidates = 0;
        totalVotes = 0;
    }
    
    /**
     * @dev Core Function 1: Register a voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) external onlyOwner {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_voter != address(0), "Invalid voter address");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 2: Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) external 
        votingIsActive 
        isRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Increment candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCasted(msg.sender, _candidateId);
    }
    
    /**
     * @dev Core Function 3: Get election results
     * @return winningCandidateId ID of the winning candidate
     * @return winningCandidateName Name of the winning candidate
     * @return winningVoteCount Vote count of the winning candidate
     */
    function getResults() external view returns (
        uint256 winningCandidateId,
        string memory winningCandidateName,
        uint256 winningVoteCount
    ) {
        require(totalCandidates > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        uint256 winnerId = 0;
        
        // Find candidate with maximum votes
        for (uint256 i = 1; i <= totalCandidates; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }
        
        return (
            winnerId,
            candidates[winnerId].name,
            candidates[winnerId].voteCount
        );
    }
    
    /**
     * @dev Add a new candidate (only owner)
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) external onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(!votingActive, "Cannot add candidates while voting is active");
        
        totalCandidates++;
        candidates[totalCandidates] = Candidate({
            id: totalCandidates,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(totalCandidates, _name);
    }
    
    /**
     * @dev Toggle voting status (only owner)
     */
    function toggleVoting() external onlyOwner {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    /**
     * @dev Get candidate details by ID
     * @param _candidateId ID of the candidate
     * @return id Candidate ID
     * @return name Candidate name
     * @return voteCount Current vote count
     */
    function getCandidate(uint256 _candidateId) external view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get voter information
     * @param _voter Address of the voter
     * @return isRegistered Whether voter is registered
     * @return hasVoted Whether voter has voted
     * @return votedCandidateId ID of candidate voted for (0 if not voted)
     */
    function getVoterInfo(address _voter) external view returns (
        bool isRegistered,
        bool hasVoted,
        uint256 votedCandidateId
    ) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
    
    /**
     * @dev Get election statistics
     * @return _electionName Name of the election
     * @return _totalCandidates Total number of candidates
     * @return _totalVotes Total votes cast
     * @return _votingActive Current voting status
     */
    function getElectionInfo() external view returns (
        string memory _electionName,
        uint256 _totalCandidates,
        uint256 _totalVotes,
        bool _votingActive
    ) {
        return (electionName, totalCandidates, totalVotes, votingActive);
    }
}