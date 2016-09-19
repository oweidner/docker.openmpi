## docker.openmpi

Travis CI: [![Build Status](https://travis-ci.org/ocramz/docker.openmpi.svg?branch=master)](https://travis-ci.org/ocramz/docker.openmpi)

With the code in this repository, you can build a Docker container that provides 
the OpenMPI runtime and tools along with various supporting libaries, 
including the MPI4Py Python bindings. The container also runs an OpenSSH server
so that multiple containers can be linked together and used via `mpirun`.


## MPI Container Cluster with `docker-compose`

While containers can in principle be started manually via `docker run`, we suggest that your use 
[Docker Compose](https://docs.docker.com/compose/), a simple command-line tool 
to define and run multi-container applications. We provide a sample `docker-compose.yml` file in the repository:

```
mpi_head:
  image: openmpi
  ports: 
   - "22"
  links: 
   - mpi_node

mpi_node: 
  image: openmpi

```
(Note: the above is docker-compose API version 1)

The file defines an `mpi_head` and an `mpi_node`. Both containers run the same `openmpi` image. 
The only difference is, that the `mpi_head` container exposes its SSH server to 
the host system, so you can log into it to start your MPI applications.


## Usage

The following command, run from the repository's directory, will start one `mpi_head` container and three `mpi_node` containers: 

```
$> docker-compose scale mpi_head=1 mpi_node=3
```
Once all containers are running, you can login into the `mpi_head` node and start MPI jobs with `mpirun`. Alternatively, you can execute a one-shot command on that container with the `docker-compose exec` syntax, as follows: 

    docker-compose exec --privileged mpi_head mpirun -n 2 python /home/mpirun/mpi4py_benchmarks/all_tests.py
    ----------------------------------------- ----------- --------------------------------------------------
    1.                                        2.          3.

Breaking the above command down:

1. Execute command on node `mpi-head`
2. run on 2 MPI ranks
3. Command to run (NB: the Python script needs to import MPI bindings)

## Testing

You can spin up a docker-compose cluster, run a battery of MPI4py tests and remove the cluster using a recipe provided in the included Makefile (handy for development):

    make main


## Credits

This repository draws from work on https://github.com/dispel4py/ by O. Weidner and R. Filgueira 
