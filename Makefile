.PHONY: all test

all:
	make -C ./driver-location
	make -C ./gateway
	make -C ./zombie-driver

test:
	docker-compose up -d nsq nsqlookup nsqadmin redis
	make -C ./driver-location test
	make -C ./gateway test
	make -C ./zombie-driver test
	docker-compose down
