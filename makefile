AUTH=ocramz
NAME=docker-openmpi
TAG=${AUTH}/${NAME}

NNODES=4

.DEFAULT_GOAL := help

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo "  help     display this help message"
	@echo "  build   build from Dockerfile"
	@echo "  main    build and docker-compose the whole thing"

build:
	docker build -t $(TAG) .

main:
	docker-compose scale mpi_head=1 mpi_node=${NNODES}
	docker-compose exec --privileged mpi_head /bin/bash -c ./home/mpirun/mpi4py_benchmarks/run_tests.sh ${NNODES}
	docker-compose down
