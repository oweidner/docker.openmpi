AUTH=ocramz
NAME=docker-openmpi
TAG=${AUTH}/${NAME}

export NNODES=4

.DEFAULT_GOAL := help

help:
	@echo "Use \`make <target>\` where <target> is one of"
	@echo "  help     display this help message"
	@echo "  build   build from Dockerfile"
	@echo "  rebuild rebuild from Dockerfile (ignores cached layers)"
	@echo "  main    build and docker-compose the whole thing"

build:
	docker build -t $(TAG) .

rebuild:
	docker build --no-cache -t $(TAG) .

main:
	# 1 worker node
	docker-compose scale mpi_head=1 mpi_node=1
	docker-compose exec --privileged mpi_head mpirun -n 1 python /home/mpirun/mpi4py_benchmarks/all_tests.py
	docker-compose down

	# 2 worker nodes
	docker-compose scale mpi_head=1 mpi_node=2
	docker-compose exec --privileged mpi_head mpirun -n 2 python /home/mpirun/mpi4py_benchmarks/all_tests.py
	docker-compose down

	# ${NNODES} worker nodes
	docker-compose scale mpi_head=1 mpi_node=${NNODES}
	docker-compose exec --privileged mpi_head mpirun -n ${NNODES} python /home/mpirun/mpi4py_benchmarks/all_tests.py
	docker-compose down
