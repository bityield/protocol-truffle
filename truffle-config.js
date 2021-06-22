/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

// const HDWalletProvider = require('@truffle/hdwallet-provider');
// const infuraKey = 'fj4jll3k.....';
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync('.secret').toString().trim();

// Load environment configuration from .env
require('dotenv').config();

const WalletProvider = require('truffle-wallet-provider');
const Wallet = require('ethereumjs-wallet');
const assert = require('assert');
const utils = require('web3-utils');
const Web3 = require('web3');
const web3 = new Web3();

const mainNetPrivateKey = new Buffer(process.env['MAINNET_PRIVATE_KEY'], 'hex')
const mainNetWallet = Wallet.fromPrivateKey(mainNetPrivateKey);
const mainNetProvider = new WalletProvider(mainNetWallet, process.env['INFURA_MAINNET_API_ENDPOINT']);

const kovanPrivateKey = new Buffer(process.env['KOVAN_PRIVATE_KEY'], 'hex')
const kovanWallet = Wallet.fromPrivateKey(kovanPrivateKey);
const kovanProvider = new WalletProvider(kovanWallet, process.env['INFURA_KOVAN_API_ENDPOINT']);

assert(process.env.KOVAN_PRIVATE_KEY, 'missing KOVAN_PRIVATE_KEY in .env file');
assert(process.env.INFURA_KOVAN_API_ENDPOINT, 'missing INFURA_KOVAN_API_ENDPOINT in .env file');

const ropstenPrivateKey = new Buffer(process.env['ROPSTEN_PRIVATE_KEY'], 'hex')
const ropstenWallet = Wallet.fromPrivateKey(ropstenPrivateKey);
const ropstenProvider = new WalletProvider(ropstenWallet, process.env['INFURA_ROPSTEN_API_ENDPOINT']);

assert(process.env.ROPSTEN_PRIVATE_KEY, 'missing ROPSTEN_PRIVATE_KEY in .env file');
assert(process.env.INFURA_ROPSTEN_API_ENDPOINT, 'missing INFURA_ROPSTEN_API_ENDPOINT in .env file');

module.exports = {
  plugins: [
    'truffle-contract-size',
    'truffle-plugin-verify',
  ],
  api_keys: {
    etherscan: process.env['ETHERSCAN_API_KEY']
  },
  networks: {
    localRopsten: {
      host: 'localhost',
      port: 8545,
      network_id: '3',
      skipDryRun: true,
      migrations_directory: 'migrations',
    },
    development: {
      host: 'localhost',
      port: 7545,
      network_id: '5777',
      skipDryRun: true,
      migrations_directory: 'migrations',
    },
    ropsten: {
      provider: () => {
        return new WalletProvider(ropstenWallet, process.env['INFURA_ROPSTEN_API_ENDPOINT']);
      },
      gas: 5000000,
      gasPrice: utils.toWei('100', 'gwei'),
      network_id: 3,
      skipDryRun: true,
    },
    kovan: {
      provider: () => {
        return new WalletProvider(kovanWallet, process.env['INFURA_KOVAN_API_ENDPOINT']);
      },
      gas: 5000000,
      gasPrice: utils.toWei('1', 'gwei'),
      network_id: 42,
      skipDryRun: true,
    },
    mainnet: {
      provider: () => {
        return new WalletProvider(kovanWallet, process.env['INFURA_MAINNET_API_ENDPOINT']);
      },
      network_id: 1,
      gas: 5000000,
      gasPrice: utils.toWei('90', 'gwei'),
    },
    matic: {
      provider: () => new HDWalletProvider(mnemonic, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
    },
  },
  compilers: {
    solc: {
      version: '0.6.10',
      docker: false,
      parser: 'solcjs',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
        'outputSelection': {
          '*': {
            '*': [
              'abi',
              'ast',
              'evm.bytecode.object',
              'evm.bytecode.sourceMap',
              'evm.deployedBytecode.object',
              'evm.deployedBytecode.sourceMap',
            ]
          },
        }
      },
    }
  },
  mocha: {
    enableTimeouts: false,
    useColors: true,
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      showTimeSpent: true,
      currency: 'USD'
    }
  }
};
