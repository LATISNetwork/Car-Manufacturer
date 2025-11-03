// // SPDX-License-Identifier: GPL-3.0
// To Compile Run: solcjs --optimize --bin SecureUpdate.sol -o Smart_Contract_Binary

pragma solidity >=0.8.0 <0.9.0;

// Information on OpenZeppelin Contracts can be found at: https://docs.openzeppelin.com/contracts/4.x/access-control
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

// STRUCTURE OF THE CONTRACT
// 1. State Variables
// 2. Events
// 3. Modifiers
// 4. Constructor
// 5. Functions

// ROLES
// [ADMIN, MODEL_A, MODEL_B, MODEL_C]
// ADMIN Privs: Can add/remove roles, can add/remove tokens, can add/remove use, can add/remove updates
// MODEL_A Privs: Can fetch updates specific to MODEL A
// MODEL_B Privs: Can fetch updates specific to MODEL B
// MODEL_C Privs: Can fetch updates specific to MODEL C

// METHODS
// [addUpdate, fetchUpdate, updateStatus, addVehicle, grantPermission]

contract SecureUpdate is ERC20, AccessControl {
    // Roles
    // Note: The bottom 4 lines can be replaced with hard-coded hashes to save compute on deployment
    bytes32 private constant ADMIN = keccak256("ADMIN");
    bytes32 private constant MODEL_A = keccak256("MODEL_A");
    bytes32 private constant MODEL_B = keccak256("MODEL_B");
    bytes32 private constant MODEL_C = keccak256("MODEL_C");
    bytes32[4] private permissionArray = [ADMIN, MODEL_A, MODEL_B, MODEL_C];

    // Define Update Struct
    struct update {
        string key;
        string checksum;
        string cid;
        string updateVersion;
        Set updateSuccess;
        Set updateFail;
    }

    // Dictionary storing information for current updates
    mapping(bytes32 => update) private curUpdates;

    constructor() ERC20("MyToken", "TKN") {
        _grantRole(ADMIN, msg.sender);
    }

    function hasUpdate(uint8 _model) public view returns (bool) {
        require(
            hasRole(permissionArray[_model], msg.sender),
            "Only the correct model can fetch updates"
        );
        return (
            !curUpdates[permissionArray[_model]].updateSuccess.has(msg.sender)
        );
    }

    function addUpdate(
        string memory _key,
        string memory _checksum,
        string memory _cid,
        string memory _updateVersion,
        uint8 _model
    ) public {
        require(hasRole(ADMIN, msg.sender), "Only ADMIN can add updates");
        bytes32 _tmodel = permissionArray[_model];
        curUpdates[_tmodel] = update(
            _key,
            _checksum,
            _cid,
            _updateVersion,
            new Set(),
            new Set()
        );
    }

    function fetchUpdate(
        uint8 _model
    )
        public
        view
        returns (string memory, string memory, string memory, string memory)
    {
        // Check has the correct role
        require(
            hasRole(permissionArray[_model], msg.sender),
            "Only the correct model can fetch updates"
        );
        // Check that system is not up to date
        require(
            !(
                curUpdates[permissionArray[_model]].updateSuccess.has(
                    msg.sender
                )
            ),
            "No update for this model"
        );
        return (
            curUpdates[permissionArray[_model]].key,
            curUpdates[permissionArray[_model]].checksum,
            curUpdates[permissionArray[_model]].cid,
            curUpdates[permissionArray[_model]].updateVersion
        );
    }

    function updateUpdateStatus(uint8 _model, bool _status) public {
        // Check has the correct role
        require(
            hasRole(permissionArray[_model], msg.sender),
            "Only the correct model can status updates"
        );
        if (_status)
            curUpdates[permissionArray[_model]].updateSuccess.add(msg.sender);
        else curUpdates[permissionArray[_model]].updateFail.add(msg.sender);
    }

    function addVehicle(uint8 _model, address _vehicle) public {
        // Check has the correct role
        require(hasRole(ADMIN, msg.sender), "Only admin can add vehicles");
        _grantRole(permissionArray[_model], _vehicle);
    }

    function grantAdmin(address _address) public {
        // Check has the correct role
        require(hasRole(ADMIN, msg.sender), "Only admin can grant permissions");
        _grantRole(ADMIN, _address);
    }

    function revokeAdmin(address _address) public {
        // Check has the correct role
        require(
            hasRole(ADMIN, msg.sender),
            "Only admin can revoke permissions"
        );
        _revokeRole(ADMIN, _address);
    }
}

contract Set {
    // Define Set Variables
    address[] values;
    mapping(address => bool) is_in;

    function add(address a) public {
        if (!is_in[a]) {
            values.push(a);
            is_in[a] = true;
        }
    }

    function has(address a) public view returns (bool) {
        return is_in[a];
    }
}
