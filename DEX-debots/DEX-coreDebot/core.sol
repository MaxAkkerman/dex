pragma ton-solidity >=0.40.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Debot.sol";
import "Terminal.sol";
import "AddressInput.sol";
import "Sdk.sol";
import "Menu.sol";
import "Msg.sol";
//import "../interfaces/Debot.sol";
//import "../interfaces/Upgradable.sol";
//import "../interfaces/Transferable.sol";
//import "../interfaces/Sdk.sol";
//import "../interfaces/Terminal.sol";
//import "../interfaces/Menu.sol";
import "ConfirmInput.sol";
//import "../interfaces/Msg.sol";
//import "../interfaces/AddressInput.sol";
//import "../interfaces/AmountInput.sol";

interface ITONTokenWallet {
    function getName() external functionID(0x000000011) returns (bytes value0);
    function getBalance() external functionID(0x00000014) returns (uint128 value0);
    function getRootAddress() external functionID(0x000000016) returns (address value0);
}
interface IDEXroot {
    function deployNewDexClient(uint256 pubkey) external returns (address newAddress);
    function computeDEXclientAddr(uint256 pubkey) external returns (address value0);
    function createDEXclient(uint256 pubkey) external returns (address deployedAddress, bool statusCreate);
}
interface IDEXpair {
   function getReservesBalance() external returns (uint128 balanceReserveA, uint128 balanceReserveB);
}
interface IDEXWrapDebot {
    function wrapTonsStepExternall(address m_Client1) external;
}

interface IDEXclient {
    function createNewEmptyWalletByOwner(address rootAddr) external returns (bool createStatus);
    function wrapTON(uint128 qtyTONgrams) external returns (bool processWrapStatus);
    function unwrapTON() external returns (bool processUnwrapStatus);
    function getPair(address value0) external returns (address pairRootA, address pairReserveA, address clientDepositA, uint128 clientAllowanceA, address pairRootB, address pairReserveB, address clientDepositB, uint128 clientAllowanceB, address curPair);
    function sendTokens3(address from, address to, uint128 tokens) external returns (address transmitter, address receiver, TvmCell body);
    function makeBdepositToPair(address pairAddr, uint128 qtyA) external returns (bool makeDepositStatus);
    function makeAdepositToPair(address pairAddr, uint128 qtyA) external returns (bool makeDepositStatus);
    function returnAllLiquidity(address pairAddr) external returns (bool returnLiquidityStatus);
    function askBalanceToken(address walletAddr) external;
    function getBalanceTokenWallet(address walletAddr) external returns (uint128 walletBal);
    function getAllDataPreparation() external returns (address[] pairKeysR, address[] walletKeysR);
    function getPairClientWallets(address pairAddr) external returns (address clientWalletA, address clientWalletB, address pairReturn);
    function connectPair(address pairAddr) external returns (bool statusConnection);
    function processSwapA(address pairAddr, uint128 qtyA) external returns (bool processSwapStatus);
    function processSwapB(address pairAddr, uint128 qtyB) external returns (bool processSwapStatus);
    function processLiquidity(address pairAddr, uint128 qtyA, uint128 qtyB) external returns (bool processLiquidityStatus);
    function makeABdepositToPair(address pairAddr, uint128 qtyA, uint128 qtyB) external returns (bool makeDepositStatus);
}

interface IDEXrootClientStorage {
    function getClientCode1() external returns (TvmCell m_DEXclientCode2);
}

abstract contract ADEXclient {
    constructor() public {}
}
contract coreDebot is Debot {
    uint128 m_clientBalanceTon;
    address m_Client;
    address constant ROOT_WRAPPED_TON = address(0xff6da7ac48c8d5cbb9a05013540b52709c04f546ced81bcf0553a027cb04c210);

    struct Wallet {
        bytes name;
        address root;
        uint128 balanceToken;
    }
    struct Pair {
        bytes name1;
        bytes name2;
        address rootA;
        address pairWalletA;
        address depositWalletA;
        uint128 allowanceA;
        address rootB;
        address pairWalletB;
        address depositWalletB;
        uint128 allowanceB;
    }
    struct PairWallet {
        address wallet1;
        address wallet2;
    }
    mapping(address => PairWallet) PairWallets;
    bool statusTONwallet = false;
    mapping(address => Pair) pairs;
    address m_DexRootAddress;

    address[] clientPairKeys;

    mapping(address => Wallet) wallets;
    address[] clientWalletKeys;

    modifier alwaysAccept {
        tvm.accept();
        _;
    }
    address m_wrapperDebotAddress;
    TvmCell m_DEXclientCode;
    address m_DEXclientStorage;
    constructor(string debotAbi, address DexRootAddress, address DEXclientStorage1, address m_wrapperDebotAddress1) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        init(0, "", "", address(0));
        m_DexRootAddress = DexRootAddress;
        m_DEXclientStorage = DEXclientStorage1;
        m_wrapperDebotAddress = m_wrapperDebotAddress1;
    }
    function setABI(string dabi) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        m_debotAbi.set(dabi);
        m_options |= DEBOT_ABI;
    }





