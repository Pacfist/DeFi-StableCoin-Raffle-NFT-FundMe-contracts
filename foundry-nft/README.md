## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
Sad SVG
data:image/svg+xml;base64,
PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjMwMCIgdmlld0JveD0iMCAwIDMwMCAzMDAiIHhtbG5z
PSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8cmFkaWFsR3JhZGll
bnQgaWQ9ImdyYWQiIGN4PSI1MCUiIGN5PSI1MCUiIHI9IjgwJSI+CiAgICAgIDxzdG9wIG9mZnNl
dD0iMCUiIHN0b3AtY29sb3I9IiNmZjlhOWUiIC8+CiAgICAgIDxzdG9wIG9mZnNldD0iNTAlIiBz
dG9wLWNvbG9yPSIjZmFkMGM0IiAvPgogICAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29s
b3I9IiNmYWQwYzQiIC8+CiAgICA8L3JhZGlhbEdyYWRpZW50PgogICAgPGZpbHRlciBpZD0iYmx1
ciIgeD0iLTIwJSIgeT0iLTIwJSIgd2lkdGg9IjE0MCUiIGhlaWdodD0iMTQwJSI+CiAgICAgIDxm
ZUdhdXNzaWFuQmx1ciBzdGREZXZpYXRpb249IjIwIiAvPgogICAgPC9maWx0ZXI+CiAgPC9kZWZz
PgoKICA8Y2lyY2xlIGN4PSIxNTAiIGN5PSIxNTAiIHI9IjEwMCIgZmlsbD0idXJsKCNncmFkKSIg
ZmlsdGVyPSJ1cmwoI2JsdXIpIiAvPgogIDxwYXRoIGQ9Ik0xMjAgMTgwIFExNTAgMTAwIDE4MCAx
ODAgVDI0MCAxODAiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSI2IiBmaWxsPSJub25lIiAv
PgogIDxjaXJjbGUgY3g9IjEyMCIgY3k9IjEzMCIgcj0iMTAiIGZpbGw9IiNmZmYiIC8+CiAgPGNp
cmNsZSBjeD0iMTgwIiBjeT0iMTMwIiByPSIxMCIgZmlsbD0iI2ZmZiIgLz4KPC9zdmc+Cg==


Happy SVG
data:image/svg+xml;base64,
PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgdmlld0JveD0iMCAwIDIwMCAyMDAiIHhtbG5z
PSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CiAgPGRlZnM+CiAgICA8cmFkaWFsR3JhZGll
bnQgaWQ9ImJnIiBjeD0iNTAlIiBjeT0iNTAlIiByPSI1MCUiPgogICAgICA8c3RvcCBvZmZzZXQ9
IjAlIiBzdG9wLWNvbG9yPSIjZmRmNmUzIi8+CiAgICAgIDxzdG9wIG9mZnNldD0iMTAwJSIgc3Rv
cC1jb2xvcj0iI2ZmZTBlNiIvPgogICAgPC9yYWRpYWxHcmFkaWVudD4KICA8L2RlZnM+CgogIDxj
aXJjbGUgY3g9IjEwMCIgY3k9IjEwMCIgcj0iOTUiIGZpbGw9InVybCgjYmcpIiBzdHJva2U9IiNm
ZmNhZDQiIHN0cm9rZS13aWR0aD0iNCIvPgoKICA8IS0tIEV5ZXMgLS0+CiAgPGNpcmNsZSBjeD0i
NzAiIGN5PSI4MCIgcj0iOCIgZmlsbD0iIzMzMyIgLz4KICA8Y2lyY2xlIGN4PSIxMzAiIGN5PSI4
MCIgcj0iOCIgZmlsbD0iIzMzMyIgLz4KCiAgPCEtLSBTbWlsZSAtLT4KICA8cGF0aCBkPSJNIDYw
IDEyMCBRIDEwMCAxNjAgMTQwIDEyMCIgc3Ryb2tlPSIjMzMzIiBzdHJva2Utd2lkdGg9IjUiIGZp
bGw9Im5vbmUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgLz4KCiAgPCEtLSBEaW1wbGVzIC0tPgog
IDxjaXJjbGUgY3g9IjU1IiBjeT0iMTIwIiByPSIyIiBmaWxsPSIjYWFhIi8+CiAgPGNpcmNsZSBj
eD0iMTQ1IiBjeT0iMTIwIiByPSIyIiBmaWxsPSIjYWFhIi8+Cjwvc3ZnPgo=