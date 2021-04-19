pragma ton-solidity >= 0.38.2;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

//import "DEXclient.sol"; //check path
//import "DEXpair.sol";

contract DEXrootClientStorage {
    TvmCell m_DEXclientCode;
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
    constructor() public {
        tvm.accept();
    }

    function setClientCode(TvmCell m_DEXclientCode1) public checkOwnerAndAccept {
        m_DEXclientCode = m_DEXclientCode1;
    }
    function getClientCode() public view alwaysAccept responsible returns(TvmCell m_DEXclientCode2) {
        m_DEXclientCode2 = m_DEXclientCode;
    }
    function getClientCode1() public view alwaysAccept returns(TvmCell m_DEXclientCode2) {
        m_DEXclientCode2 = m_DEXclientCode;
    }
}
