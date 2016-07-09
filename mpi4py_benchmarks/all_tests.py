"""
MVP : Demonstrating a MPI parallel Matrix-Vector Multiplication.
This code will run *iter* iterations of
  v(t+1) = M * v(t)
where v is a vector of length *size* and M a dense size*size
matrix. *size* must be an integer multiple of comm.size.
v is initialized to be zero except of v[0] = 1.0
M is a "off-by-one" diagonal matrix M[i, i+1] = 1.0
In effect, after *iter* iterations, the vector v should look like
v[iter] = 1. (all others zero).
In this example every MPI process is responsible for calculating a
different portion of v. Every process only knows the stripe of M, that
is relevant for it's calculation. At the end of every iteration,
Allgather is used to distribute the partial vectors v to all other
processes.
"""

from __future__ import division

import numpy as np
# from numpy.fft import fft2, ifft2
from math import ceil, fabs
from mpi4py import MPI

#=============================================================================
# I/O Utilities

def pprint(str="", end="\n", comm=MPI.COMM_WORLD):
    """Print for MPI parallel programs: Only rank 0 prints *str*."""
    if comm.rank == 0:
        print str+end,

#=============================================================================
# Main

def mvp_main(size=10000, iter=2000):
    # size = 10000           # length of vector v
    # iter = 2000            # number of iterations to run

    counter = 0

    comm = MPI.COMM_WORLD

    pprint("============================================================================")
    pprint(" Running %d parallel MPI processes" % comm.size)

    my_size = size // comm.size     # Every process computes a vector of lenth *my_size*
    size = comm.size*my_size        # Make sure size is a integer multiple of comm.size
    my_offset = comm.rank*my_size

    # This is the complete vector
    vec = np.zeros(size)            # Every element zero...
    vec[0] = 1.0                    #  ... besides vec[0]

    # Create my (local) slice of the matrix
    my_M = np.zeros((my_size, size))
    for i in xrange(my_size):
        j = (my_offset+i-1) % size
        my_M[i,j] = 1.0


    while counter < iter:
        comm.Barrier()                    ### Start stopwatch ###
        t_start = MPI.Wtime()

        for t in xrange(20):
            my_new_vec = np.inner(my_M, vec)

            comm.Allgather(
                [my_new_vec, MPI.DOUBLE],
                [vec, MPI.DOUBLE]
            )

        comm.Barrier()
        t_diff = MPI.Wtime() - t_start    ### Stop stopwatch ###

        # if fabs(vec[iter]-1.0) > 0.01:
        #     pprint("!! Error: Wrong result!")

        pprint(" %d iterations of size %d in %5.2fs: %5.2f iterations per second" %
            (20, size, t_diff, 20/t_diff)
        )

        counter += 20




def osu_latency(
    BENCHMARH = "MPI Latency Test",
    skip = 1000,
    loop = 10000,
    skip_large = 10,
    loop_large = 100,
    large_message_size = 8192,
    MAX_MSG_SIZE = 1<<22,
    ):

    comm = MPI.COMM_WORLD
    myid = comm.Get_rank()
    numprocs = comm.Get_size()

    if numprocs != 2:
        if myid == 0:
            errmsg = "This test requires exactly two processes"
        else:
            errmsg = None
        raise SystemExit(errmsg)

    s_buf = allocate(MAX_MSG_SIZE)
    r_buf = allocate(MAX_MSG_SIZE)

    if myid == 0:
        print ('# %s' % (BENCHMARH,))
    if myid == 0:
        print ('# %-8s%20s' % ("Size [B]", "Latency [us]"))

    message_sizes = [0] + [2**i for i in range(30)]
    for size in message_sizes:
        if size > MAX_MSG_SIZE:
            break
        if size > large_message_size:
            skip = skip_large
            loop = loop_large
        iterations = list(range(loop+skip))
        s_msg = [s_buf, size, MPI.BYTE]
        r_msg = [r_buf, size, MPI.BYTE]
        #
        comm.Barrier()
        if myid == 0:
            for i in iterations:
                if i == skip:
                    t_start = MPI.Wtime()
                comm.Send(s_msg, 1, 1)
                comm.Recv(r_msg, 1, 1)
            t_end = MPI.Wtime()
        elif myid == 1:
            for i in iterations:
                comm.Recv(r_msg, 0, 1)
                comm.Send(s_msg, 0, 1)
        #
        if myid == 0:
            latency = (t_end - t_start) * 1e6 / (2 * loop)
            print ('%-10d%20.2f' % (size, latency))


def allocate(n):
    try:
        import mmap
        return mmap.mmap(-1, n)
    except (ImportError, EnvironmentError):
        try:
            from numpy import zeros
            return zeros(n, 'B')
        except ImportError:
            from array import array
            return array('B', [0]) * n


if __name__ == '__main__':
    mvp_main()
    osu_latency()
