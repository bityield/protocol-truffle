NETWORK?=development
IMAGE=bityield-protocol:$(NETWORK)
SOLC_VERSION=0.6.10

.PHONY: abi clean compile console deploy docker-build docker-dist gas local size test

# Shortcuts
c: compile
g: gas
s: size
t: test

abi:
	@python scripts/abi.py

call:
	@npm run exec scripts/call.js -- --network ${NETWORK}

clean:
	@rm -rf ./build/

compile:
	@truffle compile --network ${NETWORK}

compound-build:
	@npm run exec scripts/build.js -- --network ${NETWORK}

console:
	@echo "ex: 'const i = await {Contract}.deployed()'"
	@echo "ex: 'const r = await i.getVersion()'"
	@npx truffle console --network ${NETWORK}

deploy:
	@echo "Deploying -> [${NETWORK}]"
	@npx truffle compile --network ${NETWORK}
	@npx truffle migrate --network ${NETWORK}
	@npx truffle run verify IndexV1 --network ${NETWORK} || true
	@npx truffle run verify IndexV2 --network ${NETWORK} || true

docker-build:
	docker build --squash -t $(IMAGE) -f Dockerfile .

docker-dist:
	docker push $(HOST)/$(IMAGE)

flatten:
	@./node_modules/truffle-flattener/index.js ./contracts/IndexV1.sol > tmp/IndexV1.sol
	@./node_modules/truffle-flattener/index.js ./contracts/IndexV2.sol > tmp/IndexV2.sol
	@pbcopy < tmp/IndexV1.sol
	@echo "Copied to clibboard..."

ganache:
	@ganache-cli --defaultBalanceEther 10000 --networkId 5777 --port 7545

gas:
	@npm run exec scripts/estimator.js -- --network ${NETWORK}

local: clean
	@echo "Deploying -> [local]"
	@truffle compile
	@truffle migrate

localRopsten: clean
	@echo "Deploying -> [localRopsten]"
	@truffle compile --network "localRopsten"
	@truffle migrate --network "localRopsten"

localRopstenGanacheAlchemy:
	@ganache-cli \
		-f https://eth-ropsten.alchemyapi.io/v2/c57vAQEwMuMiQBf3eFLMx8dEkWMjK-0t \
		-m "clutch captain shoe salt awake harvest setup primary inmate ugly among become" \
		-i 3 \
		-u 0xA0b569e9E0816A20Ab548D692340cC28aC7Be986

localRopstenGanacheInfura:
	@ganache-cli \
		-f https://ropsten.infura.io/v3/5ddff3d540c34448838ae811bc08449d \
		-m "clutch captain shoe salt awake harvest setup primary inmate ugly among become" \
		-i 3 \
		-u 0xA0b569e9E0816A20Ab548D692340cC28aC7Be986

mint:
	@npm run exec scripts/mint.js -- --network ${NETWORK}

size: compile
	@truffle run contract-size

test: compile
	@truffle test --network development
	# @truffle run coverage --network development

verify:
	@npx truffle run verify IndexV1 --network ${NETWORK} || true
	@npx truffle run verify IndexV2 --network ${NETWORK} || true