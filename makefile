AUTH=ocramz
NAME=docker-openmpi
TAG=${AUTH}/${NAME}

build:
	docker build -t $(TAG)

main:
	docker-compose scale mpi_head=1 mpi_node=3
	# docker-compose down
