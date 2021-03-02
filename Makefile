NETWORK?=development
IMAGE=bityield-protocol:$(NETWORK)

.PHONY: clean compile test

# Shortcuts 
c: compile
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

deployment:
	@npm run exec scripts/deployment.js -- --network kovan

docker-build:
	docker build --squash -t $(IMAGE) -f Dockerfile .

docker-dist:
	docker push $(HOST)/$(IMAGE)

gas:
	@npm run exec scripts/estimator.js -- --network ${NETWORK}

local:
	@echo "Deploying -> [local]"
	@truffle compile
	@truffle migrate
	@truffle deploy

test:
	@truffle test --network development
