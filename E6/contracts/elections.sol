// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./ownable.sol";
import "./safemath.sol";

/**
 * @title Elections
 * @notice This contract manages election-related functions.
 */
contract Elections is Ownable {
    using SafeMath for uint16;
    using SafeMath for uint256;

    uint16 public currentElectionsDay;

    uint16[] public electionsDayList;

    mapping(uint16 => string[]) electionsToCandidates;
    mapping(uint16 => mapping(string => bool)) electionsToCandidateExist;
    mapping(uint16 => mapping(string => uint)) electionsToCandidateToVotes;
    mapping(uint16 => mapping(address => bool)) electionsToPeopleToVoted;

    event changeElectionsDay(
        uint16 lastElectionsDay,
        uint16 actualElectionsDay
    );

    /**
     * @notice Converts a Unix timestamp into UNIX days.
     * @dev Using uint16 for optimization (valid until year 2149).
     * @param _timestamp The Unix timestamp to convert.
     * @return The number of days from January 1st 1970.
     */
    function _daysFromTimeStamp(uint _timestamp) private pure returns (uint16) {
        return uint16(_timestamp.div(60).div(60).div(24));
    }

    /**
     * @dev Internal function to check if it's an elections day.
     * @return true if it's an elections day, otherwise false.
     */
    function _isElectionsDay() private view returns (bool) {
        return currentElectionsDay == _daysFromTimeStamp(block.timestamp);
    }

    /**
     * @dev Modifier to check if it's an elections day.
     */
    modifier onElectionsDay() {
        require(_isElectionsDay(), "It's not elections day yet!");
        _;
    }

    /**
     * @dev Modifier to check if it's not an elections day.
     */
    modifier onNotElectionsDay() {
        require(!_isElectionsDay(), "It's still elections day!");
        _;
    }

    /**
     * @dev Modifier to check if a voter has not voted yet.
     */
    modifier voterDidNotVote() {
        require(
            !electionsToPeopleToVoted[currentElectionsDay][msg.sender],
            "The voter had already voted!"
        );
        _;
    }

    /**
     * @dev Modifier to check if a candidate exists in determined elections.
     * @param _day The day for which the candidate's existence is checked.
     * @param _name The name of the candidate to check for existence.
     */
    modifier candidateExists(uint16 _day, string memory _name) {
        require(
            electionsToCandidateExist[_day][_name],
            "The candidate does not exist!"
        );
        _;
    }

    /**
     * @dev Internal function for initializing a new day of elections.
     * @param _electionsDay The day for which elections are being initialized.
     * @param _candidates An array containing the names of the candidates for
     * this day.
     */
    function _beginElections(
        uint16 _electionsDay,
        string[] memory _candidates
    ) private {
        currentElectionsDay = _electionsDay;
        electionsDayList.push(_electionsDay);
        electionsToCandidates[_electionsDay] = _candidates;
        for (uint i = 0; i < _candidates.length; i++) {
            electionsToCandidateExist[_electionsDay][_candidates[i]] = true;
        }
    }

    /**
     * @dev Constructor for initializing the elections contract.
     * @param _electionsTimeStamp The UNIX timestamp of the day when the
     * elections will take place.
     * @param _candidates An array containing the names of the candidates.
     */
    constructor(uint256 _electionsTimeStamp, string[] memory _candidates) {
        _beginElections(_daysFromTimeStamp(_electionsTimeStamp), _candidates);
    }

    /**
     * @notice Start new elections, ending the previous ones (if any).
     * @param _electionsTimeStamp The timestamp of the day when the elections
     * will take place.
     * @param _candidates An array containing the names of the candidates.
     */
    function newElections(
        uint256 _electionsTimeStamp,
        string[] memory _candidates
    ) external onlyOwner /*onNotElectionsDay*/ {
        uint16 newElectionsDay = _daysFromTimeStamp(_electionsTimeStamp);
        emit changeElectionsDay(currentElectionsDay, newElectionsDay);
        _beginElections(newElectionsDay, _candidates);
    }

    /**
     * @notice Vote for a specific candidate in the ongoing elections.
     * @param _candidate The name of the candidate you are voting for.
     */
    function vote(
        string memory _candidate
    )
        external
        onElectionsDay
        voterDidNotVote
        candidateExists(currentElectionsDay, _candidate)
    {
        electionsToPeopleToVoted[currentElectionsDay][msg.sender] = true;
        electionsToCandidateToVotes[currentElectionsDay][_candidate]++;
    }

    /**
     * @notice Get the list of days for which election results are available.
     * @return An array of unsigned integers representing the election days.
     */
    function getElectionsDays() public view returns (uint16[] memory) {
        return electionsDayList;
    }

    /**
     * @notice Get the list of candidates for a specific day's election.
     * @param _day The elections day for which you want to get the candidates.
     * @return An array of strings containing the candidates' names.
     */
    function getElectionsCandidates(
        uint16 _day
    ) public view returns (string[] memory) {
        return electionsToCandidates[_day];
    }

    /**
     * @notice Get the number of votes received by a specific candidate on a
     * given day.
     * @param _day UNIX day for which you want to retrieve the vote count.
     * @param _candidate The name of the candidate.
     * @return The total number of votes received by the specified candidate
     * on the specified day.
     */
    function getCandidateVotes(
        uint16 _day,
        string memory _candidate
    ) public view candidateExists(_day, _candidate) returns (uint) {
        return electionsToCandidateToVotes[_day][_candidate];
    }
}