//    function setFlexClientCode(TvmCell code) public {
//        require(msg.pubkey() == tvm.pubkey(), 101);
//        tvm.accept();
//        m_flexClientCode = code;
//    }
    function start() public override {
        Menu.select("", "Welcome to Radiance DEX-Wrapper debot interface. Here you can create a new multi-TIP3 account or log into your existing account.", [
            MenuItem("Log into your existing client wallet", "", tvm.functionId(selectWallet)),
            MenuItem("Create a new DEX&TIP-3 client wallet", "", tvm.functionId(getFCAddressAndKeys)),
            MenuItem("Exit", "", 0)
            ]);
    }
/*
    deploy new client
*/


    function getFCAddressAndKeys(uint32 index) public {
        Menu.select("","",[
            MenuItem("Generate a seed phrase for me","",tvm.functionId(menuGenSeedPhrase)),
            MenuItem("I have the seed phrase","",tvm.functionId(menuEnterSeedPhrase))
            ]);
    }

    function menuGenSeedPhrase(uint32 index) public {
        Sdk.mnemonicFromRandom(tvm.functionId(showMnemonic),1,12);
    }

    function showMnemonic(string phrase) public {
        string str = "Generated seed phrase > ";
        str.append(phrase);
        str.append("\nWarning! Please don't forget it!");
        Terminal.print(0,str);
        menuEnterSeedPhrase(0);
    }

    function menuEnterSeedPhrase(uint32 index) public {
        Terminal.input(tvm.functionId(checkSeedPhrase),"Enter your seed phrase",false);
    }
string m_seedphrase;
    function checkSeedPhrase(string value) public {
        m_seedphrase = value;
        Sdk.mnemonicVerify(tvm.functionId(verifySeedPhrase),m_seedphrase);
    }

    function verifySeedPhrase(bool valid) public {
        if (valid){
            getMasterKeysFromMnemonic(m_seedphrase);
        }else{
            Terminal.print(tvm.functionId(coreDebot.start),"Error: not valid seed phrase! (try to enter it without quotes or generate a new one)");
        }
    }

    function getMasterKeysFromMnemonic(string phrase) public {
        Sdk.hdkeyXprvFromMnemonic(tvm.functionId(getMasterKeysFromMnemonicStep1),phrase);
    }

    function getMasterKeysFromMnemonicStep1(string xprv) public {
        string path = "m/44'/396'/0'/0/0";
        Sdk.hdkeyDeriveFromXprvPath(tvm.functionId(getMasterKeysFromMnemonicStep2), xprv, path);
    }

    function getMasterKeysFromMnemonicStep2(string xprv) public {
        Sdk.hdkeySecretFromXprv(tvm.functionId(getMasterKeysFromMnemonicStep3), xprv);
    }

    function getMasterKeysFromMnemonicStep3(uint256 sec) public {
        Sdk.naclSignKeypairFromSecretKey(tvm.functionId(getMasterKeysFromMnemonicStep4), sec);
    }
