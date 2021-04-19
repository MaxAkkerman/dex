pragma ton -solidity >= 0.38.2;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DEXclient.sol"; //check path
import "DEXpair.sol";

contract DEXroot {
//    TvmCell m_DEXclientCode;
//    address m_dexClientAddress;

    modifier alwaysAccept {
        tvm.accept();
        _;
    }
    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        _;
    }
//    constructor(TvmCell DEXclientCode) public {
//        tvm.accept();
//        m_DEXclientCode = DEXclientCode;
//    }
    constructor() public {
        tvm.accept();
    }
    address ROOT_WRAPPED_TON = address(0x0);
    address WRAPPER_TON = address(0x0);

    function setCfg(address rootWrapper, address wrapper) public checkOwnerAndAccept {
        ROOT_WRAPPED_TON = rootWrapper;
        WRAPPER_TON = wrapper;
    }
    function getCfg() public view alwaysAccept responsible returns(address rootWrapper, address wrapper) {
        rootWrapper = ROOT_WRAPPED_TON;
        wrapper = WRAPPER_TON;
    }
//    function getAddress() public view returns (address clientAddress, TvmCell code1){
//        clientAddress = m_dexClientAddress;
//        code1 = m_DEXclientCode;
//    }

    //pubkey - need to gen keys
//    function deployNewDexClient(uint256 pubkey) public alwaysAccept returns (address newAddress){
//
//        uint128 grams = 3000000000;
//        uint256 pubk = pubkey;
//
//        m_dexClientAddress = new DEXclient{
//            flag: 0,
//            value : grams,
//            code : m_DEXclientCode,
//            pubkey : pubk
//            }();
//        newAddress = m_dexClientAddress;
//    }
}
