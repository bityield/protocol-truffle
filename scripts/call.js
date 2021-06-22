require('dotenv').config();

const Web3 = require('web3');
const ethers = require('ethers');

const HDWalletProviderPrivKeys = require('truffle-hdwallet-provider-privkey');
const prvteKey = process.env.PRIVATE_KEY;
const network  = process.env.NETWORK || null;
const version  = process.env.VERSION || null;

if (version === null) {
    throw('Must pass a valid version\n');
}

let alchemyHost;
let infuraHost;

switch(network) {
  case "mainnet":
  	alchemyHost = process.env.ALCHEMY_MAINNET_API_ENDPOINT;
	infuraHost = process.env.INFURA_MAINNET_API_ENDPOINT;

	break;
  case "ropsten":
	alchemyHost = process.env.ALCHEMY_ROPSTEN_API_ENDPOINT;
	infuraHost = process.env.INFURA_ROPSTEN_API_ENDPOINT;

	break;
  default:
	throw("Incorrect network passed");
}

const alchemyProviderPk = new HDWalletProviderPrivKeys([prvteKey], alchemyHost, 1);
const infuraProviderPk  = new HDWalletProviderPrivKeys([prvteKey], infuraHost, 1);

const web3 = new Web3(infuraProviderPk);

const Name  = `IndexV${version}`;
const Index = artifacts.require(Name);

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

module.exports = async (callback) => {
	const accounts = await web3.eth.getAccounts();

	console.log(`executing against [${Name}] version...`);
	console.log('sending from account:', accounts[0]);
	console.log('calling contract at: ', Index.address);

	await web3.eth.sendTransaction({
		to: Index.address,
		from: accounts[0],
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
			console.log('receipt -> ', receipt);
		})
		.on('error', (error) => {
			throw(error);
		})
		.then((receipt) => {
			console.log('receipt -> ', receipt);
		});

    await web3.eth.sendTransaction({
        to: Index.address,
        from: accounts[0],
        data: getABI('function', 'exitMarket', web3),
        gas: 1500000,
        gasPrice: web3.utils.toWei('1', 'gwei'),
    })
        .once('transactionHash', (hash) => {
            console.log('transactionHash -> ', hash);
        })
        .once('receipt', (receipt) => {
            console.log('receipt -> ', receipt);
        })
        .on('error', (error) => {
            throw(error);
        })
        .then((receipt) => {
            console.log('receipt -> ', receipt);
        });

	callback();
}