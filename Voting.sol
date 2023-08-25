// SPDX-License-Identifier:GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract VotingSystem {
    struct Ballot {
        string name;
        uint256[] voteCounts;
        bool active;
    }

    struct Voter {
        bool registered;
        bool hasVoted;
    }

    mapping(address => Voter) public voters;
    Ballot[] public ballots;

    event VoteCasted(
        uint256 indexed ballotId,
        uint256 indexed optionId,
        address indexed voter
    );

    modifier onlyRegisteredVoter() {
        require(
            voters[msg.sender].registered,
            "Only registered voters can perform this action"
        );
        _;
    }

    modifier onlyActiveBallot(uint256 _ballotId) {
        require(ballots[_ballotId].active, "The ballot is not active");
        _;
    }

    function registerVoter(address _voter) external {
        require(!voters[_voter].registered, "Voter already registered");
        voters[_voter].registered = true;
    }

    function createBallot(
        string memory _name,
        uint256 _numOptions
    ) external onlyRegisteredVoter {
        uint256[] memory initialVoteCounts = new uint256[](_numOptions);
        ballots.push(
            Ballot({name: _name, voteCounts: initialVoteCounts, active: true})
        );
    }

    function castVote(
        uint256 _ballotId,
        uint256 _optionId
    ) external onlyRegisteredVoter onlyActiveBallot(_ballotId) {
        require(
            !voters[msg.sender].hasVoted,
            "Voter has already casted a vote"
        );
        require(
            _optionId < ballots[_ballotId].voteCounts.length,
            "Invalid option ID"
        );

        voters[msg.sender].hasVoted = true;
        ballots[_ballotId].voteCounts[_optionId]++;

        emit VoteCasted(_ballotId, _optionId, msg.sender);
    }

    function closeBallot(
        uint256 _ballotId
    ) external onlyRegisteredVoter onlyActiveBallot(_ballotId) {
        ballots[_ballotId].active = false;
    }

    function getBallotCount() external view returns (uint256) {
        return ballots.length;
    }

    function getOptionCount(uint256 _ballotId) external view returns (uint256) {
        require(_ballotId < ballots.length, "Invalid ballot ID");
        return ballots[_ballotId].voteCounts.length;
    }

    function getVoteCount(
        uint256 _ballotId,
        uint256 _optionId
    ) external view returns (uint256) {
        require(_ballotId < ballots.length, "Invalid ballot ID");
        require(
            _optionId < ballots[_ballotId].voteCounts.length,
            "Invalid option ID"
        );
        return ballots[_ballotId].voteCounts[_optionId];
    }
}
