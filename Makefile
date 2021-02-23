NETWORK?=local
IMAGE=bityield-protocol:$(NETWORK)

abi:
	@python scripts/abi.py

compile:
	@truffle compile

console:
	@echo "ex: 'const i = await {Contract}.deployed()'"
	@echo "ex: 'const r = await i.getVersion()'"
	@npx truffle console --network ${NETWORK}

deploy:
	@echo "Deploying -> [${NETWORK}]"
	@npx truffle compile --network ${NETWORK}
	@npx truffle migrate --network ${NETWORK}
	@npx truffle deploy --network ${NETWORK}

docker-build:
	docker build --squash -t $(IMAGE) -f Dockerfile .

docker-dist:
	docker push $(HOST)/$(IMAGE)

local:
	@echo "Deploying -> [local]"
	@truffle compile
	@truffle migrate
	@truffle deploy
