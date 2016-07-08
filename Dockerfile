# Build this image:  docker build -t mpi .
#

# FROM ubuntu:14.04
FROM phusion/baseimage
MAINTAINER Ole Weidner <ole.weidner@ed.ac.uk>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y openssh-server python-mpi4py python-numpy \
            python-virtualenv python-scipy gcc gfortran openmpi-checkpoint binutils

RUN mkdir /var/run/sshd
RUN echo 'root:mpirun' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

RUN adduser --disabled-password --gecos "" mpirun && \
    echo "mpirun ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV HOME /home/mpirun

# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

RUN mkdir /home/mpirun/.ssh/
ADD ssh/config /home/mpirun/.ssh/config
ADD ssh/id_rsa.mpi /home/mpirun/.ssh/id_rsa
ADD ssh/id_rsa.mpi.pub /home/mpirun/.ssh/id_rsa.pub
ADD ssh/id_rsa.mpi.pub /home/mpirun/.ssh/authorized_keys

RUN chmod -R 600 /home/mpirun/.ssh/* && \
    chown -R mpirun:mpirun /home/mpirun/.ssh

# ------------------------------------------------------------
# Copy Rosa's MPI4PY example scripts
# ------------------------------------------------------------

ADD mpi4py_benchmarks /home/mpirun/mpi4py_benchmarks
RUN chown mpirun:mpirun /home/mpirun/mpi4py_benchmarks

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