uint256 m_masterPubKey;
uint256 m_masterSecKey;
    function getMasterKeysFromMnemonicStep4(uint256 sec, uint256 pub) public {
        m_masterPubKey = pub;
        m_masterSecKey = sec;
        computeDEXclientAddr();
    }

    function computeDEXclientAddr() public {
        optional(uint256) pubkey;
        IDEXroot(m_DexRootAddress).computeDEXclientAddr{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setVIaRoot),
        onErrorId : 0
        }(m_masterPubKey);
    }
    address m_dexclientViaRoot;
    function setVIaRoot(address value0) public {
        m_dexclientViaRoot = value0;
        Terminal.print(0,format("send 5 tons to {}", value0));
        ConfirmInput.get(tvm.functionId(createDEXclientBool),"continue?...");
    }
    function createDEXclientBool(bool value) public {
        if (value){
            createDEXclient();
        } else
            Terminal.print(tvm.functionId(coreDebot.start),"Terminated!");
    }
    function createDEXclient() public {
        optional(uint256) pubkey;
        IDEXroot(m_DexRootAddress).createDEXclient{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setVIaRootDeployed),
        onErrorId : 0
        }(m_masterPubKey);
    }
    function setVIaRootDeployed(address deployedAddress, bool statusCreate) public {
        m_Client = deployedAddress;
        Terminal.print(0,format("status {}",deployedAddress));
        mainmenu();
    }

    function getCLientCode() public {
        optional(uint256) pubkey;
        IDEXrootClientStorage(m_DEXclientStorage).getClientCode1{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setClientCode),
        onErrorId : 0
        }();
    }
    function setClientCode(TvmCell m_DEXclientCode2) public {
        m_DEXclientCode = m_DEXclientCode2;
        ConfirmInput.get(tvm.functionId(checkCode),"continue?...");
    }
    function checkCode(bool value) public {
        if (value){
            checkFlexClient();
        } else
            Terminal.print(tvm.functionId(coreDebot.start),"Terminated!");
    }
    function checkFlexClient() public {
        Terminal.print(0,"At insert pubkeys");
        TvmCell deployState = tvm.insertPubkey(m_DEXclientCode, m_masterPubKey);
        m_Client = address.makeAddrStd(0, tvm.hash(deployState));
        Sdk.getAccountType(tvm.functionId(FlexClientAccType), m_Client);
    }

    function FlexClientAccType(int8 acc_type) public {
        if ((acc_type==-1)||(acc_type==0)) {
            ConfirmInput.get(tvm.functionId(isFCMoneySend),format("Send some tokens to address {}\nDid you send the money?",m_Client));
        }else if (acc_type==1){
            Terminal.print(tvm.functionId(coreDebot.start), format("FLeX Client account is {}",m_Client));
        } else if (acc_type==2){
            Terminal.print(tvm.functionId(coreDebot.start), format("Account {} is frozen.",m_Client));
        }
    }


    function isFCMoneySend(bool value) public {
        if (value){
            Sdk.getAccountType(tvm.functionId(DeployFlexClientStep1), m_Client);
        } else
            Terminal.print(tvm.functionId(coreDebot.start),"Terminated!");
    }

    function DeployFlexClientStep1(int8 acc_type) public {
        if (acc_type==-1) {
            FlexClientAccType(-1);
        }else if (acc_type==0) {
            Terminal.print(tvm.functionId(DeployFlexClientStep2Proxy), "Deploying..");
        }else if (acc_type==1){
            Terminal.print(tvm.functionId(coreDebot.start), format("Terminated! Account {} is already active.",m_Client));
        } else if (acc_type==2){
            Terminal.print(tvm.functionId(coreDebot.start), format("Terminated! Account {} is frozen.",m_Client));
        }
    }

//    function getClientCodeFromRoot() public {
//        optional(uint256) pubkey;
//        IDEXroot(m_DEXrootAddress).getClientCode{
//        abiVer : 2,
//        extMsg : true,
//        sign : false,
//        pubkey : pubkey,
//        time : uint64(now),
//        expire: 0x123,
//        callbackId : tvm.functionId(DeployFlexClientStep2Proxy),
//        onErrorId : 0
//        }();
//    }
    function DeployFlexClientStep2Proxy() public {
        DeployRootStep2(true);
    }

    function DeployRootStep2(bool value) public {
        if (value)
        {
            TvmCell image = tvm.insertPubkey(m_DEXclientCode, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: m_Client,
            callbackId: tvm.functionId(onSuccessFCDeployed),
            onErrorId: tvm.functionId(onDeployFCFailed),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,

            call: {ADEXclient}
            });
            Msg.sendWithKeypair(tvm.functionId(onSuccessFCDeployed), deployMsg,m_masterPubKey,m_masterSecKey);
        }else
            Terminal.print(tvm.functionId(coreDebot.start),"Terminated!");
    }

    function onSuccessFCDeployed() public {
        Terminal.print(tvm.functionId(mainmenu), format("Contract deployed {}\n",m_Client));
    }

    function onDeployFCFailed(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Deploy failed. Sdk error = {}, Error code = {}", sdkError, exitCode));
        ConfirmInput.get(tvm.functionId(DeployRootStep2), "Do you want to retry?");
    }


    ////////////////
    function deployDexClient(uint32 index) public {
        Terminal.inputUint(tvm.functionId(deployDexClientRequest), "Generate a new pubkey & set in 0x format");
    }
    function deployDexClientRequest(uint256 value) public alwaysAccept view {
        uint256 val = value;
        optional(uint256) pubkey;
        IDEXroot(m_DexRootAddress).deployNewDexClient{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setWalletAddressAfterDeploy),
        onErrorId : tvm.functionId(deployError)
        }(val);
    }
    function deployError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("sdkError: {}\nexitCOde:{}", sdkError, exitCode));
        start();
    }

    function setWalletAddressAfterDeploy(address newAddress) public {
        m_Client = newAddress;
//      Terminal.print(tvm.functionId(mainmenu), "Client address smart-contract complete...");
        checkDeployedWallet();
    }
    function checkDeployedWallet() public {
        Sdk.getAccountType(tvm.functionId(checkWalletExist), m_Client);
    }

    function checkWalletExist(int8 acc_type) public {
        if (acc_type == -1 || acc_type == 0 || acc_type == 2)  {
            checkDeployedWallet();
        }else{
            mainmenu();
        }
    }

    /*
        set wallet address
    */
    function selectWallet(uint32 index) public {
        Terminal.print(0, "Enter your client address");
        AddressInput.select(tvm.functionId(setWalletAddress));
    }
    function setWalletAddress(address value) public {
        m_Client = value;
        Terminal.print(tvm.functionId(getClientData), "");
    }
