pragma ton-solidity >=0.38.2;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

interface IDEXroot {
	function getCfg() external responsible returns(address rootWrapper, address wrapper);
}

contract DEXclienttest {

	address ROOT_WRAPPED_TON = address(0x0);
	address WRAPPER_TON = address(0x0);

	constructor(address DEXroot) public {
		require(tvm.pubkey() == msg.pubkey(), 102);
		tvm.accept();
		IDEXroot(DEXroot).getCfg{callback:DEXclienttest.setCfg}();
	}
	function setCfg(address rootWrapper, address wrapper) public {
		ROOT_WRAPPED_TON = rootWrapper;
		WRAPPER_TON = wrapper;
	}
	function getCfg() public view returns(address rootWrapper, address wrapper) {
		rootWrapper = ROOT_WRAPPED_TON;
		wrapper = WRAPPER_TON;
	}

}
