solc DEXroot.sol
tvm_linker compile DEXroot.code --lib ../../../../TVM/TON-Solidity-Compiler/lib/stdlib_sol.tvm
tonos-cli genaddr DEXroot.tvc DEXroot.abi.json --genkey DEXroot.keys.json

tvm_linker decode --tvc DEXroot.tvc > code.txt

0:3b730bf0f73d7b9a1f79ded047d5936baa2f91d74407c1a35bb2114f79e86396
jaguar great knock open drink pizza august keep twin soft right agree


tonos-cli account 0:0c3427febed3b30d548f6e76a481bd90786fe7a509929e66b3a0cc23594be735

//копируем из code.txt значение переменной code
//если возникает ошибка можно вызвать вот в таком виде
tvm_linker decode --tvc <DEXCLIENT>>.tvc
//в результате придет переменная code - создать файл code.txt и cкопировать ее значение в этот в файл

export TVM_WALLET_CODE=`cat code.txt`

tonos-cli deploy DEXroot.tvc {} --sign DEXroot.keys.json --abi DEXroot.abi.json

tonos-cli call 0:6a22d6da4131aeec9b07d60f047e900bbacc9e3e47d0132cb8702d0256c796c5 setCfg '{"rootWrapper":"0:ff6da7ac48c8d5cbb9a05013540b52709c04f546ced81bcf0553a027cb04c210","wrapper":"0:a39cbd7030558f6a65ff6c988c2077e464670d57308e908f6a0a3f860e631280"}' --abi DEXroot.abi.json --sign DEXroot.keys.json
tonos-cli run 0:6a22d6da4131aeec9b07d60f047e900bbacc9e3e47d0132cb8702d0256c796c5 getCfg {} --abi DEXroot.abi.json


    function getCfg() public view alwaysAccept returns(address rootWrapper, address wrapper) {

    function setCfg(address rootWrapper, address wrapper) public checkOwnerAndAccept {


адреса подставляем свои
pubkey генерируем ручками

tonos-cli account 0:36c1dbcd47319fc85400f6bd08fb56a0083680ea7cf5baad22a4e230c4565d96
tonos-cli run 0:36c1dbcd47319fc85400f6bd08fb56a0083680ea7cf5baad22a4e230c4565d96 getAddress {} --abi DEXrootClient.abi.json
tonos-cli call 0:6f888960842b35af4af5dabe8ee082bf1c9cbb02e7f0a0e56ca676f8fef84e2d deployNewDexClient '{"pubkey":"0x9261701ded267b8a2e2a3b351a6e992702fbce97a7e9ca3a8bc42e86507b6695"}' --abi DEXrootClient.abi.json --sign DEXrootClient.keys.json


tonos-cli genphrase
tonos-cli getkeypair gg.keys.json "feature furnace plate stock analyst priority race please pioneer ripple seat palace"