/*
    fetch client data
*/

    function createWTONwallet(uint32 index) public {
        if(statusTONwallet){
            Terminal.print(tvm.functionId(mainmenu), "You already have WTON wallet...");
        }else{
            createWTONwallet1();
        }
    }

    function createWTONwallet1() public {
            optional(uint256) pubkey;
            IDEXclient(m_Client).createNewEmptyWalletByOwner{
            abiVer : 2,
            extMsg : true,
            sign : true,
            pubkey : pubkey,
            time : uint64(now),
            expire: 0x123,
            callbackId : tvm.functionId(scCreareTonW),
            onErrorId : tvm.functionId(errCreareTonW)
            }(ROOT_WRAPPED_TON);
    }
    function scCreareTonW(bool createStatus) public {
        Terminal.print(tvm.functionId(mainmenu), "Success create WTON wallet");
        statusTONwallet = true;
    }
    function errCreareTonW(uint32 sdkError, uint32 exitCode) public {
        createWTONwallet1();
    }

    function getClientDataPRE(uint32 index) public {
        Terminal.print(tvm.functionId(getClientData), "");
    }
    function getClientData() public {
        optional(uint256) pubkey;
        IDEXclient(m_Client).getAllDataPreparation{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setClientData),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function setBalance(uint128 nanotokens) public {
        m_clientBalanceTon = nanotokens;
    }
//get exist pairs and wallets by client
    function setClientData(address[] pairKeysR, address[] walletKeysR) public {
        clientPairKeys = pairKeysR;
        clientWalletKeys = walletKeysR;
        Sdk.getBalance(tvm.functionId(setBalance), m_Client);
        Terminal.print(tvm.functionId(getWalletsData), "Data smart-contract complete...");
    }
//get pairs data

    function getPairsData(address pairAddress) public {
        optional(uint256) pubkey;
        IDEXclient(m_Client).getPair{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setClientPairData),
        onErrorId : tvm.functionId(someError)
        }(pairAddress);
    }
    function setClientPairData(address pairRootA, address pairReserveA, address clientDepositA, uint128 clientAllowanceA, address pairRootB, address pairReserveB, address clientDepositB, uint128 clientAllowanceB, address curPair) public {
        Pair cp = pairs[curPair];
            cp.rootA = pairRootA;
            cp.pairWalletA = pairReserveA;
            cp.depositWalletA = clientDepositA;
            cp.allowanceA = clientAllowanceA;
            cp.rootB = pairRootB;
            cp.pairWalletB = pairReserveB;
            cp.depositWalletB = clientDepositB;
            cp.allowanceB = clientAllowanceB;
            pairs[curPair] = cp;
    }
