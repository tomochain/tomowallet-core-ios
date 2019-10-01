## TomoWalletCore
**TomoWallet-core** is an important part of **TomoWallet.**
It contains functions that help you interact with **TomoChain** more easier and simpler.
In the next version, we will provider built-in screens to create a wallet, import a wallet via private key/recovery phrase, backup wallet, send fund and confirm a transaction.

TomoWalletcore supports iOS, with CocoaPods and macOS.

## Feature
- Create wallet.
- Manage wallets.
- Import wallet.
- ExportWallet (Mnemonic, Privatekey)
- Make transactions.
- Sign and send transactions.
- Get balance.
- Get token info.

## Installation
CocoaPods
TomoWalletCore is available through CocoaPods. To install

it, simply add the following line to your Podfile:
```
pod 'TomoWalletCore'
```
Next step open terminal from root folder project and enter command line: pod install

After the installation you can import TomoWalletCore in your .swift files.
```
import TomoWalletCore
```
## How to use
Interaction TomoChain
With TomoWalletCore you can connect to TomoChain **Mainnet** or **Testnet**.
The base class for all available methods is WalletCore.
```Swift
let walletCore = WalletCore(network: .Mainnet)
```

##### WalletCore provide the methods:
- CreateWallet
- ImportWallet

##### TomoWallet provide the methods:

- get tomo balance.
- get token balance.
- get token info.
- make transaction.
- send or sign transaction.

### Create your wallet
**Parameters**: none
**Returns**: ```tomoWallet```
```Swift

let walletCore = WalletCore(network: .Mainnet)
walletCore.createWallet { (result) in
    switch result{
    case .success(let wallet):
        //success
        // do something.
        print(wallet.getAddress())
    case .failure(let error):
        print(error)
    }
}
```
### Import wallet with private key
**Parameters**: “745044ccdb778fb6d2d999c561f4329deb57ee3628672d7a2954a53e20b167e”
**Returns**: ```tomoWallet```
```Swift
walletCore.importWallet(hexPrivateKey: "Input your private key here") { (result) in
    switch result{
    case .success(let wallet):
        //success
        //do somwthing.
        print(wallet.getAddress())
    case .failure(let error):
        print(error)
    }
}
```
### Import wallet with Mnemonic
**Parameters**:” ordinary chest giant insane van denial twin music curve offer umbrella spot”
**Returns**: ```tomoWallet```
```Swift
walletCore.importWallet(recoveryPhase: "Input your mnemonic here") { (result) in
    switch result{
    case .success(let wallet):
        //success
        // tomoWallet
        print(wallet.getAddress())
    case .failure(let error):
        print(error)
    }
}
```
### Import wallet with Address read-only
**Parameters**: “0x36d0701257ab74000588e6bdaff014583e03775b “
**Returns**: ```tomoWallet```
```Swift
walletCore.importAddressOnly(address: "Input your address here") { (result) in
    switch result{
    case .success(let wallet):
        //success
        // do something
        print(wallet.getAddress())
    case .failure(let error):
        print(error)
    }
}
```
>*note: If you import address read-only, you can't create or sign transactions by this wallet.*

## Manage Wallets
The TomoWalletCore is support mulitiple wallets, you can create one or more wallets.

TomoWallet have 3 type:
- HDWallet : is the wallet that you created bycreateWallet or imported wallet by recoveryPhase
- Privatekey: is the wallet that you imported by Privatekey
- AddressOnly:is the wallet that you imported by AddressOnly

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
### List all wallets
List all wallets you had created and imported
**Parameters**: none
**Returns** : ```[tomoWallet]```

```Swift
let wallets = walletCore.getAllWallets()
print(wallets.count)
```
### Get a wallet that you have created or imported
**Parameters**: “0x36d0701257ab74000588e6bdaff014583e03775b”
**Returns**: ```tomoWallet```

```Swift
walletCore.getWallet(address: "Input your Address") { (result) in
    switch result{
    case .success(let wallet):
        // success
        // do some thing
        print(wallet)
    case .failure(let error):
        print( error)
    }
}
```
### Get balance
The first, You must import framwork PromiseKit. Promises simplify asynchronous programming.
https://github.com/mxcl/PromiseKit
```Swift
import PromiseKit
```


```
 // get tomo babance
  firstly {
            wallet.getTomoBabance()
        }.done { (balance) in
            // String balance tomo
            // do something
            print(balance)
        }.catch { (let error) in
            print("error")
        }
```
### Get TokenInfo
**Parameters**: Contract address
**Returns** : ```tokenObject```
```Swift
   firstly {
            wallet.getTokenInfo(contract: " input contract address here")
        }.done { (token) in
            // return tokenobject
            print(token)
        }.catch { (let error) in
            print(error)
        }
```
get token babance
**Parameters**: ```tokenObject```
**Returns** : babance
```Swift
firstly {
            wallet.getTokenBalance(token: tokenObject)
        }.done { (tokenBalance) in
            print(tokenBalance)
        }.catch { (let error) in
            print(error)
        }
```
### Make a send tomo transaction
**Parameters**: 
- Address
- Amount tomo

**Returns** : signTransaction
``` Swift

 firstly{
            tomoWallet.makeTomoTransaction(toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684 ", amount: "1.0")
        }.done { (signTransaction) in
            print(signTransaction)
        }.catch { (error) in
            print(error)
        }
```
### Send Tomo transaction
**Parameters**: 
- toAddress
- Amount tomo 

**Returns** : sentTransaction
``` Swift
 firstly{
            wallet.sendTomo(toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "1.0")
        }.done { (sentTransaction) in
            print(sentTransaction)
        }.catch { (error) in
            print( error)
        }
```
### Send Token transaction
**Parameters**: 
- contractAddress
- Address
- Amount tomo

**Returns** : sentTransaction
``` Swift
 firstly{
            wallet.sendToken(contract: "0x3005111b37f476c56480672cebacc0031c95d32f ", toAddress: "0x9f6b8fDD3733B099A91B6D70CDC7963ebBbd2684", amount: "2.0")
        }.done { (sentTransaction) in
            print(sentTransaction)
        }.catch { (error) in
            print( error)
        }
```
## License
MIT
