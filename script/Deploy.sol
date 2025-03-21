pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {TaskManagerUpgradeable} from "../src/TaskManagerUpgradeable.sol";
import {PartnerUpgradeable} from "../src/PartnerUpgradeable.sol";

import {MockBridge} from "../src/mocks/MockBridge.sol";

contract TaskTest is Script {
    address public admin;
    address public relayer;
    address public goatBridge;

    function setUp() public virtual {
        admin = vm.envAddress("ADMIN_ADDR");
        relayer = vm.envAddress("RELAYER_ADDR");
        goatBridge = vm.envAddress("GOAT_BRIDGE_CONTRACT");
    }

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy contracts
        PartnerUpgradeable partnerLogic = new PartnerUpgradeable();
        UpgradeableBeacon partnerBeacon = new UpgradeableBeacon(
            address(partnerLogic),
            admin
        );
        TaskManagerUpgradeable taskManager = new TaskManagerUpgradeable(
            address(partnerBeacon),
            goatBridge
        );

        // initialize task manager
        taskManager.initialize();
        taskManager.grantRole(taskManager.ADMIN_ROLE(), admin);
        taskManager.grantRole(taskManager.RELAYER_ROLE(), relayer);

        console.log(
            "TaskManagerUpgradeable contract address: ",
            address(taskManager)
        );
        console.log(
            "UpgradeableBeacon contract address: ",
            address(partnerBeacon)
        );

        vm.stopBroadcast();
    }
}
