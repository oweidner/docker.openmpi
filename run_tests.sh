#!/bin/sh

NNODES=$1

export P=${HOME}/mpi4py_benchmarks/

pwd
ls -lsA

mpirun -n ${NNODES} python ./matrix_vector_product.py
mpirun -n ${NNODES} python ./osu_bibw.py
mpirun -n ${NNODES} python ./osu_bw.py
mpirun -n ${NNODES} python ./osu_latency.py
