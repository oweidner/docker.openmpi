#!/bin/sh

NNODES=$1

pwd
ls -lsA

mpirun -n ${NNODES} python /home/mpirun/mpi4py_benchmarks/matrix_vector_product.py
mpirun -n ${NNODES} python /home/mpirun/mpi4py_benchmarks/osu_bibw.py
mpirun -n ${NNODES} python /home/mpirun/mpi4py_benchmarks/osu_bw.py
mpirun -n ${NNODES} python /home/mpirun/mpi4py_benchmarks/osu_latency.py