//fetching name and balance by each client wallet
    function getWalletsData() public {

        for(uint8 i = 0; i < clientWalletKeys.length; i++){
            address curClientWallet = clientWalletKeys[i];
            askNameTokenWallet(curClientWallet);
            askWalletBalance1(curClientWallet);
            askRootAddressTokenWallet(curClientWallet);
        }
        for(uint8 k = 0; k < clientPairKeys.length; k++){
            address curClientPair = clientPairKeys[k];
            getPairsData(curClientPair);
            getPairClientWalletsFunc(curClientPair);
        }
        Terminal.print(tvm.functionId(mainmenu), "Client data smart-contract complete...\nPlease refresh and get your client data");
    }


    function getPairClientWalletsFunc(address cuePair) public alwaysAccept {
        address curPairRes = cuePair;
        optional(uint256) pubkey;
        IDEXclient(m_Client).getPairClientWallets{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setWalletsNameS),
        onErrorId : tvm.functionId(someError)
        }(curPairRes);
    }

    function setWalletsNameS(address clientWalletA, address clientWalletB, address pairReturn) public {
        address adrAX = clientWalletA;
        address adrBX = clientWalletB;
        PairWallet pw = PairWallets[pairReturn];
        pw.wallet1 = adrAX;
        pw.wallet2 = adrBX;
        PairWallets[pairReturn] = pw;
        Pair cx = pairs[pairReturn];
        Wallet cp = wallets[adrAX];
        Wallet cp1 = wallets[adrBX];
        bytes nameP = cp.name;
        bytes nameR = cp1.name;
        cx.name1 = nameP;
        cx.name2 = nameR;
        pairs[pairReturn] = cx;
    }
    function askRootAddressTokenWallet(address waletAddress) public alwaysAccept {
        optional(uint256) pubkey;
        ITONTokenWallet(waletAddress).getRootAddress{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setRootAddress),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function setRootAddress(address value0) public {
        address rootAddress = value0;
        address clientWallet = msg.sender;
        Wallet cp = wallets[clientWallet];
        cp.root = rootAddress;
        wallets[clientWallet] = cp;
    }

    function askNameTokenWallet(address waletAddress) public alwaysAccept {
        optional(uint256) pubkey;
        ITONTokenWallet(waletAddress).getName{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setTokenName),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function setTokenName(bytes value0) public {
        bytes tokenName = value0;
        address clientWallet = msg.sender;
        Wallet cp = wallets[clientWallet];
        cp.name = tokenName;
        wallets[clientWallet] = cp;
    }

    function askWalletBalance1(address waletAddress) public alwaysAccept {
        optional(uint256) pubkey;
        ITONTokenWallet(waletAddress).getBalance{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(setTokenBalanceInMenuCB),
        onErrorId : tvm.functionId(someError)
        }();
    }

uint128 bb;
    function setTokenBalanceInMenuCB(uint128 value0) public {
        address answerAddress = msg.sender;
        bb = value0;
        Wallet cp = wallets[answerAddress];
        cp.balanceToken = value0;
        wallets[answerAddress] = cp;
    }
/*
    view client data
*/
    function setDataForView(uint32 index) public {
        for(uint8 i = 0; i < clientWalletKeys.length; i++){
            address cur = clientWalletKeys[i];
            Wallet cp = wallets[cur];
            uint128 bal = cp.balanceToken;
            bytes nam = cp.name;
            Terminal.print(0, format("Wallet address: {}\nToken name: {}\nToken balance: {}\n................", cur, nam, bal));
        }
        (uint64 dec, uint64 float) = tokens(m_clientBalanceTon);
        Terminal.print(tvm.functionId(mainmenu), format("Your client address is: {}\nClient balance: {}.{} TONS", m_Client, dec, float));
    }

    function mainmenu() public {
        Menu.select("", "Main menu", [
            MenuItem("Log into a different client wallet", "", tvm.functionId(selectWallet)),
            MenuItem("Refresh client wallet data", "", tvm.functionId(getClientDataPRE)),
            MenuItem("Display client wallet data", "", tvm.functionId(setDataForView)),
//            MenuItem("Send tokens", "", tvm.functionId(sendTokens_chooseWallet)),
            MenuItem("Create WrappedTON wallet", "", tvm.functionId(createWTONwallet)),
            MenuItem("Wrap tons", "", tvm.functionId(wrapTonsStep)),
//            MenuItem("Unwrap all tons", "", tvm.functionId(unwrapTON1)),
//            MenuItem("Connect to a new token pair", "", tvm.functionId(connectToPair_GetPairAddress)),
            MenuItem("Quit", "", 0)
            ]);
    }

    function wrapTonsStep(uint32 index) public {

        IDEXWrapDebot(m_wrapperDebotAddress).wrapTonsStepExternall(m_Client);
    }

    function someError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("sdkError: {}\nexitCOde:{}", sdkError, exitCode));
        Terminal.print(tvm.functionId(mainmenu), "Back to menu...");
    }
    //service functions
    function tomainmenu(uint32 index) public {
        Terminal.print(tvm.functionId(mainmenu), "Back to menu...");
    }
    function tokens(uint128 nanotokens) private pure returns (uint64, uint64) {
        uint64 decimal = uint64(nanotokens / 1e9);
        uint64 float = uint64(nanotokens - (decimal * 1e9));
        return (decimal, float);
    }

    function getVersion() public override returns (string name, uint24 semver) {
        (name, semver) = ("Radiance DEX-Wrapper debot", 1 << 16);
    }
    function fetch() public override returns (Context[] contexts) {}
    function quit() public override {}
}
