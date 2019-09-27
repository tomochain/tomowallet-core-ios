#  TomoWalletCore


TomoWallet-core is an important part of TomoWallet.  
It contains functions that help you interact with TomoChain more easier and simpler.  
In the next version, we will provider built-in screens to create a wallet, import a wallet via private key/recovery phrase, backup wallet, send fund and confirm a transaction.

TomoWalletcore supports iOS,  with CocoaPods and macOS.



## Example



Check the usage below or look through the repositories tests.



## Why?


`TomoWalletCore` was built with simply, modularity, portability, speed and efficiency in mind.



## Installation



### CocoaPods



TomoWalletCore is available through [CocoaPods](http://cocoapods.org). To install

it, simply add the following line to your `Podfile`:



```ruby

pod 'TomoWalletCore'

```




After the installation you can import `TomoWalletCore` in your `.swift` files.



```Swift

import TomoWalletCore

```



##  How to use



### Interaction TomoChain



With `TomoWalletCore` you can connect to TomoChain Mainnet or Testnet.
The base class for all available methods is `WalletCore`.



```Swift

let walletCore = WalletCore(network: .Mainnet)

```


### Create your wallet



Return an `TomoWallet` object



****Parameters****



none



****Returns****



`TomoWallet` - The Object have methods, You can send signed transactions, call contract  and much more.



```Swift

let walletCore = WalletCore(network: .Mainnet)

walletCore.createWallet { (result) in
switch result{
case .success(let wallet):
//success
print(wallet.getAddress())
case .failure(let error):
print(error)
}
}

```



#### Import wallet with private key

Return an `TomoWallet`  object.



****Parameters****



Privatekey: String 
For xample:  745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e



****Returns****



`TomoWallet` - The Object have methods, You can send signed transactions, call contract  and much more.



```Swift
walletCore.importWallet(hexPrivateKey: "Input your private key here") { (result) in
switch result{
case .success(let wallet):
//success
print(wallet.getAddress())
case .failure(let error):
print(error)
}
}
```



#### Import wallet with Mnemonic



Return an `TomoWallet`  object.


****Parameters****



Mnemonic: String 
For xample: ordinary chest giant insane van denial twin music curve offer umbrella spot



****Returns****



`TomoWallet` - The Object have methods, You can send signed transactions, call contract  and much more.




```Swift
walletCore.importWallet(recoveryPhase: "Input your mnemonic here") { (result) in
switch result{
case .success(let wallet):
//success
print(wallet.getAddress())
case .failure(let error):
print(error)
}
}
```

#### Import wallet with Address readonly
- Return an `TomoWallet`  object. but you can't sign or send transaction on more . it is reading balance Tomo or TRC token


****Parameters****



Address: String
For xample: 0x36d0701257ab74000588e6bdaff014583e03775b



****Returns****



`TomoWallet` : Object




```Swift
walletCore.importAddressOnly(address: "Input your address here") { (result) in
switch result{
case .success(let wallet):
//success
print(wallet.getAddress())
case .failure(let error):
print(error)
}
}
```



### Manage Wallets
- The `TomoWalletCore` is support mulitiple wallet, you can create one or more wallets.
- `TomoWallet` have 3 type:
+ HDWallet : is the wallet that you created by`createWallet` or imported wallet by `recoveryPhase`
+ Privatekey: is the wallet that you imported by `Privatekey`
+ AddressOnly:is the wallet that you imported by `AddressOnly`

```Swift

switch wallet.walletType(){
case .AddressOnly:
print("AddressOnly")
case .Privatekey:
print("PrivateKey")
case .HDWallet:
print("HDWallet")
}

```
#### List all wallets  
- List all wallets you had created and imported

****Parameters****
none
****Returns****
`[TomoWallet]` : Array
```Swift

let wallets = walletCore.getAllWallets()

```
#### Get a wallet that you have created or imported
- The response `TomoWallet`

****Parameters****



Address: String
0x36d0701257ab74000588e6bdaff014583e03775b



****Returns****



`TomoWallet` : Object



```Swift

walletCore.getWallet(address: "Input your Address") { (result) in
switch result{
case .success(let wallet):
// success
print(wallet)
case .failure(let error):
print( error)
}
}
```


#### Get balance

``` Swift
wallet.getTomoBabance()
```
#### Get TokenInfo
``` Swift
wallet.getTokenInfo(contract: "Input Addres ontract")
```
#### Get babance Token
``` Swift
wallet.getTokenBalance(contract:"Input Addres Contract
```


## License


TomoWalletCore is available under the MIT license. See the LICENSE file for more info.
