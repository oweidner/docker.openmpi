#!/bin/bash

NNODES=2

echo ${HOME}

cd ${HOME}/mpi4py_benchmarks
ls -lsA

mpirun -n ${NNODES} python matrix_vector_product.py
mpirun -n ${NNODES} python osu_bibw.py
mpirun -n ${NNODES} python osu_bw.py
mpirun -n ${NNODES} python osu_latency.py
