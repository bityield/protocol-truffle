NETWORK?=development
IMAGE=bityield-protocol:$(NETWORK)

.PHONY: abi clean compile console deploy docker-build docker-dist gas local size test

# Shortcuts 
c: compile
g: gas
s: size
t: test

abi:
	@python scripts/abi.py

clean:
	@rm -rf ./build/

compile: clean
	@truffle compile

console:
	@echo "ex: 'const i = await {Contract}.deployed()'"
	@echo "ex: 'const r = await i.getVersion()'"
	@npx truffle console --network ${NETWORK}

deploy: clean
	@echo "Deploying -> [${NETWORK}]"
	@npx truffle compile --network ${NETWORK}
	@npx truffle migrate --network ${NETWORK}
	@npx truffle deploy --network ${NETWORK}
	@npx truffle run verify IndexC1 --network ${NETWORK}

docker-build:
	docker build --squash -t $(IMAGE) -f Dockerfile .

docker-dist:
	docker push $(HOST)/$(IMAGE)

gas:
	@npm run exec scripts/estimator.js -- --network ${NETWORK}

local: clean
	@echo "Deploying -> [local]"
	@truffle compile
	@truffle migrate --reset
	@truffle deploy

size: compile
	@truffle run contract-size

test:
	@truffle test --network development