// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DecentralizedVoting
 * @dev A transparent and secure voting system on the blockchain
 * @author Your Name
 */
contract DecentralizedVoting {
    
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
    string public electionTitle;
    bool public votingActive;
    uint256 public totalVotes;
    uint256 private nextCandidateId;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint256[] public candidateIds;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStarted();
    event VotingEnded();
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    modifier votingNotActive() {
        require(!votingActive, "Voting is currently active");
        _;
    }
    
    /**
     * @dev Constructor to initialize the contract
     * @param _electionTitle Title of the election
     */
    constructor(string memory _electionTitle) {
        owner = msg.sender;
        electionTitle = _electionTitle;
        votingActive = false;
        totalVotes = 0;
        nextCandidateId = 1;
    }
    
    /**
     * @dev Core Function 1: Add a candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner votingNotActive {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        uint256 candidateId = nextCandidateId;
        candidates[candidateId] = Candidate({
            id: candidateId,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        candidateIds.push(candidateId);
        nextCandidateId++;
        
        emit CandidateAdded(candidateId, _name);
    }
    
    /**
     * @dev Core Function 2: Register a voter
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyOwner {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter is already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 3: Cast a vote
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public votingIsActive {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Record the vote
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Increment candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Start the voting process
     */
    function startVoting() public onlyOwner votingNotActive {
        require(candidateIds.length >= 2, "Need at least 2 candidates to start voting");
        votingActive = true;
        emit VotingStarted();
    }
    
    /**
     * @dev End the voting process
     */
    function endVoting() public onlyOwner votingIsActive {
        votingActive = false;
        emit VotingEnded();
    }
    
    /**
     * @dev Get candidate information
     * @param _candidateId ID of the candidate
     * @return id, name, voteCount of the candidate
     */
    function getCandidate(uint256 _candidateId) public view returns (uint256, string memory, uint256) {
        require(candidates[_candidateId].exists, "Candidate does not exist");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get all candidate IDs
     * @return Array of candidate IDs
     */
    function getCandidateIds() public view returns (uint256[] memory) {
        return candidateIds;
    }
    
    /**
     * @dev Get the winner of the election
     * @return winnerId, winnerName, winnerVoteCount
     */
    function getWinner() public view returns (uint256, string memory, uint256) {
        require(!votingActive, "Voting is still active");
        require(totalVotes > 0, "No votes have been cast");
        
        uint256 winnerId = 0;
        uint256 highestVoteCount = 0;
        
        for (uint256 i = 0; i < candidateIds.length; i++) {
            uint256 candidateId = candidateIds[i];
            if (candidates[candidateId].voteCount > highestVoteCount) {
                highestVoteCount = candidates[candidateId].voteCount;
                winnerId = candidateId;
            }
        }
        
        return (winnerId, candidates[winnerId].name, highestVoteCount);
    }
    
    /**
     * @dev Get voter information
     * @param _voter Address of the voter
     * @return isRegistered, hasVoted, votedCandidateId
     */
    function getVoterInfo(address _voter) public view returns (bool, bool, uint256) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
}
