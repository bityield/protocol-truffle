require('dotenv').config();

const Web3 = require('web3');
const ethers = require('ethers');
const fs = require('fs');
const py = require('pryjs');
const assert = require('assert');

const HDWalletProviderMnemonic = require('truffle-hdwallet-provider');
const HDWalletProviderPrivKeys = require('truffle-hdwallet-provider-privkey');

const prvteKey = process.env.PRIVATE_KEY;
const network  = process.env.NETWORK || null;
const version  = process.env.VERSION || null;

if (version === null) {
    throw('Must pass a valid version\n');
}

const getABI = (type, name, w3) => {
    let functionType = type;
    let functionName = name;

    let functionDefinition = {
        definition: [
            `${functionType} ${functionName}()`,
        ],
        invocation: {
            method: `${functionName}`,
            parameters: [],
        },
    };

    let iface = new ethers.utils.Interface(functionDefinition.definition);
    let wABI = iface.encodeFunctionData(functionDefinition.invocation.method, functionDefinition.invocation.parameters)

    return wABI;
};

let chainID;

let alchemyHost;
let infuraHost;

let cDaiAddress;
let daiAddress;
let daiMcdJoin;
let daiMcdMnemonic;

switch(network) {
  case "mainnet":
    alchemyHost = process.env.ALCHEMY_MAINNET_API_ENDPOINT;
	infuraHost = process.env.INFURA_MAINNET_API_ENDPOINT;

    daiAddress = process.env.DAI_MAINNET_ADDRESS;
    daiMcdJoin = process.env.DAI_MCD_MAINNET_ADDRESS;
    daiMcdMnemonic = process.env.DAI_MCD_MAINNET_MNEMONIC;

    cDaiAddress = '0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643';

    chainID = 1;

	break;
  case "ropsten":
    alchemyHost = process.env.ALCHEMY_ROPSTEN_API_ENDPOINT;
	infuraHost = process.env.INFURA_ROPSTEN_API_ENDPOINT;

    chainID = 3;

    daiAddress = process.env.DAI_ROPSTEN_ADDRESS;
    daiMcdJoin = process.env.DAI_MCD_ROPSTEN_ADDRESS;
    daiMcdMnemonic = process.env.DAI_MCD_ROPSTEN_MNEMONIC;

    cDaiAddress = '0xbc689667C13FB2a04f09272753760E38a95B998C';

	break;
  case "localRopsten":
    alchemyHost = process.env.ALCHEMY_ROPSTEN_API_ENDPOINT;
	infuraHost = process.env.INFURA_ROPSTEN_API_ENDPOINT;

    chainID = 3;

    daiAddress = process.env.DAI_ROPSTEN_ADDRESS;
    daiMcdJoin = process.env.DAI_MCD_ROPSTEN_ADDRESS;
    daiMcdMnemonic = process.env.DAI_MCD_ROPSTEN_MNEMONIC;

    cDaiAddress = '0xbc689667C13FB2a04f09272753760E38a95B998C';

    break;
  default:
	throw("Incorrect network passed");
}

const assetName = 'DAI';
const underlyingDecimals = 18;

const infuraProviderMn_daiMCD    = new HDWalletProviderMnemonic(daiMcdMnemonic, infuraHost, 1); 
const infuraProviderPk_personal  = new HDWalletProviderPrivKeys([prvteKey], infuraHost, 1);

const alchemyProviderMn_daiMCD    = new HDWalletProviderMnemonic(daiMcdMnemonic, alchemyHost, 1); 
const alchemyProviderPk_personal  = new HDWalletProviderPrivKeys([prvteKey], alchemyHost, 1);

// This uses DAI MCD private key - oddly this is public
const web3AM = new Web3(alchemyProviderMn_daiMCD);
const web3IM = new Web3(infuraProviderMn_daiMCD);

// This uses personal private key - do not share this!!!
const web3AP = new Web3(alchemyProviderPk_personal);
const web3IP = new Web3(infuraProviderPk_personal);

// Go through ganache-cli to $NETWORK
const web3D = new Web3('http://127.0.0.1:8545');

// Set the current web3 provider to the accounts to be used.
const web3 = web3D;

const Name  = `IndexV${version}`;
const Index = artifacts.require(Name);

