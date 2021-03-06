# Bityield Index Protocol

## Setup

Install:

```
npm i
```

Compile:

```
make c
```

Test

```
make t
```

Deploy

```
NETWORK=ropsten make deploy
```

## Gas Estimation

Estimate:

```
make gas
```

## Contract Size

Size:

```
make size
```

## Contract ABI

ABI:

```
make abi
```


## Usage

In order to execute an `enterMarket` contract call, there must be a valid Uniswap Pair for the given initialized token set on the Index contract constructor.