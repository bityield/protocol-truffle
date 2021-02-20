migrate:
	@npx truffle migrate --network kovan
	@npx truffle migrate --network ropsten

# deploy:
# 	@npx truffle deploy --network kovan
# 	@npx truffle deploy --network ropsten

abiDocker:
	@docker run -v /Users/alexmanelis/Development/Solidity/acme/contracts:/sources ethereum/solc:0.7.1 /sources/Exchange.sol --abi

abiLocal:
	@python abi.py build/contracts/Allocator.json

compile:
	@truffle compile

console:
	@echo "ex: 'const i = await {Contract}.deployed()'"
	@echo "ex: 'const r = await i.getVersion()'"
	@npx truffle console --network ${NETWORK}

local:
	@echo "Deploying -> [local]"
	@truffle compile
	@truffle migrate
	@truffle deploy

deploy:
	@echo "Deploying -> [${NETWORK}]"
	@npx truffle compile --network ${NETWORK}
	@npx truffle migrate --network ${NETWORK}
	@npx truffle deploy --network ${NETWORK}