module.exports = async (callback) => {
    const accounts = await web3.eth.getAccounts();
    const ownerAct = accounts[0];

    const daiAbi = require('../resources/abi/dai-abi.json');
    const daiContract = new web3.eth.Contract(daiAbi, daiAddress);
    
    const compoundCDaiContractAbi = require('../resources/abi/c-dai-abi.json');
    const compoundCDaiContract = new web3.eth.Contract(compoundCDaiContractAbi, cDaiAddress);

    console.log('\n\n');
    console.log('Start -------------------------------------');
    console.log(`our account: ${ownerAct}`);
    console.log(`our index: ${Index.address}`);
    console.log(`daiAdr ${network}:${daiAddress}`);
    console.log(`daiMcd ${network}:${daiMcdJoin}`);

    const numbDaiToMint = web3.utils.toWei('100', 'ether');

    console.log('\n\n------- calling #mint');
    await daiContract.methods.mint(Index.address, numbDaiToMint).send({ 
        from: daiMcdJoin,
		gasPrice: web3.utils.toHex(0)
    })
        .once('transactionHash', (hash) => {
            console.log('DAI mint transactionHash -> ', hash);
        })
        .then((result) => {
            console.log('DAI mint success');
            return daiContract.methods.balanceOf(Index.address).call();
        }).then((balanceOf) => {
            const dai = balanceOf / 1e18;
            console.log('DAI balance:', dai);
        }).catch((err) => {
            throw(err);
        });
    
    const indexABI = JSON.parse(fs.readFileSync(`./build/contracts/${Name}.json`)).abi;
    const indexCON = new web3.eth.Contract(indexABI, Index.address);

    console.log('\n\n------- calling #enterMarket');
    await indexCON.methods.enterMarket().send({ 
		to: Index.address,
		from: ownerAct,
		value: web3.utils.toWei('1.0', 'ether'),
		data: getABI('function', 'enterMarket', web3),
		gas: 2000000,
		gasPrice: web3.utils.toWei('1', 'gwei'),
		gasLimit: '0x5208',
    })
        .once('transactionHash', (hash) => {
            console.log('transactionHash -> ', hash);
        })
        .once('receipt', (receipt) => {
            assert(receipt.events.Log[0].event == 'Log');
            assert(receipt.events.Log[1].event == 'Log');

            assert(receipt.events.Log[0].returnValues._message == "Exchange Rate (scaled up)")
            assert(receipt.events.Log[1].returnValues._message == "Supply Rate (scaled up)")

            console.log(receipt.events.Log[3].returnValues._message, ' ', receipt.events.Log[3].returnValues._amount);
        })
        .on('error', (error) => {
            throw(error);
        });

    console.log(`Checking ERC20 balances at Index address: ${Index.address}`);
    await indexCON.methods.balanceOf(daiAddress).call().then((bal) => {
        console.log(`${Index.address} / daiAddress[${daiAddress}], balance: ${bal}`);
    });

    await indexCON.methods.balanceOf(daiMcdJoin).call().then((bal) => {
        console.log(`${Index.address} / daiMcdJoin[${daiMcdJoin}], balance: ${bal}`);
    });

    console.log(`Checking ERC20 balances at DAI address: ${daiMcdJoin}`);
    await daiContract.methods.balanceOf(daiAddress).call().then((bal) => {
        console.log(`${daiAddress} / daiAddress[${daiAddress}], balance: ${bal}`);
    });

    await daiContract.methods.balanceOf(daiMcdJoin).call().then((bal) => {
        console.log(`${daiAddress} / daiMcdJoin[${daiMcdJoin}], balance: ${bal}`);
    });

    let balanceOfUnderlying = await compoundCDaiContract.methods.balanceOfUnderlying(Index.address).call();
    const balanceOfUnderlyingDai = web3.utils.fromWei(balanceOfUnderlying);
    console.log(`${assetName} supplied to the Compound Protocol:`, balanceOfUnderlyingDai);

    let cTokenBalance = await compoundCDaiContract.methods.balanceOf(Index.address).call();
    cTokenBalance = cTokenBalance / 1e8;
    console.log(`MyContract's c${assetName} Token Balance:`, cTokenBalance);

    let endingDaiBalance = await daiContract.methods.balanceOf(Index.address).call();
    endingDaiBalance = endingDaiBalance / 1e8;
    console.log(`MyContract's dai balance:`, endingDaiBalance);

    let endingcDaiBalance = await indexCON.methods.balanceOf(cDaiAddress).call();
    endingcDaiBalance = endingcDaiBalance / 1e8;
    console.log(`MyContract's cDai balance:`, endingcDaiBalance);

    console.log('\n\n\-------------------------');
    console.log('\n\n------- calling #exitMarket');
    await indexCON.methods.exitMarket().send({ 
		to: Index.address,
		from: ownerAct,
		data: getABI('function', 'exitMarket', web3),
		gas: 2000000,
		gasPrice: web3.utils.toWei('1', 'gwei'),
		gasLimit: '0x5208',
    })
        .once('transactionHash', (hash) => {
            console.log('transactionHash -> ', hash);
        })
        .once('receipt', (receipt) => {
            console.log(receipt);
        })
        .on('error', (error) => {
            throw(error);
        });

	callback();
}