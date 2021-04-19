solc DEXrootClientStorage.sol
tvm_linker compile DEXrootClientStorage.code --lib ../../../../TVM/TON-Solidity-Compiler/lib/stdlib_sol.tvm
tonos-cli genaddr DEXrootClientStorage.tvc DEXrootClientStorage.abi.json --genkey DEXrootClientStorage.keys.json

tvm_linker decode --tvc DEXclient.tvc > code.txt

0:370e406297517a8874a920339233d2c2dcf4b6b00522d2ed54a1db53266469d8
cotton rigid habit muscle shift cable key chuckle taste equal kidney train


tonos-cli account 0:0c3427febed3b30d548f6e76a481bd90786fe7a509929e66b3a0cc23594be735

//копируем из code.txt значение переменной code
//если возникает ошибка можно вызвать вот в таком виде
tvm_linker decode --tvc DEXclient.tvc
//в результате придет переменная code - создать файл code.txt и cкопировать ее значение в этот в файл

export TVM_WALLET_CODE=`cat code.txt`

tonos-cli deploy DEXrootClientStorage.tvc {} --sign DEXrootClientStorage.keys.json --abi DEXrootClientStorage.abi.json


tonos-cli call 0:370e406297517a8874a920339233d2c2dcf4b6b00522d2ed54a1db53266469d8 setClientCode '{"m_DEXclientCode1":"'$TVM_WALLET_CODE'"}' --abi DEXrootClientStorage.abi.json --sign DEXrootClientStorage.keys.json
tonos-cli run 0:370e406297517a8874a920339233d2c2dcf4b6b00522d2ed54a1db53266469d8 getClientCode1 {} --abi DEXrootClientStorage.abi.json



solc DEXclient.sol
tvm_linker compile DEXclient.code --lib ../../../../TVM/TON-Solidity-Compiler/lib/stdlib_sol.tvm
base64 DEXclient.tvc
tonos-cli genaddr DEXclient.tvc DEXclient.abi.json --genkey DEXclient.keys.json
